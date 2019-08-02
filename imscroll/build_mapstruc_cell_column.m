function mapstruc_cell_column = build_mapstruc_cell_column(oneAoiinf,startparm,folder,folderuse,handles)
%
% function build_mapstruc_cell_column(aoiinf,startparm,folder,folderuse)
%
% Will assemble the mapstruc structure needed to direct the fitting
% routine gauss2d_mapstruc.m  Each of the arguements can be arrays
% whose rows will be successive entries into the mapstruc structure.
% If an input arguement has but a single row (e.g. likely for 'folder'),
% that row will be repeated for each element of the output mapstruc.
%
% The output is a cell array of structures refering to a single aoi.
% Each structure contains information for processing one frame.  The 
% form of the structure is
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell_column(n).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source

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


% Initialize the structure
% oneAoiinf has row number = number of fitted frames
[nFrame, ~]=size(oneAoiinf);
mapstruc_cell_column = cell(nFrame,1);
mapstruc_cell_column(:) = {struct(...
    'startparm',startparm,...
    'folder',folder,...
    'folderuse',folderuse...
    )};
if startparm == 2
    % == 2 for moving aois, in which case we will shift the xy coordinates
    % using the handles.DriftList table
    frameRange = oneAoiinf(:,1)';
    for iFrame = frameRange
        
        isEntryEqualiFrame=(iFrame==oneAoiinf(:,1));
        oneAoiinf(isEntryEqualiFrame,3:4)=oneAoiinf(isEntryEqualiFrame,3:4)+...
            ShiftAOI(oneAoiinf(1,6),iFrame,handles.FitData,handles.DriftList);
    end
end

for iFrame = 1:nFrame
    mapstruc_cell_column{iFrame}.aoiinf = oneAoiinf(iFrame,:);
end

end
 