function pc=macavi_with_overlay_splitscale_glimpse_v2(gfolder,frames,flagg,frmrate,avifolder,frmave,info,boundaries,xory,minmax12,driftlist)
%
% function macavi_with_overlay_splitscale_glimpse_v2(imfold,frames,flagg,frmrate,avifolder,frmave,info,boundaries,xory,minmax12,driftlist)
%
% This function will return a movie after reading in images from one of 
% JC and LF files of  iccd data.  The user can take the output and play 
% it as a movie (e.g. movie(pc) ).  Uses image sequences saved in GLIMPSE
% format.
%
% gfolder == the alphanumeric for the path to the frames.  EX
%          imfold  ='D:\temp\larry\april_14_07\b16p106a_534\'
% frames == vector of images to be put into avi file
% flagg == logical variable.  If flagg ==1 then use images in the global
%           variable movframes(mrange,nrange,frmindx)
% frmrate== output frame rate for the avi (in frames per second)
% avifolder == folder in which avi will be placed
% After the movie (e.g. 'mov')is made, the user can make an avi file using:
%  movie2avi(mov,folder,'fps',30,'quality',100,'compression','none');
% frmave = the number of frames to average.  This will be a running ave
%        (careful not to exceed number of frames: hiindx only to maxfrm#-frmave)
% info == 'aoifits' structure made in the gui 'imscroll'. The 'info'
%        structure contains a list of aois selected within the 'imscroll'
%        gui, and boxes will be drawn around those aois in the avi that is
%        made
% boundaries == [x1 x2 y1 y2 xorysplit]  where x1 x2 y1 y2 define the
%         boundary of the entire image, and xorysplit defines the dividing
%         x or y boundary between the two image sections (choice of x or y
%         is specified by 'xory' variable.
% xory == 'x' or 'y' will specify whether the image is split by specifying
%         an x coordinate (vertical line) or a y coordinate (horizontal
%         line)
% minmax12 == [mn1 mx1 mn2 mx2]   defines the minimum and maximum display
%         intensities in fields one and two [ minimum1 maximum1 minimum2 maximum2]
% driftlist == Nx3 matrix [(frm #) (delta x) (delta y) ]
%              where N = # of frames in the glimpse file
%global movframes dum
% V2  added driftlist capability  Not yet tested 3/22/2011
mkavi='yes';

                                            % load the vid structure in the
                                            % header.mat file
eval(['load ' [gfolder 'header.mat'] ' -mat'])
dum =glimpse_image(gfolder,vid,1);           % just to get the proper frame size
[a b]=size(dum);
dum=uint32(zeros(a,b,frmave));                      % space to read in groups of frames that will be averaged
movieindx=1;
colormap(gray(256));
 fig=figure(10);                              % open figure:   'DoubleBuffer'used in avi example in 'Help' 
   set(fig,'DoubleBuffer','on');
%for inum = loindx : hiindx					% read in images to be averaged
for inum=frames
%      figure(1);surf(double(imread([imfold filenum],'tiff'))-50,...
%         'Edgecolor','none');camlight left;lighting phong;view([-25 80]);axis([0 100 0 100 0 25])

%      figure(1);surf(double(imread([imfold filenum],'tiff'))-50,'Facecolor','red',...
%         'Edgecolor','none');camlight left;lighting phong;view([-25 80]);axis([0 100 0 100 0 25])
%      figure(1);pcolor(double(imread([imfold tiff_name(inum)],'tiff'))-50 );caxis([5 35]);colorbar;shading flat
%    figure(1);image(imread([imfold tiff_name(inum)],'tiff') );colormap(gray(256));figure(1)
        if flagg==1
%        dum=movframes(:,:,inum);
        dum_display=imdivide(sum(movframes(:,:,inum:inum+frmave-1),3) ,frmave);      
        else
  
%        dum=imread([imfold tiff_name(inum)],'tiff') ;
        %dum=readstacked(imfold,inum:inum+frmave-1);
                                                % Read in one group of
                                                % frames to be averaged
        for rdindx=inum:inum+frmave-1
%        dum(:,:,rdindx-inum+1)=imread(imfold,'tif',rdindx);
        dum(:,:,rdindx-inum+1)=glimpse_image(gfolder,vid,rdindx);
 
        end
                                                % Now average the frames
        
        dum_display=imdivide(sum(dum,3) ,frmave);
        end
   
%    figure(3);imagesc(dum(:,1:300),dispscale);colormap(gray(256));axis('equal');axis('off');set(gcf,'color','white')
dum_display=double(dum_display);
dum_display=image_split_scale(dum_display,boundaries,xory,minmax12);


   figure(10);imagesc(rot90(dum_display,0),[0 255]);colormap(gray(256));axis equal;axis off
    
for indx=1:max(aoiinfo(:,6))     % Cycle through all aois
    XYshift=ShiftAOI(indx,inum,infoaoiinfo2,driftlist);   % indx=aoi index,  inum=frame number index
    draw_box(info.aoiinfo2(indx,3:4)+XYshift,(pixnum)/2,(pixnum)/2,'b');
end
%draw_aoifits_aois_no_numbers(info,[1 .7 0]);  % [0 .9 0] is green
%draw_aoifits_aois_no_numbers(info,'y');  % [0 .9 0] is green
 axis([boundaries(1:4)]); 
   
%  figure(10);imagesc(dum_display,[lolim hilim]);colormap(gray);axis equal;axis off
  %figure(10);imagesc(rot90(dum_display,0),[lolim hilim]);colormap(gray);axis equal;axis off

%  draw_aoifits_aois_no_numbers(info,'r');
%  draw_aoifits_aois_no_numbers(info,'y');

  pc(movieindx)=getframe(gca);                  % add the current figure to the movie
  % pc(movieindx)=im2frame(dum,gray(256));
  
   	movieindx=movieindx+1;
    if movieindx/20==round(movieindx/20)
        movieindx
    end
end                                                % End of for loop

if mkavi =='yes'
    sprintf('making an avi file \n')
   
    movie2avi(pc,avifolder,'fps',frmrate,'quality',100,'compression','none');
end
%caxis('auto')

