function background = getAOIBackgroundIntensity(currentFrameImage,xycoord,aoiWidth)

[AOIimage, newcenter] = getAOIsubImageAndCenter(currentFrameImage, xycoord, aoiWidth+4);
mask = true(size(AOIimage));
innerLength = aoiWidth;

innerEdges(1,:) = newcenter - innerLength;
innerEdges(2,:) = newcenter + innerLength;

mask(innerEdges(3):innerEdges(4),...
    innerEdges(1):innerEdges(2)) = false;
background = median(AOIimage(mask))*aoiWidth^2;
end