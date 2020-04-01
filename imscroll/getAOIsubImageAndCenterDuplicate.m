function [subimage, newcenter] = getAOIsubImageAndCenterDuplicate(image, center, radius)
% Get the AOI sub image given the AOI center coordinate and AOI halfwidth.
% 
[ymax,xmax] = size(image);
edge(1,:) = round(center - radius + 0.5);
edge(2,:) = round(center + radius - 0.5);
y = edge(3):edge(4);
x = edge(1):edge(2);
newcenter = [radius+1, radius+1];
% 
% newcenter(2) = newcenter(2)-sum(y<1);
% y = y(y>=1);
% y = y(y < ymax);
% 
% newcenter(1) = newcenter(1)-sum(x<1);
% x = x(x >= 1);
% x = x(x < xmax);

subimage = image(y,x);

end
