function pc=compare_AOIs(AOI1, AOI2)
% function compare_AOIs(AOI1, AOI2)
%
% Will compare the lists of AOIs and output any AOIs in AOI1 that do not
% appear in AOI2.
%
% AOI1== vector list of AOIs
% AOI2 == vector list of AOIs
%
% output.notin2==vector list of AOIs that appear in AOI1 but not in AOI2
% output.notin1==vector list of AOIs that appear in AOI2 but not in AOI1
%
% Copyright 2017 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

pc.notin2=[];
for indx=1:length(AOI1)
    if (any(AOI1(indx)==AOI2))
    else
        pc.notin2=[pc.notin2;AOI1(indx)];
    end
end

pc.notin1=[];
for indx=1:length(AOI2)
    if (any(AOI2(indx)==AOI1))
    else
        pc.notin1=[pc.notin1;AOI2(indx)];
    end
end
