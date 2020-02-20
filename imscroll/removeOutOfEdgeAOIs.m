function [shiftedXYout,aoiinfoout, isGoodAOI] = removeOutOfEdgeAOIs(shiftedXYin,aoiinfo,imageFileProperty)
xmax = imageFileProperty.height;
ymax = imageFileProperty.width;
aoiHalfWidth = aoiinfo(1,5)/2;
isInRangeX = (shiftedXYin(:,1,:) < xmax  - aoiHalfWidth) & (shiftedXYin(:,1,:) > 1 + aoiHalfWidth);
isInRangeY = (shiftedXYin(:,2,:) < ymax  - aoiHalfWidth) & (shiftedXYin(:,2,:) > 1 + aoiHalfWidth);
isRemoveAOI = any(~isInRangeX,3) | any(~isInRangeY,3);
isGoodAOI = ~isRemoveAOI;
shiftedXYout = shiftedXYin(~isRemoveAOI,:,:);
aoiinfoout = aoiinfo(~isRemoveAOI,:);
end