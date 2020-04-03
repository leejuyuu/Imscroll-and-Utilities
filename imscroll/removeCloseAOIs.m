function new_aoiinfo2 = removeCloseAOIs(aoiinfo2, radius)
%
% new_aoiinfo2 = Remove_Close_AOIs_v1(aoiinfo2, radius)
% 
% Remove AOIs that are too close to any other AOI in the given 'aoiinfo2'
% array, and return a new, mutually far away enough 'new_aoiinfo2' array.
% Too close here means that the distance between 2 AOIs is smaller than or
% equal to the 'radius' argument. So no two aois will be closer than a 
% distance specified by 'radius'.
% 
% Input args:
%     aoiinfo2: N x 6 array, the handles.FitData array, with each row being
%               data for each AOI, and has the column structure as follows.
%               [frame#, frameAverage, xCoord, yCoord, aoiWidth, aoi#]
%
%     radius: float (unit: pixel), any AOI that has one or more other AOIs 
%             present in the circular region specified by the radius and the 
%             coordinate of this AOI, will be removed.
%
% Output arg:
%     new_aoiinfo2: M x 6 array, the aoiinfo2 array with AOIs that are
%                   clustered to each other removed. (M <= N)
 
% Copyright 2020 Tzu-Yu Lee, National Taiwan University.
% Copyright 2015 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

xyCoords = aoiinfo2(:, 3:4);
nAOIs = length(aoiinfo2(:, 1));

isFarFromOthers = false(nAOIs, 1);
for iAOI = 1:nAOIs
    % Test each aoi against all the others
    thisAoiCoord=xyCoords(iAOI,:);
    allOtherAoiCoords = xyCoords;
    allOtherAoiCoords(iAOI, :) = [];
    % Distance of test aoi to all others
    distance = sqrt( (allOtherAoiCoords(:,1)-thisAoiCoord(1)).^2 +...
        (allOtherAoiCoords(:,2)-thisAoiCoord(2)).^2 );
    isFarFromOthers(iAOI) = all(distance > radius);
end

new_aoiinfo2 = aoiinfo2(isFarFromOthers, :);
new_aoiinfo2(:, 6) = 1:length(new_aoiinfo2(:, 6));

