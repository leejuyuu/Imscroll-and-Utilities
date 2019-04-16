function [xypos button]=func_gbox

% func_gbox - 
%
% this function lets a user hold down left mouse button and draw a rectangle
% over a plot.  The return variable is [xypos button], 
% where xypos = [xmin xmax ymin ymax]
%
% example:
%
% [xypos button]=func_gbox;
%
% author jc june2008

%k = waitforbuttonpress;

[xin yin button]=ginput(1);
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

xypos=[min(x) max(x) min(y) max(y)];

%if button==1
%    line(x,y,'color','r')            % draw box around selected region
%end


