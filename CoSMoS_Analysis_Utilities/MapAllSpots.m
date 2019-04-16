function pc=MapAllSpots(AllSpots,fignum)
%
% function MapAllSpots(AllSpots,fignum)
%
% Will use the AllSpots structure saved from imscroll gui and highlight the
% location of all the spots that appeared.
 frms=AllSpots.FrameVector;      % List of frames over which we found spots
 figure(fignum);
 hold on
 [rose col]=size(frms);

 for indx=1:max(rose,col)                           % Cycle through frame range
    
     spotnum=AllSpots.AllSpotsCells{indx,2}; % number of spots found in the current frame
     xy=AllSpots.AllSpotsCells{indx,1}(1:spotnum,:);    % xy pairs of spots in current frame
     plot(xy(:,1),xy(:,2),'y.');                % Plot the spots for current frame
 end
 hold off