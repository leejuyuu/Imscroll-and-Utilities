function mapAOIsOut(handles)
% map the present AOI set to
% field #2 e.g. x1
% -> x2
% (output is x2y2  coordinates)
% Save the current AOI locations before mapping
aoiinfo2=handles.FitData;
eval(['save ' handles.dataDir.String 'premapAOIs.dat' ' aoiinfo2']);
fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
% Stored as [mxx21 mxy21 bx;
%            myx21 myy21 by]
% handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]

nowpts=[handles.FitData(:,3) handles.FitData(:,4)];
% Now map to the x2

handles.FitData(:,3)=mappingfunc(fitparmvector(1,:),nowpts);
%handles.FitData(:,3)=handles.FitData(:,3)*fitparmvector(1) + fitparmvector(2);
% Now map to the y2
handles.FitData(:,4)=mappingfunc(fitparmvector(2,:),nowpts);
%handles.FitData(:,4)=handles.FitData(:,4)*fitparmvector(3) + fitparmvector(4);
if get(handles.ProximityMappingToggle,'Value')==1
    % Here to instead use proximity mapping method
    [rosenow colnow]=size(nowpts);
    mappednow=zeros(rosenow,2);
    for indx=1:rosenow
        % Use 15 nearest points for mapping to field2
        mappednow(indx,:)=proximity_mapping_v1(handles.MappingPoints,nowpts(indx,:),15,fitparmvector,2);
    end
    handles.FitData(:,3:4)=mappednow;
end


% only keep points with pixel indices >=1
log=(handles.FitData(:,3)>=1 ) & (handles.FitData(:,4) >=1) & (handles.FitData(:,3) <=1024) & (handles.FitData(:,4) <=1024);
handles.FitData=handles.FitData(log,:);
handles.FitData=update_FitData_aoinum(handles.FitData);
%     guidata(gcbo,handles)
% Save the current AOI locations after mapping
aoiinfo2=handles.FitData;
eval(['save ' handles.dataDir.String 'postmapAOIs.dat aoiinfo2']);
set(handles.ButtonChoice,'Value',7);           % Make ButtonChoice menu ready to reload mapped AOIs
set(handles.InputParms,'String','postmapAOIs.dat')     % Put name of postmap AOI file into editable text field (ready to re-load)


end