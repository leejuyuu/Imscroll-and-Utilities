function background = getAOIBackgroundIntensity(currentFrameImage,xycoord,aoiWidth)

[AOIimage, newcenter] = getAOIsubImageAndCenter(currentFrameImage, xycoord, aoiWidth+4);
mask = true(size(AOIimage));
[ymax,xmax] = size(AOIimage);
innerLength = aoiWidth;

innerEdges(1,:) = newcenter - innerLength;
innerEdges(2,:) = newcenter + innerLength;

y = innerEdges(3):innerEdges(4);
x = innerEdges(1):innerEdges(2);

y = y(y>=1);
y = y(y < ymax);

x = x(x < xmax);
mask(y,x) = false;
background = median(AOIimage(mask))*aoiWidth^2;
end