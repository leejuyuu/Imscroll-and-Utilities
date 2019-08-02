function region = setProcessingImageRegionFromHandles(handles,imageFileProperty)
xlow=1;
xhigh=imageFileProperty.width;
ylow=1;
yhigh=imageFileProperty.height;
% Initialize frame limits
if get(handles.Magnify,'Value')==1                  % Check whether the image magnified (restrct range for finding spots)
    limitsxy=eval( get(handles.MagRangeYX,'String') );  % Get the limits of the magnified region
    % [xlow xhi ylow yhi]
    xlow=limitsxy(1);xhigh=limitsxy(2);            % Define frame limits as those of
    ylow=limitsxy(3);yhigh=limitsxy(4);            % the magnified region
    
end
region = {xlow,xhigh,ylow,yhigh};
end
