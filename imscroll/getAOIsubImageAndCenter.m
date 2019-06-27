function [subimage, newcenter] = getAOIsubImageAndCenter(image, center, radius)
[ymax,xmax] = size(image);
edge(1,:) = center - radius;
edge(2,:) = center + radius;
y = edge(3):edge(4);
x = edge(1):edge(2);
newcenter = [radius+1, radius+1];

    y = y(y>=1);
    newcenter(2) = newcenter(2)-sum(y<1);

    y = y(y < ymax);

    x = x(x >= 1);
    newcenter(1) = newcenter(1)-sum(x<1);

    x = x(x < xmax);


subimage = image(y,x);

end
