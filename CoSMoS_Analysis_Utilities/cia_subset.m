function pc=cia_subset(cia,AOIList)
%
% function cia_subset(cia,AOIList)
%
% This function will output a cia array (from Intervals structure) 
% containing events only from the AOIs contained in the list AOIList.  
% The AOI numbers in the output cia will be re-numbered from 1 to
% length(AOIList).  This is for use in interval_single_v6 so we can easily
% display a random subset of the AOIs in a rastorgram just for clarity.
%
% see also cia_aoilist

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

aoiNum=length(AOIList);         % Number of AOIs in our output cia
ciaout=[];              % Output cia.  This will be slow, but it matters little here
for indx=1:aoiNum
    logik=cia(:,7)==AOIList(indx);  % Find all events for this AOI
    ciaSub=cia(logik,:);
    ciaSub(:,8)=ciaSub(:,7);
    ciaSub(:,7)=indx;
    ciaout=[ciaout
            ciaSub];          % Slow b/c we re-allocate memory in each looop
end
pc=ciaout;