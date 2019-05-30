function intensity=linear_AOI_interpolation2(currentFrameImage,xycenter,aoiHalfWidth)
%
% function linear_AOI_interpolation(frm,xycenter,radius)
%
% This function will integrate an aoi specified by the center xy 
% coordinates of the aoi (xycenter) and the aoi size (radius = 1/2 the
% length of one side).  When the aoi overlaps only a fraction of a 
% particular pixel, the integration will include that same fraction of
% the pixel value in the output sum.
%
% frm == image frame that contains the aoi that will be integrated
% xycenter  ==  [xcoordinate ycoordinate]  the x and y coordinates of the 
%            aoi center (integral numbers specify the center of a pixel,
%            half integers specify the edge of a pixel)
% radius  ==  when an aoi is m x m pixels in dimensions, the radius is
%            defined as m/2, or half the length (in pixels) of one side of
%            the aoi.  e.g. a 6 x 6 pixel has a radius of 3 and a 7 x 7 aoi
%            has a radius of 3.5

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
aoiX = xycenter(1);
aoiY = xycenter(2);

% Define a range of pixels that more than encompases the entire
% aoi.  We will integrate only over this limited pixel range.
xRange = [aoiX-aoiHalfWidth, aoiX+aoiHalfWidth];
yRange = [aoiY-aoiHalfWidth, aoiY+aoiHalfWidth];

xIntRange = round(xRange);
yIntRange = round(yRange);

aoiImage = double(currentFrameImage(yIntRange(1):yIntRange(2),xIntRange(1):xIntRange(2)));
mask = ones(size(aoiImage));

mask(:,1) = mask(:,1)*(xIntRange(1)+0.5-xRange(1));
mask(:,end) = mask(:,end)*(xRange(2)-xIntRange(2)+0.5);
mask(1,:) = mask(1,:)*(yIntRange(1)+0.5-yRange(1));
mask(end,:) = mask(end,:)*(yRange(2)-yIntRange(2)+0.5);
maskedImage = mask.*aoiImage;
intensity = sum(maskedImage(:));
    
end
