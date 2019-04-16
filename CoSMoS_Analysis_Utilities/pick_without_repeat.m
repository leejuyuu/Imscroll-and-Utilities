function pc=pick_without_repeat(AOIlist, PickNumber)
%
%function pick_without_repeat(AOIlist, PickNumber)
%
% Will output a list of AOI numbers randomly chosen from the 'AOIlist'.
% without repeating any AOI number in the list.  For Joerg.
%
% AOIlist == 1D vector listing all the AOI numbers we will choose from
% PickNumber == number of AOIs we will receive in the output list

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.


if PickNumber>length(AOIlist)       % Number of AOIs in list too small
    error('PickNumber exceeds number of AOIs')
end
[rose col]=size(AOIlist);
if col>rose
    AOIlist=AOIlist';
end

tbl=[AOIlist ones(length(AOIlist),1)];		% [(aoi #)    (probability )]
samp=[];				% variable to hold the list of chosen AOIs
tbldum=tbl;			% Dummy table (we will modify it in the loop)
for indx=1:PickNumber
aoidum=probability_steps(tbldum,1);	 	% Pick one AOI number
samp=[samp;aoidum];		% Store that AOI number
logik=tbldum(:,1)==aoidum;			% Find that AOI number in our table
tbldum(find(logik),:)=[];			% Remove that AOI choice from the table
end
pc=samp;

