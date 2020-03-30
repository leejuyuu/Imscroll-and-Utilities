function FitAOIs_Callback_outer(hObject, eventdata, handles, varargin)
% hObject    handle to FitAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global argouts imageset folderpass %parenthandles
aoifits = create_AOIfits_Structure(handles);
outputName = get(handles.OutputFilename,'String');
imagePath = getImagePathFromHandles(handles)

imageFileProperty = getImageFileProperty(imagePath);
% Build a 2D mapstruc to direct data processing
mapstruc2d = build_2d_mapstruc_aois_frms(handles);
DataOutput2d=gauss2d_mapstruc2d_temp_bypass(mapstruc2d,handles,imageFileProperty); % Process the data (integrate, fit etc)
% V.2 is parallel processing

argoutsImageData=DataOutput2d.ImageData;
argoutsBackgroundData=DataOutput2d.BackgroundData;


% Start a gui for display of the fit results
% argouts=[ aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
% Save the data after each aoi is processed
% First assign the ImageData


aoifits.data=argoutsImageData;
aoifits.BackgroundData=argoutsBackgroundData;
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
%parenthandles=handles;
% Pass the handle to the
% main gui figure as input
% to the subgui plotargout

plotargout(handles.figure1)
