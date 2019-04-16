function pc=cia_aoilist(cia)
%
% function cia_aoilist(cia)
%
% Will return a vector list of the AOI numbers that appear within the cia.
% Ths cia is derived from imscroll gui within the Intervals structure.
% i.e. cia==Intervals.CumulativeIntervalsArray.  When we edit the cia using
% e.g. events_per_aoi_v5 (to limit the number of maximum possible events)
% some AOIs may be removed so the cia may no longer contain all AOI
% numbers (hence the need for this function).
%cia ==
%  (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI# 
%
% See also cia_subset

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

mxAOI=max(cia(:,7));
%mxAOI=max(cia(:,1));
pc=[];
for indx=1:mxAOI
    if any(indx==cia(:,7))
    %if any(indx==cia(:,1))
        % Here if the the AOI number==indx is appears in the cia 
        pc=[pc;indx];
    end
end