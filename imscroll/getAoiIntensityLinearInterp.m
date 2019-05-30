function pc = getAoiIntensityLinearInterp(mapstruc_cell,imageFileProperty)
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
    
pixnum = mapstruc_cell{1,1}.aoiinf(5);
[nFrames, nAOI] = size(mapstruc_cell); 
FrameAverage = mapstruc_cell{1,1}.aoiinf(1,2);
% Pre-Allocate space
Data = zeros(nAOI,8,nFrames);
for iFrame = 1:nFrames
        
    if mod(iFrame,10) == 0
        %indicate the current progress
        fprintf('processing frame %d\n',iFrame)
    end
    % Get the next averaged frame to process
    currentFrameImage = getAveragedImage(imageFileProperty,iFrame,FrameAverage);
    for iAOI = 1:nAOI   % Loop through all the aois for this frame
        shiftedx=mapstruc_cell{iFrame,iAOI}.aoiinf(3);
        shiftedy=mapstruc_cell{iFrame,iAOI}.aoiinf(4);
        
        Data(iAOI,:,iFrame)=[iAOI, mapstruc_cell{iFrame,iAOI}.aoiinf(1:5), 0,...
            double(linear_AOI_interpolation2(currentFrameImage,[shiftedx shiftedy],pixnum/2))];
        
    end             %END of for loop aoiindx2
   
end           % end of for loop framemapindx


% Reshaping data matrices for output
% The form ImageData and BackgroundData matrices was required to
% satisfy the parallel processing loop requirements for indexing
pc.ImageData = zeros(nAOI*nFrames,8);
for frameindex=1:nFrames
    pc.ImageData((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=Data(:,:,frameindex);
end
pc.BackgroundData = pc.ImageData;
end
 