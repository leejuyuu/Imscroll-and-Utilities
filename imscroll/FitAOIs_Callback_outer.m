function FitAOIs_Callback_outer(hObject, eventdata, handles, varargin)
% hObject    handle to FitAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global argouts imageset folderpass %parenthandles

% Find out if user wants a fixed or moving aoi, startparm=1 for fixed, startparm=2 for moving
startparameter = get(handles.StartParameters,'Value');
if startparameter ~= 1
    error('Error in build_2d_mapstruc_aois_frms:\n    Moving AOI while gaussian fitting is not supported in this version.%s', '');
end

aoifits = create_AOIfits_Structure(handles);
outputName = get(handles.OutputFilename,'String');
imagePath = getImagePathFromHandles(handles);

imageFileProperty = getImageFileProperty(imagePath);

fitChoice = get(handles.FitChoice,'Value');
aoiProcessParameters = getAoiProcessParameters(handles);
if fitChoice == 5
    DataOutput2d = getAoiIntensityLinearInterp(imageFileProperty,handles.FitData,...
        aoiProcessParameters,handles.DriftList);
    aoifits.data=DataOutput2d.ImageData;
    aoifits.BackgroundData=DataOutput2d.BackgroundData;
elseif fitChoice == 1    
    isTrackAOI = logical(get(handles.TrackAOIs,'Value'));
    
    DataOutput2d = fitAoisTo2dGaussian(...
        handles.FitData,...
        aoiProcessParameters,...
        imageFileProperty,...
        isTrackAOI...
        );
    aoifits.data=DataOutput2d;
    aoifits.BackgroundData=[];
else
    error('the chosen fitting method isn''t supported in this version')
end


save([handles.dataDir.String, outputName],'aoifits')
handles.aoifits1=aoifits;                        % store our structure in the handles structure
handles.aoifits2=aoifits;
if get(handles.BackgroundAOIs,'Value')==1
    % Here if radio button depressed instructing us to store this fit or
    % integrated data into the handles.BackgroundAOIs member.  This will
    % ordinarilly be just a singe frame integration over control
    % (nontarget) AOI set
    set(handles.BackgroundAOIs,'Value',0);        % Reset radio button
    handles.BackgroundAOIsData=aoifits;
end
guidata(handles.FitAOIs,handles);

% Pass the handle to the
% main gui figure as input
% to the subgui plotargout

% Start a gui for display of the fit results
plotargout(handles.figure1)

end

