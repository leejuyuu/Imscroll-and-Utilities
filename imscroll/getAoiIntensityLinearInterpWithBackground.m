function pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,driftList)
%
% function getAoiIntensityLinearInterp(mapstruc_cell,parenthandles)
%
% 
%
%  The function will make use of repeated applications of gauss2dfit.m

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
...............................................................................
    
% tiffObj = TIFFStack(imageFileProperty.filePath);
% warning('off','last')
nAOIs = length(aoiinfo(:,1));

aoiWidth = aoiinfo(1,5);
frameAverage = aoiProcessParameters.frameAverage;
frameRange = aoiProcessParameters.frameRange;
nFrames = length(frameRange);
shiftedXY = batchShitfAOI(aoiinfo(:,[3 4]),aoiinfo(1,1),...
        frameRange,driftList);

intXY = round(shiftedXY);
% Pre-Allocate space
Data = zeros(nAOIs,8,nFrames);
intensity = zeros(nAOIs,nFrames);
backgroundIntensity = zeros(nAOIs,nFrames);
for iFrame = 1:nFrames
        
    if mod(iFrame,10) == 0
        %indicate the current progress
        fprintf('processing frame %d\n',iFrame)
    end
    
    % Get the next averaged frame to process
%     currentFrameImage = uint32(sum(uint32(tiffObj(:,:,iFrame:iFrame+frameAverage-1)),3))/frameAverage;
    currentFrameImage = getAveragedImage(imageFileProperty,iFrame,frameAverage);
    for iAOI = 1:nAOIs   % Loop through all the aois for this frame
        
        intensity(iAOI,iFrame) = double(linear_AOI_interpolation2(...
            currentFrameImage,shiftedXY(iAOI,:,iFrame),aoiWidth/2));
        backgroundIntensity(iAOI,iFrame) = getAOIBackgroundIntensity(currentFrameImage,intXY(iAOI,:,iFrame),aoiWidth);
        Data(iAOI,:,iFrame)=[iAOI,iFrame,frameAverage,shiftedXY(iAOI,:,iFrame),aoiWidth, 0,...
            intensity(iAOI,iFrame) - backgroundIntensity(iAOI,iFrame)];
        
    end             %END of for loop aoiindx2
   
end           % end of for loop framemapindx


% Reshaping data matrices for output
% The form ImageData and BackgroundData matrices was required to
% satisfy the parallel processing loop requirements for indexing
pc.ImageData = zeros(nAOIs*nFrames,8);
for frameindex=1:nFrames
    pc.ImageData((frameindex-1)*nAOIs+1:(frameindex-1)*nAOIs+nAOIs,:)=Data(:,:,frameindex);
end
pc.BackgroundTrace =backgroundIntensity;
pc.beforeBackground = intensity;
% delete(tiffObj);
% warning('on','last')
end
 