function mapout = getInverseMap(map)
mapout = -map;
v = cross(map(1,:),map(2,:));
mapout(5:6) = v(1:2);
mapout(1) = map(4);
mapout(4) = map(1);
mapout = mapout/v(3);
end
