function SpotIntervals(hObject, eventdata, handles)
% hObject    handle to SpotIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Copy top of the 'DataOperation' callback to set some variables

% Use the aoifits1 to define the list of AOIs that we will process (find all landings near them)
% Use the aoifits2 to provide a single example of the frame range and time base for processing
% User should then load the full set of AOIS into aoifits1, and a single integrated trace into aoifits2
parenthandles = guidata(handles.parenthandles_fig);
aoifits=parenthandles.aoifits2;                 % Now have the current aoifits2 structure
% Get the aoinumber (saved when plotting in DisplayBottom)
%****aoinumber=handles.IntervalDataStructure.PresentTraceCellArray{1,2};
%****log1=aoifits.data(:,1)==aoinumber;              % Get sub aoifits for this
%****onedat=aoifits.data(log1,:);                    % one aoi = onedat
% [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
%PTCA{1,11}=[onedat(:,2) onedat(:,8)];           % This is the InputTrace in which we
% want to detect events (and is plotted on axes3)

%[aoifitsFile AOINum UpThreshold DownThreshold  mean  std  MeanStdFrms DataFrms  TimeBase IntervalArray...
% InputTrace DetrendedInputTrace BinaryInputTrace BinaryInputtraceDescription DetrendFrameRange]

PTCA=handles.IntervalDataStructure.PresentTraceCellArray;

%aoiinfo2=aoifits.aoiinfo2;      % Will be whatever is currently loaded into plotargout
aoiinfo2=parenthandles.aoifits1.aoiinfo2;      % Will be whatever is currently loaded into plotargout aoifits1
%  '[(framenumber when marked) ave x y pixnum aoinumber]'
aoivector=aoiinfo2(:,6);    % Vector of aoi numbers
[aoirose aoicol]=size(aoivector);
% First clear the exiting IntervalDataStructure
% (retain the .PresentTraceCellArray so we
% can keep the mean and std of one trace)

handles.IntervalDataStructure.AllTracesCellArray=cell(1,16);     % Cumulative data from all traces
handles.IntervalDataStructure.CumulativeIntervalArray=[];        % Just the interval list from all traces
% Cycle through all the aois listed in aoifits2

for aoiindx=1:max(aoirose,aoicol)
    
    
    aoinumber=aoivector(aoiindx);   % Current AOI
    %log1=aoifits.data(:,1)==aoinumber;
    %onedat=aoifits.data(log1,:);
    % [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
    
    %PTCA{1,11}=[onedat(:,2) onedat(:,8)];   % Place current Input Trace into PTCA
    %PTCA{1,12}=[PTCA{1,11}(:,1) PTCA{1,11}(:,2)-min( PTCA{1,11}(:,2) )];     % Place Input Trace also into DetrendedTrace entry of PTCA
    % Note that we subract off and bring baseline close to zero
    
    %*****copy from Data Operation case 15 above to process one aoi
    radius=handles.SpotProximityRadius;           % Proximity of spot to AOI center
    radius_hys=str2num(get(handles.UpThreshold,'String'));
    % Bin01Trace = [(frm #)  0/1]
    Bin01Trace=AOISpotLanding(aoinumber,radius,parenthandles,parenthandles.aoifits1.aoiinfo2,radius_hys);          % 1/0 binary trace of spot landings
    
    % w/in radius of the AOI center.  Uses the FrameRange from AllSpots.FrameRange itself
    
    MultipleFrameIntervals=PTCA{1,8};   % Use the DataFrameRange [N x 2] from the PTCA
    
    % Take binary trace and find all the intervals in it
    %0.5=upThresh  0.5=downThresh  1=minUP  1=minDown
    dat=Find_Landings_MultipleFrameIntervals(Bin01Trace,MultipleFrameIntervals,0.5,0.5,1,1);
    % dat:  structure w/ members 'BinaryInputTrace' and  'IntervalData'
    % dat.BinaryInputTrace = [0/1/2/3   (frm #)   0/1]
    
    % figure(24);plot(Bin01Trace(:,1),Bin01Trace(:,2),'b');           % Plot the binary trace
    
    %axes(handles.axes2);
    %plot(Bin01Trace(:,1),Bin01Trace(:,2),'b')
    
    % Next section just from 'Find Intervals case 10 above
    tb=PTCA{1,9};                         %Time base array
    % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
    % where InputTrace here includes only sections searched for events
    %Also mark the first interval 0s or 1s with -2 or -3 respectively,
    %and the ending interval 0s or 1s with +2 or +3 respectivley
    PTCA{1,2}=aoinumber;               % Place aoinumber into proper cell array entry
    PTCA{1,13}=dat.BinaryInputTrace;   % [(-2,-3,0,1,2,3)  frm#  0,1]
    % Place binary trace into input trace, b/c a raw integrated input trace MAY not by present
    PTCA{1,11}=[PTCA{1,13}(:,2) PTCA{1,13}(:,3)];
    PTCA{1,12}=[PTCA{1,11}(:,1) PTCA{1,11}(:,2)-min( PTCA{1,11}(:,2) )];     % Place Input Trace also into DetrendedTrace entry of PTCA
    % Note that we subtract off and bring baseline close to zero
    % keyboard
    if isempty(tb)
        sprintf('User must input time base file prior to building IntervalData array')
    else
        % add the deltaTime value to the 5th column to the IntervalData
        % array, and subtract mean from event height
        %IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
        
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) dat.IntervalData(:,5)-PTCA{1,5}];
        
        % Next get the average intensity of the detrended
        % trace for each event (for column 6 of IntervalData)
        % And AOI number (for column 7)
        
        [IDrose IDcol]=size(dat.IntervalData);
        % Need to provide values for columns 5:7 of
        % dat.IntervalData(:,5:7)=[ (delta time)  (interval ave intehsity)  AOI#]
        
        
        %InputTrace=PTCA{1,12};          % Detrended trace used here (same definition from above)
        
        RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here
        aveint=[];
        
        
        for IDindx=1:IDrose             % Cycle through rows of dat.IntervalData to supply  (ave interval int)
            
            
            startframe=dat.IntervalData(IDindx,2);
            rawstartframe=find(RawInputTrace(:,1)==startframe);
            
            endframe=dat.IntervalData(IDindx,3);
            rawendframe=find(RawInputTrace(:,1)==endframe);
            % Use ave of raw input trace w/ mean
            % subtracted off
            
            aveint=[aveint;sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}];   % Subtract mean off the uncorrected trace to get pulse height
            
        end
        %   ************  Correct problem with one frame events right at gap in the aquisition sequence (between Glimpse boxes)
        %medianOneFrame=median(diff(tb));    % median value of one frame duration
        %PTCA_1_10_dum=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];
        
        %logikal=dat.IntervalData(:,3)==dat.IntervalData(:,2);       % Single frame duration: need this in case one frame events begins
        % just before Glimpse sequence goes off to take other image (can
        % artificially lengthen the event length
        %PTCA_1_10_dum(logikal,5)=medianOneFrame;
        %PTCA{1,10}=PTCA_1_10_dum;                       %  Same form as cia array
        
        % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
        % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m
        medianOneFrame=median(diff(tb));    % median value of one frame duration
        PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame aveint  PTCA{1,2}*ones(IDrose,1)];
        %   ****************
        % PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];
        % Altered at lines 1515 1616 1881 3141
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
        guidata(gcbo,handles);
        axes(handles.axes3)
        hold off
        
        plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        % Overlay the binary information showing interval detection
        % onto the axes3 plot and figure(25)
        OverlayBinaryPlot(PTCA,handles.axes3,25);
        % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
        
        HistogramIntervalData(handles.IntervalDataStructure.PresentTraceCellArray{1,10},handles.axes2,1,BinNumber);
        % Display the cumulative interval histogram for high=1 states
        
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
            
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
    end
    % Check for manual limits on the bottom axis
    if (get(handles.AxisScale,'Value')) ==0
        figure(25);axis auto
        axes(handles.axes3);axis auto
    else
        figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
        axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
    end
    
    % Change X limits if toggle is depressed
    if get(handles.CustomXLimitsBottomToggle,'Value')==1
        % Toggle depressed: use x limits from matrix
        set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
    else
        % auto scaling used above: store the auto scaled x axis limits
        handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
    end
    guidata(gcbo,handles);
    
    %****set(handles.ButtonChoice,'Value',11);
    % ***End of copy from DataOperation case 15 (find intervals for one AOI)
    
    % ***Now copy from Data Operation case 13 (add trace to Interval Data Structure)
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    ATCA=handles.IntervalDataStructure.AllTracesCellArray;
    % append the present trace cell array to the AllTraceCellArray
    [rose col]=size(ATCA);
    if (rose==1) & isempty(ATCA{1,10})
        % Here if this is the first nonempty entry to ATCA
        ATCA=PTCA;
    else
        ATCA=[ATCA;PTCA];
    end
    
    % Now put all the interval data together into one Nx5 array
    cumul=[];
    [rose col]=size(ATCA);
    
    for indx=1:rose
        cumul=[cumul;ATCA{indx,10}];
    end
    
    % Update the handles structure
    handles.IntervalDataStructure.AllTracesCellArray=ATCA;
    handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
    % Now turn off the expand X axis  toggle
    set(handles.CustomXLimitsBottomToggle,'Value',0);
    CustomXLimitsBottomToggle_Callback(handles.CustomXLimitsBottomToggle, eventdata, handles)
    guidata(gcbo,handles);
    set(handles.ButtonChoice,'Value',6);
    
    aoiindx
    % *****End of copy from Data Operation case 13 (Add trace to Interval Data Structure)
    
end             % End of cycling through the AOIs
% Add the AllSpots structure (for saving) used for finding intervals
% AllSpots structure defined in imscroll gui
handles.IntervalDataStructure.AllSpots=FreeAllSpotsMemory(parenthandles.AllSpots);
% Add the proximity radius used in computing the intervals to the
% AllSpots structure (so it will be there when saved)
handles.IntervalDataStructure.AllSpots.ProximityRadius=handles.SpotProximityRadius;

guidata(gcbo,handles);

