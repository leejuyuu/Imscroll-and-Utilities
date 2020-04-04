function new_aoiinfo2 = removeEmptyAOIs(aoiinfo2, AllSpots, radius)
% Here to remove AOIs that do not contain a
% spot  case12
% Spots within radius distance


% Remove AOIs that do not contain a detected spot
% Now the AllSpots structure
% contains a list of all spots in the current
% frame.  We next want to remove all the current
% AOIs that do not contain one of these spots

     % Use as max pixel distance to a spot.
% A spot must be this close to an AOI center
% for that AOI to  be retained
radius_hys = 1;     % A multiplicative constant not used here

% [framenumber ave x y pixnum aoinumber];

nAOIs = length(aoiinfo2(:, 1));
AOIspots = zeros(nAOIs,2);     % We will denote the AOI spot number N
% as containing a spot by marking
% AOIspots(N,2) = 1

% This third index is for the frame number.
xyCoord = zeros(nAOIs, 2, 1);
xyCoord(:, :, 1) = aoiinfo2(:, 3:4);
for iAOI = 1:nAOIs
    
    % Cycle through all the aois
    AOIspots(iAOI,:)=AOISpotLanding2(aoiinfo2(iAOI,6),radius,radius_hys, AllSpots, ...
        AllSpots, xyCoord);
    
end
% We have now found all the AOIs w/ and w/o spots and need
% to remove those AOIs without spots
% Keep only those rows i for which AOIspots(i,2) = 1
new_aoiinfo2 = aoiinfo2(logical(AOIspots(:,2)),:);
new_aoiinfo2 = update_FitData_aoinum(new_aoiinfo2);




end