function new_aoiinfo2 = removeEmptyOrSpotAOIs(aoiinfo2, AllSpots, radius, choice)
% Remove AOIs from 'aoiinfo2' that do not contain a spot in 'AllSpots' within a 
% circular region defined by 'radius'.
% 
% choice: str, 'empty' or 'spot'

% A multiplicative constant not important here
radius_hys = 1;

nAOIs = length(aoiinfo2(:, 1));

% This third index is for the frame number.
xyCoord = zeros(nAOIs, 2, 1);
xyCoord(:, :, 1) = aoiinfo2(:, 3:4);

AOIspots = zeros(nAOIs,2);  % [frameNumber, containSpot(0 or 1)];
for iAOI = 1:nAOIs
    AOIspots(iAOI,:)=AOISpotLanding2(aoiinfo2(iAOI,6),radius,radius_hys, AllSpots, ...
        AllSpots, xyCoord);
end
isContainSpot = logical(AOIspots(:,2));
switch choice
    case 'empty'
        % Select those AOIs that contain spot.
        new_aoiinfo2 = aoiinfo2(isContainSpot,:);
    case 'spot'
        % Select those AOIs that do not contain spot.
        new_aoiinfo2 = aoiinfo2(~isContainSpot,:);
    otherwise
        error('Error in removeEmptyOrSpotAOIs:\nChoice can only be "empty" or "spot"%s', '');
end
new_aoiinfo2 = update_FitData_aoinum(new_aoiinfo2);
end