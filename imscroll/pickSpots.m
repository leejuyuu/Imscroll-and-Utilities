function spotCoords = pickSpots(image, spotPickingParam, region)
% function spotCoords = pickSpots(image, spotPickingParam, region)
%
% Pick spots on an region of image given a set of spotPickingParam. Return the
% xy coordinates of the spots.
%
% Input args:
%     image: 2D numeric array
%     spotPickingParam: struct with the fields:
%         noiseDiameter: double, image structure smaller than this number is noise
%         spotDiameter: double, image structure larger than this number is not spots
%         spotBrightness: double, image peaks larger than this value are spots
%     region: 1x4 cell, each value is the boundary of a subimage:
%             {xlow, xhigh, ylow, yhigh}
%
% Output args:
%     spotCoords: N x 2 double, each row is the coordinate of a spot, with the
%                 first column being the x and the second column being y.

    noiseDiameter = spotPickingParam.noiseDiameter;
    spotDiameter  = spotPickingParam.spotDiameter;
    spotBrightness = spotPickingParam.spotBightness;
    [xlow,xhigh,ylow,yhigh] = region{:};
    croppedImage = double(image(ylow:yhigh,xlow:xhigh));
    % The spot picking is worked on a bandpassed image
    filteredImage = bpass(croppedImage, noiseDiameter, spotDiameter);
    spotCoords = pkfnd(filteredImage, spotBrightness, spotDiameter);
    spotCoords = cntrd(filteredImage, spotCoords, spotDiameter+2);
    
    [nAOIs, ~] = size(spotCoords);
    % If there are spots, correct coordinates for case where we used a smaller
    % region than the full image
    if nAOIs
        spotCoords(:,1) = spotCoords(:,1) + xlow - 1;
        spotCoords(:,2) = spotCoords(:,2) + ylow - 1;
    end
end

