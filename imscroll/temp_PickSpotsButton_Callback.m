% --- Executes on button press in PickSpotsButton.
function PickSpotsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PickSpotsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                                    % Check ranges of NoiseDiameter,
                                    % SpotDiameter and SpotBrightness

if handles.NoiseDiameter<=0
    handles.NoiseDiameter=1;
    set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter))
end
if handles.SpotDiameter<=0
    handles.SpotDiameter=1;
    set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter))
end
if handles.SpotBrightness<=0
    handles.SpotBrightness=1;
    set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness))
end
FitDataHold = handles.FitData;
handles.FitData=[];                 % Clear the screen of AOIs by setting handles.Fitdata=[]
guidata(gcbo,handles)               % and showing the image
slider1_Callback(handles.ImageNumber, eventdata, handles)
handles.FitData=FitDataHold;        % Replace the handles.FitData and show the image with
                                    % the proper AOIs
guidata(gcbo,handles)

ave=round(str2double(get(handles.FrameAve,'String')));  % Averaging number
pixnum=str2double(get(handles.PixelNumber,'String'));   % Pixel number
imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
avefrm=getframes_v1(handles);                       % Fetch the current frame(s) displayes
if get(handles.SpotsPopup,'Value')==8
    % Here if the spots are to be picked from images that have been background
    % subtracted according to handles.BackgroundChoice
    if any(get(handles.BackgroundChoice,'Value')==[2 3])
                        % Here to use rolling ball background (subtract off background) 
           
        avefrm=avefrm-rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
    elseif any(get(handles.BackgroundChoice,'Value')==[4 5])
                        % Here to use Danny's newer background subtraction(subtract off background) 
            
        avefrm=avefrm-bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
    end
end
[frmrose frmcol]=size(avefrm);                  % [ysize xsize]
xlow=1;xhigh=frmcol;ylow=1;yhigh=frmrose;         % Initialize frame limits
if get(handles.Magnify,'Value')==1                  % Check whether the image magnified (restrct range for finding spots)  
    limitsxy=eval( get(handles.MagRangeYX,'String') );  % Get the limits of the magnified region
                                                   % [xlow xhi ylow yhi]
    xlow=limitsxy(1);xhigh=limitsxy(2);            % Define frame limits as those of 
    ylow=limitsxy(3);yhigh=limitsxy(4);            % the magnified region

end
                                    % Find the spots

dat=bpass(double(avefrm(ylow:yhigh,xlow:xhigh)),handles.NoiseDiameter,handles.SpotDiameter);
pk=pkfnd(dat,handles.SpotBrightness,handles.SpotDiameter);
pk=cntrd(dat,pk,handles.SpotDiameter+2);

[aoirose aoicol]=size(pk);
                    % Put the aois into our handles structure handles.FitData = [frm#  ave  x   y  pixnum  aoinum]
if aoirose~=0       % If there are spots, put them into handles.FitData and draw them
    pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
    pk(:,2)=pk(:,2)+ylow-1;
    handles.FitData=[imagenum*ones(aoirose,1) ave*ones(aoirose,1) pk(:,1) pk(:,2) pixnum*ones(aoirose,1) [1:aoirose]'];
                    % Draw the aois
    for indx=1:aoirose
        draw_box_v1(handles.FitData(indx,3:4),(pixnum)/2,(pixnum)/2,'b');
    end
    
end
                        %draw_aois(handles.FitData,imagenum,pixnum,handles.DriftList);
guidata(gcbo,handles)
