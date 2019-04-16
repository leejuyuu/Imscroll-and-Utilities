function pc=draw_aois_restrict(aoilist,aoiinfo2,frame,aoisize,driftlist,ListNotList,BoxColor)
%
% function pc=draw_aois_restrict(aoilist,aoiinfo2,frame,aoisize,driftlist,ListNotList,BoxColor)
%
% This function will use the list of aois in aoiinfo2, reposition all aois
% at their location for frame 'frame' (using data in driftlist)and draw at
% those locations with the box side specified in 'aoisize'
%
% aoilist == vector list of AOI numbers that will be drawn at locations
%          cited in the aoiinfo2 array
% aoiinfo2 == array that is saved from imscroll.  The aoiinfo2 matrix is of
%          the form:
%   [ (frame #)  (frame average) (x coordinate=column) (ycoordinate=row)...
%                            (aoi side dimension in pixels)  (aoi number) ]
% frame == common frame number to be used in positioning all the aois
% aoisize==  side (in pixels) dimension of the aoi box to be drawn
% driftlist ==[(frame #) (x shift from last frame) (y shift from last frm)]
% ListNotList== 1 => draw the AOIs listed in the aoilist
%                 else (equals anything but 1), 
%                 draw all the AOIs not listed in the aoilist
% BoxColor == e.g.  'r', 'k', 'b', 'c' ...etc
%
% Function will output the aoiinfo2 matrix showing the xy locations of the aois
% at their shifted positions.
listlength=length(aoilist);
aoiinfo2_aoilist=[];        % will contain an aoiinfo2 type matrix containing
                            % just those AOIs from the input 'aoiinfo2' that
                            % DO appear in the aoilist
aoiinfo2_Not_aoilist=[];    % will contain an aoiinfo2 type matrix containing
                            % just those AOIs from the input 'aoiinfo2' that
                            % DO NOT appear in the aoilist
            
[rose col]=size(aoiinfo2);
    % First we shift the xy coordinates in the aoiinfo2 matrix
for indx=1:rose
     XYshift=ShiftAOI(indx,frame,aoiinfo2,driftlist);
     aoiinfo2(indx,3:4)=aoiinfo2(indx,3:4)+XYshift;
end
     % Next we split the aoiinfo2 into aoiinfo2_aoilist and aoiinfo2_Not_aoilist
for indx=1:rose
    if any(aoiinfo2(indx,6)==aoilist)   % True if this AOI number from aoiinfo2
                                        % appears in the aoilist
                % If true, add aoiinfo2 row to the aoiinfo2_aoilist matrix
        aoiinfo2_aoilist=[aoiinfo2_aoilist;aoiinfo2(indx,:)];
    else
                % If not true, add aoiinfo2 row to the aoiinfo2_Not_aoilist matrix
        aoiinfo2_Not_aoilist=[aoiinfo2_Not_aoilist;aoiinfo2(indx,:)];
    end
end
        % We have now split the original aoiinfo2 matrix into two. the
        % aoiinof2_aoilist contains data from AOIs list in 'aoilist', and
        % aoiinfo2_Not_aoilist contains data from AOIs not listed in 'aoilist'
   % Next, we draw the AOIs from aoiinfo2_aoilist (ListNotList=1) or we
   % draw the AOIs fro aoiinfo2_Not_aoilist (ListNotList~=1)
if ListNotList==1
        % Here to draw AOIs from aoiinfo2_sublist
    aoiinfo2_drawlist=aoiinfo2_aoilist;
else
    aoiinfo2_drawlist=aoiinfo2_Not_aoilist;
end
                % Now draw the chosen AOI subset (those AOIs in the aoilist
                % (ListNotList=1) or those not in the list (ListNotList~=1) 
[rose col]=size(aoiinfo2_drawlist);
for indx=1:rose
                        % Cycle through for each aoi
   
                        % Draw the box for the shifted aoi location 
                        % Use draw_box_v1 to draw at pixel boundaries
   draw_box(aoiinfo2_drawlist(indx,3:4)+XYshift,(aoisize)/2,...
                              (aoisize)/2,BoxColor);
   
end
pc.aoiinfo2_aoilist=aoiinfo2_aoilist;
pc.aoiinfo2_Not_aoilist=aoiinfo2_Not_aoilist;


