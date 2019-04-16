function mouseMove (object, eventdata)
%
% Used to print out the cursor position in the figure title.  
% User needs to type the following line in the command mode to invoke
% this function:
% >> (gcf, 'WindowButtonMotionFcn', @mouseMove);
C = get (gca, 'CurrentPoint');
C(1,1)=round(C(1,1)*10)/10;         % Only register to w/in 0.1 units
C(1,2)=round(C(1,2)*10)/10;
title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
