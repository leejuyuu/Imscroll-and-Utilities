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
% preallocate the arrays for
% storing spot information
AllSpots.AllSpotsCells=cell(nFrames,3);  % Will be a cell array {N,3} N=# of frames computed, and
% AllSpots{m,1}= [x y] list of spots, {m,2}= # of spots in list, {m,3}= frame#

AllSpots.AllSpotsCellsDescription='{m,1}= [x y] list of spots in frm m, {m,2}= # of spots in list, {m,3}= frame#]';
AllSpots.FrameVector=frameRange;         % Vector of frames whose spots are stored in AllSpotsCells
AllSpots.Parameters=[ noiseDiameter, spotDiameter, spotBrightness];
AllSpots.ParametersDescripton='[NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots';

% AllSpots.aoiinfo2=handles.FitData;       % List of AOIs user has chosen
% AllSpots.aoiinfo2Description='[frm#  ave  x  y  pixnum  aoi#]';
[xlow,xhigh,ylow,yhigh] = region{:};
for i = 1:length(frameRange)          % Cycle through all frames, finding the spots
    iFrame = frameRange(i);
    if iFrame/500==round(iFrame/500)
        fprintf('processing frame %d\n', iFrame);
    end
    
    currentFrameImage = getAveragedImage(imageFileProperty,iFrame,frameAverage);
    % Fetch the current frame (appropriately averaged)
    % If the handles.BackgroundChoice is set to show the user
    % a background-subtracted image, then use that background
    % subtracted image in which to find spots.
    
    
    dat=bpass(double(currentFrameImage(ylow:yhigh,xlow:xhigh)),noiseDiameter,spotDiameter);
    pk=pkfnd(dat,spotBrightness,spotDiameter);
    pk=cntrd(dat,pk,spotDiameter+2);        % This is our list of spots in this frame FrameRange(frmindx)
    
    [nAOIs,~]=size(pk);
    
    if nAOIs~=0       % If there are spots
        pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
        pk(:,2)=pk(:,2)+ylow-1;
        
        AllSpots.AllSpotsCells{i,1}=pk;
        AllSpots.AllSpotsCells{i,2}=nAOIs;                         % Number of detected spots we store
        AllSpots.AllSpotsCells{i,3}=iFrame;            % Frame number
        
    else
        AllSpots.AllSpotsCells{i,1}=[];
        AllSpots.AllSpotsCells{i,2}=0;                         % Number of detected spots we store
        AllSpots.AllSpotsCells{i,3}=iFrame;            % Frame number
    end
    
end


fprintf('process finished\n');
pc = AllSpots;
% pc=FreeAllSpotsMemory(AllSpots);                        % Output structure containing cell array with spot record