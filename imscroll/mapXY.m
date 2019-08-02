function XYout = mapXY(XY,map)
XY1 = [XY, ones(length(XY(:,1)),1)];
XYout = XY1*map';
end
