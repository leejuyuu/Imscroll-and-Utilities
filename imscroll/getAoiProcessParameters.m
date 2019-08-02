function aoiProcessParameters = getAoiProcessParameters(handles)

aoiProcessParameters.frameRange = eval([get(handles.FrameRange,'String') ';']);
aoiProcessParameters.frameAverage = round(str2double(get(handles.FrameAve,'String')));




end