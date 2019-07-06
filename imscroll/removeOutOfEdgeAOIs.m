function [shiftedXYout,aoiinfoout] = removeOutOfEdgeAOIs(shiftedXYin,aoiinfo,imageFileProperty)
xmax = imageFileProperty.width;
ymax = imageFileProperty.height;
aoiHalfWidth = aoiinfo(1,5)/2;
isInRangeX = (shiftedXYin(:,1,:) < xmax  - aoiHalfWidth) & (shiftedXYin(:,1,:) > 1 + aoiHalfWidth);
isInRangeY = (shiftedXYin(:,2,:) < ymax  - aoiHalfWidth) & (shiftedXYin(:,2,:) > 1 + aoiHalfWidth);
isRemoveAOI = any(~isInRangeX,3) | any(~isInRangeY,3);
shiftedXYout = shiftedXYin(~isRemoveAOI,:,:);
aoiinfoout = aoiinfo(~isRemoveAOI,:);
end