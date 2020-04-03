function removeEmptyAOIs(handles)
% Here to remove AOIs that do not contain a
% spot  case12
% Spots within radius distance

handles.PreAddition=handles.FitData;                % Store the present aoi set before removing some of them
% Pick Spots according to paramters set within
% the 'Auto Spot Picking' box
imagenum=get(handles.ImageNumber,'value');        % Retrieve the value of the slider
CurrentFrameRange=get(handles.FrameRange,'String');  % Fetch current frame range
% Set the frame range to current single value of image number from the slider
set(handles.FrameRange,'String',['[' num2str(imagenum) ']'])
CurrentSpotsPopup=get(handles.SpotsPopup,'Value');  % Fetch current value of SpotsPopup dropdown menu
CurrentSpotsButtonString=get(handles.SpotsButton,'String');
set(handles.SpotsPopup,'Value',2)          % Set to 'FrameRange'
% Now execute a detection of AllSpots
handles=FrameRange(handles);    % Invokes the Frame Range choice of finding AllSpots
% in just the current frame
set(handles.FrameRange,'String',CurrentFrameRange)  % Returns the editable text handles.FrameRange to prior string
set(handles.SpotsPopup,'Value',CurrentSpotsPopup);
set(handles.SpotsButton,'String',CurrentSpotsButtonString);
%SpotsButton_Callback(handles.SpotsButton, eventdata, handles)
%FramesPickSpots_Callback(handles.FramesPickSpots, eventdata, handles)

% Remove AOIs that do not contain a detected spot
% Now the AllSpots structure
% contains a list of all spots in the current
% frame.  We next want to remove all the current
% AOIs that do not contain one of these spots
%  AOISpotLanding(AOInum,radius,handles,aoiinfo2,radius_hys)
radius=str2num(get(handles.EditUniqueRadius,'String'));     % Use as max pixel distance to a spot.
% A spot must be this close to an AOI center
% for that AOI to  be retained
radius_hys = 1;     % A multiplicative constant not used here
aoiinfo2=handles.FitData;       % Contains list of current AOIs
% [framenumber ave x y pixnum aoinumber];
[rose col]=size(aoiinfo2);  % rose = number of AOIs currently
AOIspots=zeros(rose,2);     % We will denote the AOI spot number N
% as containing a spot by marking
% AOIspots(N,2) = 1

for indx=1:rose
    
    % Cycle through all the aois
    AOIspots(indx,:)=AOISpotLanding(aoiinfo2(indx,6),radius,handles,aoiinfo2,radius_hys);
    
end
% We have now found all the AOIs w/ and w/o spots and need
% to remove those AOIs without spots
% Keep only those rows i for which AOIspots(i,2) = 1
handles.FitData=handles.FitData(logical(AOIspots(:,2)),:);



handles.FitData=update_FitData_aoinum(handles.FitData);

%handles.Field2=[handles.FitData;handles.Field2];
%[rose2 col2]=size(handles.Field2);
%handles.Field2(:,6)=[1:rose2]';
%handles.FitData=handles.Field2;                     % Place the summed aoi sets also into current FitData
guidata(gcbo,handles);                              % Update the handle varialbes
slider1_Callback(handles.ImageNumber, eventdata, handles)   % And show the user the updated summed aoiset


end