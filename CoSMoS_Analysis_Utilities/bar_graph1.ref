function pc=bar_graph(xLower,xUpper,y,color,fignum)
%
% function bar_graph(xLower, xUpper, y, color, fignum)
%
% This function will create a bar graph with variable width bars.  The user
% specified the lower and upper edges of each bar in the vectors xLower and
% xUpper respectively, as well as the height of each bar in the vector y.
% The length of xLower, xUpper and y must all be the same.
%
% xLower ==vector of x coordinates specifying the lower edge of all bars
% xUpper ==vector of x coordinates specifying the upper edge of all bars
% y == vector of y coordinates specifying the height of all bars
% color== alphanumeric specifying the bar color, e.g. 'b', 'r', 'k' etc
% fignum == figure number in which the bar graph will appear.

figure(fignum);
for indx=1:length(y)
    patch([xLower(indx) xLower(indx) xUpper(indx) xUpper(indx)],[0 y(indx) y(indx) 0],color);
end
