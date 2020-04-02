function pc = fitAoisTo2dGaussian(aoiinfo,...
                                  aoiProcessParameters,...
                                  imageFileProperty,...
                                  isTrackAOI)
nAOI = length(aoiinfo(:, 1));
nFrame = length(aoiProcessParameters.frameRange);

% Pre-Allocate space
ImageDataParallel = zeros(nAOI, 8, nFrame);

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
pc = zeros(nAOI*nFrame, 8);

% ImageDataParallel(aoiindx,DataEntryIndx,FrmIndx)
% Reshaping data matrices for output
% The form ImageData and BackgroundData matrices was required to
% satisfy the parallel processing loop requirements for indexing

for frameindex=1:nFrame
    pc((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=ImageDataParallel(:,:,frameindex);
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