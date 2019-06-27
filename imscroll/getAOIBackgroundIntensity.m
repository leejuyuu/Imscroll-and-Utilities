function background = getAOIBackgroundIntensity(currentFrameImage,xycoord,aoiWidth)

bounds = size(currentFrameImage); %[ymax,xmax]
mask = logical(currentFrameImage*0);
innerLength = aoiWidth;
outerLength = aoiWidth+4;
outerEdges(1,:) = xycoord - outerLength;
outerEdges(2,:) = xycoord + outerLength;
innerEdges(1,:) = xycoord - innerLength;
innerEdges(2,:) = xycoord + innerLength;
for i = 1:2
    outerEdges(:,i) = bound(outerEdges(:,i),bounds(3-i),1);
    innerEdges(:,i) = bound(outerEdges(:,i),bounds(3-i),1);
end

mask(outerEdges(3):outerEdges(4),...
    outerEdges(1):outerEdges(2)) = true;
mask(innerEdges(3):innerEdges(4),...
    innerEdges(1):innerEdges(2)) = true;
background = median(currentFrameImage(mask))*aoiWidth^2;
end