function [subimage, neworigin] = getAOIsubImageAndCenterDuplicate(image, center, aoiHalfwidth)
% Get the AOI sub image given the AOI center coordinate and AOI halfwidth.
% 
% Input args: 
%     image: M x N array, the image
%     center: 1 x 2 float, the center coordinate of the aoi
%     aoiHalfwidth: fload, the half width of the aoi
%
% Output args:
%     subimage: (2 * aoiHalfwidth) x (2 * aoiHalfwidth) image array
%     neworigin: 1 x 2 int, the indices of the top-left pixel in the 
%                subimage relative to the original image

[ymax,xmax] = size(image);
edge(1,:) = round(center - aoiHalfwidth + 0.5);
edge(2,:) = round(center + aoiHalfwidth - 0.5);
yRange = edge(3):edge(4);
xRange = edge(1):edge(2);
neworigin = edge(1, :);

subimage = image(yRange,xRange);
end
