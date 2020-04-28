function pc=FindAllSpots(imageFileProperty,region,aoiProcessParameters,spotPickingParameters)
%
%  function FindAllSpots(handles,maxnum)
% gfolder,frmrange,frmlimits,NoiseDiameter,SpotDiameter,SpotBrightness
% Will use spot picking algorithm to find all the spots in each frame
% defined by the frmrange.
% handles == handles structure of the calling program ( imscroll() )
% maxnum == maximum # of spots in each frame (for preallocating arrays:
%       too high means you have too many spots, nonspecific interactions or
%       some other problem)

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


frameRange = aoiProcessParameters.frameRange;
frameAverage = aoiProcessParameters.frameAverage;
noiseDiameter = spotPickingParameters.noiseDiameter;
spotDiameter  = spotPickingParameters.spotDiameter;
spotBrightness = spotPickingParameters.spotBightness;

nFrames = length(frameRange);
AllSpots.AllSpotsCells=cell(nFrames,3);  % Will be a cell array {N,3} N=# of frames computed, and
% AllSpots{m,1}= [x y] list of spots, {m,2}= # of spots in list, {m,3}= frame#

AllSpots.AllSpotsCellsDescription='{m,1}= [x y] list of spots in frm m, {m,2}= # of spots in list, {m,3}= frame#]';
AllSpots.FrameVector=frameRange;         % Vector of frames whose spots are stored in AllSpotsCells
AllSpots.Parameters=[ noiseDiameter, spotDiameter, spotBrightness];
AllSpots.ParametersDescripton='[NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots';

for i = 1:length(frameRange)
    iFrame = frameRange(i);
    if ~mod(iFrame, 500)
        fprintf('processing frame %d\n', iFrame);
    end
    
    currentFrameImage = getAveragedImage(imageFileProperty,iFrame,frameAverage);
    pk = pickSpots(currentFrameImage, spotPickingParameters, region);
    
    [nAOIs,~]=size(pk);
    AllSpots.AllSpotsCells{i,1}=pk;
    AllSpots.AllSpotsCells{i,2}=nAOIs;
    AllSpots.AllSpotsCells{i,3}=iFrame;
end


fprintf('process finished\n');
pc = AllSpots;
end

