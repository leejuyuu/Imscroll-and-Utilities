function pc=gauss2d_mapstruc2d_temp_bypass(parenthandles,imageFileProperty)
%
% function gauss2d_mapstruc2d_v2(mapstruc_cell,parenthandles,handles)
%
% This function will apply a gaussian fit to aois in a series of images.
% The aois and frames will be specified in the mapstruc structure
% images == a m x n x numb array of input images
% mapstruc_cell == structure array each element of which specifies:
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc_cell
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc_cell
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == the folder location of the images to be read
%
% parenthandles == the handles arrary from the top level gui
% handles == the handles array from the GUI
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



fitChoice = get(parenthandles.FitChoice,'Value');
aoiProcessParameters = getAoiProcessParameters(parenthandles);
if fitChoice == 5
    pc = getAoiIntensityLinearInterp(imageFileProperty,parenthandles.FitData,...
        aoiProcessParameters,parenthandles.DriftList);
elseif fitChoice == 1    
    isTrackAOI = logical(get(parenthandles.TrackAOIs,'Value'));
    if get(parenthandles.BackgroundChoice,'Value') ~= 1
        error('background choice is not supported in this version')
    end
    aoiinfo = parenthandles.FitData;
    
    nAOI = length(aoiinfo(:, 1));
    nFrame = length(aoiProcessParameters.frameRange);
    
    % Pre-Allocate space
    ImageDataParallel = zeros(nAOI, 8, nFrame);
    BackgroundDataParallel = zeros(nAOI, 8, nFrame);
    
    frameAverage = aoiProcessParameters.frameAverage;
    
    %Now loop through the remaining frames
    for framemapindx=1:nFrame
        if framemapindx/10==round(framemapindx/10)
            framemapindx
        end
        % Get the averaged image of this frame to process
        currentFrameNumber = aoiProcessParameters.frameRange(framemapindx);
        
        currentfrm = getAveragedImage(...
            imageFileProperty,...
            currentFrameNumber,...
            frameAverage);
        for aoiindx2=1:nAOI   % Loop through all the aois for this frame
            
            if isTrackAOI && framemapindx ~= 1 && framemapindx ~= 2
                coord = ImageDataParallel(aoiindx2,4:5,framemapindx - 1);
            else
                coord = aoiinfo(aoiindx2, 3:4);
            end
            
            pixnum = aoiinfo(aoiindx2, 5);
            [currentaoi, aoi_origin] = getAOIsubImageAndCenterDuplicate(currentfrm, coord, pixnum/2);

            inputarg0 = guessStartingParameters(double(currentaoi));
            
            % Now fit the current aoi
            outarg=gauss2dfit(double(currentaoi),double(inputarg0));            
            
            % ImageDataParallel: [aoi#     frm#       amp    xo    yo    sigma  offset (int inten)]
            sumIntensity = sum(currentaoi(:));
            % Shift the x, y coordinates from origin in AOI to origin at image
            outarg(2:3) = outarg(2:3) + aoi_origin';
            ImageDataParallel(aoiindx2, 1, framemapindx) = aoiindx2;
            ImageDataParallel(aoiindx2, 2, framemapindx) = currentFrameNumber;
            ImageDataParallel(aoiindx2, 3:7, framemapindx) = outarg(:);
            ImageDataParallel(aoiindx2, 8, framemapindx) = sumIntensity;
            
        end
    end
    
    % Pre-Allocate space
    pc.ImageData = zeros(nAOI*nFrame, 8);
    pc.BackgroundData = zeros(nAOI*nFrame, 8);
    
    % ImageDataParallel(aoiindx,DataEntryIndx,FrmIndx)
    % Reshaping data matrices for output
    % The form ImageData and BackgroundData matrices was required to
    % satisfy the parallel processing loop requirements for indexing
    
    for frameindex=1:nFrame
        pc.ImageData((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=ImageDataParallel(:,:,frameindex);
        pc.BackgroundData((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=BackgroundDataParallel(:,:,frameindex);
    end
else
    
    error('the chosen fitting method isn''t supported in this version')
end
end

function startParams = guessStartingParameters(aoiImage)
% Set the starting parameters for 2D gaussian fitting
%
% Input arg:
%     aoiImage: N x N double array, the image of the AOI at a certain frame,
%               N is the width of the AOI
% Return:
%     startParams: 1 x 5 double array, corresponding to the 5 fitting 
%                  parameters of the 2D gaussian
%                  [amplitude xzero yzero sigma offset]
%
aoiWidth = length(aoiImage(:, 1));
maxIntensity = max(aoiImage(:));
meanIntensity = mean(mean(aoiImage));
startParams = [...
    maxIntensity-meanIntensity,...  % amplitude
    aoiWidth/2,...  % xzero
    aoiWidth/2,...  % yzero
    aoiWidth/4,...  % sigma
    meanIntensity,...  % offset
    ];
end

