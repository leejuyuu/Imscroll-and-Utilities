function pc=draw_AllSpots(AllSpots,frame,driftlist)
%
% function draw_AllSpots(AllSpots,frame,driftlist)
%
% Will draw all the spots detected by the auto spot picker in imscroll and
% stored in the AllSpots structure.  The spots will be drawn at their
% location in the specified 'frame' using the driftlist to compensate for
% drift
%
% AllSpots == structure stored by imscroll following auto spot picking of
%            fluorescent spots throughout a specified framed range
% frame == all the detected spots will be drift corrected and plotted at
%         their xy location in this 'frame'.  
% driftlist = [frm#  deltax   deltay  (glimpse time)] driftlist that will
%           be used to correct locations of the detected spots 
frms=AllSpots.FrameVector;      % List of frames over which we found spots
        
[rose col]=size(frms);
        
 hold on       
for indx=1:max(rose,col)                           % Cycle through frame range
    XYshift=[0 0];                  % initialize aoi shift due to drift
                    
                    
                                    % Fake aoiinfo structure (one entry) specification frame being the indx (i.e. frame for spot detection)  
    %aoiinfo=[indx 1 0 0 5 1];
    aoiinfo=[frms(indx) 1 0 0 5 1];
                                    % Get the xy shift that moves each spot detected in frame=indx to the current frame=imval   
    XYshift=ShiftAOI(1,frame,aoiinfo,driftlist);
                 
            
    spotnum=AllSpots.AllSpotsCells{indx,2}; % number of spots found in the current frame
    xy=AllSpots.AllSpotsCells{indx,1}(1:spotnum,:);     % xy pairs of spots in current frame
       
    xy(:,1)=xy(:,1)+XYshift(1);     % Offset all the x coordinates for the detected spots
    xy(:,2)=xy(:,2)+XYshift(2);     % Offset all the y coordinates for the detected spots
    plot(xy(:,1),xy(:,2),'ro','MarkerSize',3.0);                % Plot the spots for current frame
end

hold off
pc=1;

