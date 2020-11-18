function data = fitAoisTo2dGaussian(aoiinfo,...
                                  aoiProcessParameters,...
                                  imageFileProperty,...
                                  isTrackAOI)
% Fit the AOIs in the aoiinfo list to 2D gaussian function over a frame 
% range and return the fitted coefficients. 
% f(x, y) = amplitude * exp(-((x-x0).^2 + (y-y0).^2) / (2*sigma^2)) + offset
% 
% The major use case of this function is to get the x, y coordinates of 
% AOIs. This is used when updating to more precise coordinates or to track
% the AOIs.
%
% Input args:
%     aoiinfo: N x 6 array, the information of the aoi got from imscroll
%              handles.FitData. The columns correspond to 
%              [(framenumber when marked), frameAverage, x, y, aoiWidth, aoinumber]
%     aoiProcessParameters: struct with two fields
%         {
%         frameAverage: int, number of frames to average
%                       when processing image
%         frameRange: 1 x M int, the frame numbers the processing to
%                     iterate over
%         }
%     imageFileProperty: struct with 3 fields {
%         nFrame: the total number of frames in the image sequence
%         width: the image width (pixel)
%         height: the image height (pixel)
%         fileType: str, specify the image type, possible 'tiff' or 
%                   'glimpse'
%         filePath: str, the path to the image (tiff) or image directory 
%                   glimpse
%         gheader: the vid structure if the fileType is glimpse
%         }
%     isTrackAOI: bool, determine whether the user want to update the
%                 starting fitting parameter (x0, y0) after every frame 
%                 to the previous frame (true) or just use the aoiinfo as 
%                 the starting parameter (false)
%
% Output arg:
%     data: N*M x 8 array, the info from the fitted result of each frame
%           and each AOI. The AOI number changes faster then the frame
%           number when you go down the rows. The columns correspond to 
%           [aoi#, frame#, amplitude, x0, y0, sigma, offset, total intensity of AOI]
%
nAOI = length(aoiinfo(:, 1));
nFrame = length(aoiProcessParameters.frameRange);
frameAverage = aoiProcessParameters.frameAverage;

% Pre-Allocate space
tempData = zeros(nAOI, 8, nFrame);

for iFrame = 1:nFrame
    if mod(iFrame,10) == 0
        %indicate the current progress
        fprintf('processing frame %d\n',iFrame)
    end
    % Get the averaged image of this frame to process
    currentFrameNumber = aoiProcessParameters.frameRange(iFrame);
    currentFrameImage = getAveragedImage(...
        imageFileProperty,...
        currentFrameNumber,...
        frameAverage);
    
    for iAOI = 1:nAOI
        
        if isTrackAOI && iFrame ~= 1 && iFrame ~= 2
            % Use the coordinate from the fitted result in the last frame
            coord = tempData(iAOI,4:5,iFrame - 1);
        else
            % Use the coordinate pre-determined for all frame
            coord = aoiinfo(iAOI, 3:4);
        end
        
        aoiWidth = aoiinfo(iAOI, 5);
        
        try
        [currentAoiImage, aoi_origin] = getAOIsubImageAndCenterDuplicate(currentFrameImage, coord, aoiWidth/2);
        catch ME
            switch ME.identifier
                case 'MATLAB:badsubscript'
                    fprintf('Bad aoi: %d\n', iAOI)
                    return
                otherwise
                    rethrow(ME)
            end
        end
        startingCoeff = guessStartingParameters(double(currentAoiImage));
        
        % Fit the current aoi
        fittedCoeff = gauss2dfit(double(currentAoiImage),double(startingCoeff));
        
        % Assign the result to tempData
        sumIntensity = sum(currentAoiImage(:));
        % Shift the x, y coordinates from origin in AOI to origin at image
        fittedCoeff(2:3) = fittedCoeff(2:3) + aoi_origin';
        tempData(iAOI, 1, iFrame) = iAOI;
        tempData(iAOI, 2, iFrame) = currentFrameNumber;
        tempData(iAOI, 3:7, iFrame) = fittedCoeff(:);
        tempData(iAOI, 8, iFrame) = sumIntensity;
    end
end

% Pre-Allocate space
data = zeros(nAOI*nFrame, 8);

% ImageDataParallel(aoiindx,DataEntryIndx,FrmIndx)
% Reshaping data matrices for output
% The form ImageData and BackgroundData matrices was required to
% satisfy the parallel processing loop requirements for indexing

for frameindex=1:nFrame
    data((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=tempData(:,:,frameindex);
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