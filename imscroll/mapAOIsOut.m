function mapAOIsOut(handles, outfield)
% map the present AOI set to
% field #2 e.g. x1
% -> x2
% (output is x2y2  coordinates)

isProxMap = logical(get(handles.ProximityMappingToggle,'Value'));

% Save the current AOI locations before mapping
aoiinfo2=handles.FitData;
save([handles.dataDir.String, 'premapAOIs.dat'], 'aoiinfo2');
fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
% Stored as [mxx21 mxy21 bx;
%            myx21 myy21 by]
% handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]

currentCoords = handles.FitData(:, 3:4);

% Now map to the x2
if isProxMap
    % Use proximity mapping method
    [nAOIs, ~] = size(currentCoords);
    proxMappedCoords = zeros(nAOIs,2);
    for iAOI = 1:nAOIs
        % Use 15 nearest points for mapping to field2
        proxMappedCoords(iAOI,:)=proximity_mapping_v1(handles.MappingPoints,currentCoords(iAOI,:),15,fitparmvector,outfield);
    end
    handles.FitData(:, 3:4) = proxMappedCoords;
else
    % Use normal mapping method
    if outfield == 1
       fitparmvector = inverseMapMatrix(fitparmvector); 
    end
    handles.FitData(:, 3:4) = mapXY(currentCoords, fitparmvector);
end


% only keep points with pixel indices >=1
log=(handles.FitData(:,3)>=1 ) & (handles.FitData(:,4) >=1) & (handles.FitData(:,3) <=1024) & (handles.FitData(:,4) <=1024);
handles.FitData=handles.FitData(log,:);
handles.FitData=update_FitData_aoinum(handles.FitData);
%     guidata(gcbo,handles)
% Save the current AOI locations after mapping
aoiinfo2=handles.FitData;
save([handles.dataDir.String, 'postmapAOIs.dat'], 'aoiinfo2');
set(handles.ButtonChoice,'Value',7);           % Make ButtonChoice menu ready to reload mapped AOIs
set(handles.InputParms,'String','postmapAOIs.dat')     % Put name of postmap AOI file into editable text field (ready to re-load)


end