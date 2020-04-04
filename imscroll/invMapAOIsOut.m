function invMapAOIsOut(handles)
% Invert the map: go from e.g. x2 -> x1
% output is x1y1 coordinates
% B9p148
%
% Save the current AOI locations before mapping
aoiinfo2=handles.FitData;
eval(['save ' handles.dataDir.String 'premapAOIs.dat' ' aoiinfo2']);
fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
% Stored as [mxx21 mxy21 bx;
%            myx21 myy21 by]
za=fitparmvector(1,1);zb=fitparmvector(1,2);zc=fitparmvector(1,3);
zd=fitparmvector(2,1);ze=fitparmvector(2,2);zf=fitparmvector(2,3);
denom=1/(za*ze-zb*zd);
invmapmat=denom*[ze -zb (zb*zf-zc*ze) ; -zd za (zd*zc-zf*za)]; % b9p148 inverse matrix

% handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]
nowpts=[handles.FitData(:,3) handles.FitData(:,4)];
% Now map to the x1
handles.FitData(:,3)=mappingfunc(invmapmat(1,:),nowpts);
% Now map to the y1
handles.FitData(:,4)=mappingfunc(invmapmat(2,:),nowpts);

if get(handles.ProximityMappingToggle,'Value')==1
    % Here to instead use proximity mapping method
    [rosenow colnow]=size(nowpts);
    mappednow=zeros(rosenow,2);
    for indx=1:rosenow
        % Use 15 nearest points for mapping to field1
        mappednow(indx,:)=proximity_mapping_v1(handles.MappingPoints,nowpts(indx,:),15,fitparmvector,1);
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
set(handles.InputParms,'String','postmapAOIs.dat')     % Put name of postmap AOI file into editable text fi

end