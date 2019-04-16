function rv=stationary_reference_correction(frm_start,frm_stop,fpath,disp_scale,bpass_inputs,pkfnd_inputs,maxdisp)
%manual drift correction. It returns a matrix of n by 3, where cols 1 and 
%2 are the drift correction in xy format and the third is the frame of the
%corresponding displacement.
%frm_start is the starting frame.
%frm_stop is the last frame.
%fpath is the path to the file (ends in backslash).
%disp_scale is the display scale. eg. [1000 1800]
%bpass_inputs=[x y]
% 	X: Characteristic lengthscale of noise in pixels. Additive noise averaged over this length should vanish. 			
%        May assume any positive floating value. , 
% 	Y: A length in pixels somewhat larger than a typical object. Must be an odd valued integer.)
% 
%pkfnd_inputs=[x y]
% 	X: The minimum brightness of a pixel that might be local maxima. (NOTE: Make it big and the code runs faster 			
%         but you might miss some particles.  Make it small and you'll get everything and it'll be slow.)
% 	Y: OPTIONAL if your data's noisy, (e.g. a single particle has multiple local maxima), then set this optional 			
%         keyword to a value slightly larger than the diameter of your blob.  if multiple peaks are found 			
%         within a radius of sz/2 then the code will keep only the brightest.  Also gets rid of all 				
%         peaks within sz of boundary
% 
% maxdisp(x):
% 	X: An estimate of the maximum distance that a particle would move in a single time interval.
% 	      maxdisp should be set to a value somewhat less than the mean spacing between the particles. As maxdisp 				
%         approaches the mean spacing the runtime will increase significantly. The function will produce an 			
%         error message: "Excessive Combinatorics!" if the run time would be too long, and the user should 			
%         respond by re-executing the function with a smaller value of maxdisp. Obviously, if the particles 			
%         being tracked are frequently moving as much as their mean separation in a single time step, this 			
%         function will not return acceptable trajectories.
%
    load([fpath 'header.mat']);
    imfnum=vid.nframes;
    time=(vid.ttb-vid.ttb(1))/1000; %s
    %bpass_inputs=str2num(get(handles.bpass,'string'));
    %pkfnd_inputs=str2num(get(handles.pk_find,'string'));
    frange=[num2str(frm_start) ' : ' num2str(frm_stop)];
    frange=str2num(frange);
    glimpse_ave=[];
    pk_master=[];
    counter=0;
    for findx=frange
        wawa=read_image('glimpse',fpath,findx,'');
        [m,n] = size(glimpse_ave);
        if m<3
            glimpse_ave=wawa;
        else
            glimpse_ave=glimpse_ave+wawa;
        end
        dum=wawa;
        dat=bpass(dum,bpass_inputs(1),bpass_inputs(2));
        pk=pkfnd(dat,pkfnd_inputs(1),pkfnd_inputs(2));
        pk=cntrd(dat,pk,15); %centroid refinement
        if isempty(pk)
            pk=[0 0 time(findx)];
        else
            pk=pk(:,1:2);
            pk(:,3)=time(findx);
        end
        pk_master=[pk_master;pk];
        counter=counter+1;
    end
    glimpse_ave=glimpse_ave/counter;
    %tracking--------------------------------------------------------
    param.mem=2;    %has to be in consecutive frames to be considered in the same trajectory
    param.good=4;   %didn't use because I don't know what "param.good" does
    param.dim=3;    %x y t (3D)
    param.quiet=1;  %no text
    %maxdisp=str2double(get(handles.max_disp,'string'));
    trajectory=track(pk_master,maxdisp,param);
    if isempty(trajectory)
        warning('no trajectories to analyze!')
        return;
    end
    %----------------------------------------------------------------
    %graph image #####################################
    cla;
    axis image;
    colormap(gray);
    imagesc(glimpse_ave,disp_scale);
    axis image;
    title('Choose brightest reference points');
    xlabel('x position (pixels)');
    ylabel('y position (pixels)');
    peaks.long=pk_master;
    tracks.long=trajectory;
    time_to_frames=unique([unique(pk_master(:,3),'rows') (frm_start:frm_stop)'],'rows');
    %time_to_frames(:,1)
    %average movement between skipped frames
    traj_ids=sort(unique(trajectory(:,4), 'rows'),1);
    [r,s]=size(traj_ids);
    next_likely_id=0;
    trajectory_ave=[];
    for i=1:r
        findx=find(trajectory(:,4)==traj_ids(i));
        trajectory_selected=trajectory(findx,:);
        [a,b]= size(trajectory_selected);
        findframes=[];
        for i=1:a
            findframes=[findframes;time_to_frames(find(time_to_frames(:,1)==trajectory_selected(i,3)),2)];
        end
        trajectory_selected_ave=[];
        for i=1:1:a-1
            findi=findframes(i);
            findi2=findframes(i+1);
            trajectory_selected_ave=[trajectory_selected_ave;trajectory_selected(i,:) findi];
            if findi2-findi > 1
                diff=findi2-findi;
                ave1=(trajectory_selected(i+1,1)-trajectory_selected(i,1))/diff;
                ave2=(trajectory_selected(i+1,2)-trajectory_selected(i,2))/diff;
                ave3=(trajectory_selected(i+1,3)-trajectory_selected(i,3))/diff;
                ave4=(trajectory_selected(i+1,4)-trajectory_selected(i,4))/diff;
                for j=1:diff-1
                    nextframe=findi+(((findi2-findi)/diff)*j);
                    nextpoint=[trajectory_selected(i,1)+ave1*j trajectory_selected(i,2)+ave2*j time_to_frames(nextframe-frm_start+1,1) trajectory_selected(i,4)+ave4*j nextframe]; 
                    trajectory_selected_ave=[trajectory_selected_ave;nextpoint];
                end
            end
            trajectory_selected_ave=[trajectory_selected_ave;trajectory_selected(i+1,:) findi2];
        end
        trajectory_selected=sortrows(unique(trajectory_selected_ave,'rows'),5);
        trajectory_ave=[trajectory_ave;trajectory_selected];
    end
    trajectory=trajectory_ave(:,1:4);
    %end averaging movement between skipped frames
    %select reference points
    drift_corr=[];
    drift_time_span=[];
    drift_dist_ave=[];
    drift_traj_ave=[];
    c=[];
    c(1:length(trajectory),1)=0;
    traj_times_all=unique([trajectory(:,3) c],'rows');
    selected_trajs=[];
    while true % until LMB or enter is pressed
        [xin yin button]=ginput(1);    %first select the trajectory of interest
        if(button==3)
            break;
        end
        %axes(handles.axes_image);
        selected=[xin yin];
        if isempty(selected)
            break;
            %end loop 
        end
        %drift_corr
        rv = func_return_nearest_TOIs2(trajectory, selected,'');
        drift_corr=[drift_corr;rv;rv];
        id_indx=rv(3);
        findx=find(trajectory(:,4)==id_indx);
        trajectory_selected=trajectory(findx,:);
        drift_time_span=[drift_time_span;trajectory_selected(:,3)];
        drift_time_span=unique(drift_time_span, 'rows');
        %drift_time_span
        [a,b]= size(drift_time_span);
        covered=(a/(frange(end)-frange(1)+1)*100);

        %print drift time span/frame range?
        %toprint=[num2str(covered) '% covered'];
        %set(handles.disp1,'string',toprint);
        %toprint=['Covered frames ' num2str(time_to_frames(find(time_to_frames(:,1)==drift_time_span(1,1)),2)) ' to ' num2str(time_to_frames(find(time_to_frames(:,1)==drift_time_span(end,1)),2))];
        %set(handles.disp2,'string',toprint);
        %num_selected=num_selected+1;
        if isempty(drift_traj_ave)
            drift_traj_ave=[trajectory_selected(:,1)-trajectory_selected(1,1) trajectory_selected(:,2)-trajectory_selected(1,2) trajectory_selected(:,3)];
            selected_trajs=unique([selected_trajs;id_indx],'rows');
            %add one to counter, later divide each time by
            %counter
            for j=1:length(drift_traj_ave)
                time_to_add=find(traj_times_all(:,1)==drift_traj_ave(j,3));
                traj_times_all(time_to_add,2)=traj_times_all(time_to_add,2)+1;
            end
        else
            %set up traj time matrix that counts the number of times a time
            %has been added to average it by that number later
            traj_times=trajectory_selected(:,3);
            [r,c]=size(traj_times);
            for i=1:r
                findave1=find(drift_traj_ave(:,3)==traj_times(i,1));
                if isempty(findave1) %drift ave doesnt contain this line of the selected traj
                    drift_traj_ave=[drift_traj_ave;trajectory_selected(i,1)-trajectory_selected(1,1) trajectory_selected(i,2)-trajectory_selected(1,2) trajectory_selected(i,3)];
                    %add one to counter, later divide each time by
                    %counter
                    selected_trajs=unique([selected_trajs;id_indx],'rows');
                    findave2=find(drift_traj_ave(:,3)==traj_times(i,1));
                    time_to_add=find(traj_times_all(:,1)==drift_traj_ave(findave2,3));
                    traj_times_all(time_to_add,2)=traj_times_all(time_to_add,2)+1;
                else
                    findave=drift_traj_ave(findave1,:);
                    findsel=find(trajectory_selected(:,3)==traj_times(i,1));
                    if isempty(findsel)
                        findsel=[trajectory_selected(1,1) trajectory_selected(1,2)];
                    else
                        findsel=trajectory_selected(findsel,:);
                    end
                    drift_traj_ave(findave1,:)=unique([findave(1,1)+findsel(1,1)-trajectory_selected(1,1) findave(1,2)+findsel(1,2)-trajectory_selected(1,2) drift_traj_ave(findave1,3)],'rows');
                    %make sure that trajectories are unique before
                    %adding
                    %to counter
                    if isempty(selected_trajs)
                        %add one to counter, later divide each time by
                        %counter
                        time_to_add=find(traj_times_all(:,1)==drift_traj_ave(findave1,3));
                        traj_times_all(time_to_add,2)=traj_times_all(time_to_add,2)+1;
                    else
                        if isempty(find(selected_trajs(:,1)==id_indx, 1))
                            %add one to counter, later divide each time by
                            %counter
                            time_to_add=find(traj_times_all(:,1)==drift_traj_ave(findave1,3));
                            traj_times_all(time_to_add,2)=traj_times_all(time_to_add,2)+1;
                        end
                    end
                end
            end
            selected_trajs=unique([selected_trajs;id_indx],'rows');
        end
    end
    %check for no selected points
    if isempty(drift_traj_ave)
       'no points selected!'
       return; 
    end
    %divide each displacement(by time) by the number of trajectories that were selected that
    %exist during this time
    counter1=1;
    for j=1:length(traj_times_all)
        if traj_times_all(j,2)~=0
            drift_traj_ave(counter1,:)=[drift_traj_ave(counter1,1)/traj_times_all(j,2) drift_traj_ave(counter1,2)/traj_times_all(j,2) drift_traj_ave(counter1,3)];
            counter1=counter1+1;
        end
    end
    drift_traj_ave=sortrows(unique(drift_traj_ave,'rows'),3);
    %will interpolate drift_traj so it makes better movies (less jumpy)
    drift_traj_ave_temp=drift_traj_ave;
    %convert all times to frames, replace in drift corr
    %interpolation function, averages drift between frame gaps
    gap_counter=1;
    finder=find(time_to_frames(:,1)==drift_traj_ave_temp(1,3));
    drift_traj_ave_temp(1,3)=time_to_frames(finder,2);
    drift_correction=drift_traj_ave_temp(1,:);
    for i=2:length(drift_traj_ave_temp)
       finder=find(time_to_frames(:,1)==drift_traj_ave_temp(i,3));
       frame=time_to_frames(finder,2);
       drift_traj_ave_temp(i,3)=frame;
       gap_counter=drift_traj_ave_temp(i,3)-drift_traj_ave_temp(i-1,3);
       if gap_counter>1
           x_drift=(drift_traj_ave_temp(i,1)-drift_traj_ave_temp(i-1,1))/gap_counter;
           y_drift=(drift_traj_ave_temp(i,2)-drift_traj_ave_temp(i-1,2))/gap_counter;
           frames=(drift_traj_ave_temp(i,3)-drift_traj_ave_temp(i-1,3))/gap_counter;
           for j=1:gap_counter
               drift_correction=[drift_correction;[drift_traj_ave_temp(i-1,1)+x_drift*j drift_traj_ave_temp(i-1,2)+y_drift*j drift_traj_ave_temp(i-1,3)+frames*j]];
           end
       else
           drift_correction=[drift_correction;drift_traj_ave_temp(i,:)];
       end
    end
    for i=2:length(drift_correction)-1
        if abs(drift_correction(i,1))+abs(drift_correction(i,2))==0
            drift_correction(i,1)=(drift_correction(i-1,1)+drift_correction(i+1,1))/2;
            drift_correction(i,2)=(drift_correction(i-1,2)+drift_correction(i+1,2))/2;
            drift_correction(i,3)=(drift_correction(i-1,3)+drift_correction(i+1,3))/2;
        end
    end
    rv=drift_correction;