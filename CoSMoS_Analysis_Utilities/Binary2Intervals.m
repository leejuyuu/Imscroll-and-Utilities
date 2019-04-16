function pc=Binary2Intervals(fp_results,aoiinfo2,fp_images,fpfn_Intervals)
%
% function Binary2Intervals(fp_results,aoiinfo2,fp_images,fpfn_Intervals)
%
% This function will use a binary input trace of form [ (frm#)  0/1] to
% produce an output Intervals structure.  The binary input is from e.g. the
% gui_spot_model program of Alex+DougT, and the Intervals structure is more
% commonly output by the imscroll gui when used to find co-localized
% landing events.
%
% fp_results == file path to the 'results' directory that is output from
%           the 'gui_spots_model' program.  The 'results' directory
%           contains one file for each processed AOI.  That file is of
%           format [(frame#)  (class Spot prob)  (class NoSpot prob)].
%           This program will turn each AOI data set into a trace of the
%           form:
%           [(frame number)  0/1]  Binary input trace encoding the
%         co-localization state of a substrate molecule.  0 => substrate is 
%         NOT co-localized with a fluorescent-labeled binding species, while 
%         1 => substrate IS NOT co-localized with a fluorescent-labeled 
%         binding species.  This program will then use those traces to 
%         create the 'Intervals' structure for output
% aoiinfo2 == contains a listing of the AOI coordinates, of the form
%         [frm#  ave  x  y  pixnum  aoi#]
% fp_images == file path to the Glimpse folder containing the images.  The
%         program will use this to retrieve the time base
% fpfn_Intervals == full file path and name for the output Intervals
%         structure.  'Intervals' members are:
%         AllTracesCellArrayDescription
%         AllTracesCellArray {AOI# x 16 cell}
%         CumulativeIntervalArrayDescription 
%         CumulativeIntervalArray [M x 7 double]
%         AllSpots [1x1 structure]
%
% Guided by the SpotIntervals callback in plotargout gui.
% 

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

    % We first read in the 'results', using the aoiinfo2 file to guide
    % thet number and numbering of the AOIs.
[NumberOfAOIs col]=size(aoiinfo2);              % Size of the matrix containing the AOI coordinates
    % Read in one file to obtain frame range
eval(['load ' fp_results num2str(aoiinfo2(1,6)) '.mat'])
[rosebin colbin]=size(results.classes);     % Size of the binary 0/1 trace for first AOI
               % results.classes = [(frame#)  (likelihood?)  (0/1 almost)]
BinaryTraces=cell(NumberOfAOIs,2);           % {1}= [(frm#) (# of frames)], {2}=AOI number
frms=results.classes(:,1);                  % Vector of frame numbers in trace
    
for aoiindx=1:NumberOfAOIs
    eval(['load ' fp_results num2str(aoiinfo2(aoiindx,6)) '.mat'])  % Read in one file containing 'results' for one AOI
                        % Place [(frm #)   0/1] into BinaryTraces cell array  
    
    BinaryTraces{aoiindx,1}=[results.classes(:,1)  (sign(results.classes(:,2)-.5)>=0) ];   % [(frm #)   0/1], 0=NoSpot  1=Spot
    BinaryTraces{aoiindx,2}=aoiinfo2(aoiindx,6);            % AOI number for this loop 
end
    % Now we need to build the Intervals array from all the binary traces
    % in the BinaryTraces cell array.
    
 
    %  Next add the members necessary for the interval detection:  We make
    %  a structure with one member being a cell array containing aoifits file info,
    %  data processing info and the high/low event intervals for that
    %  aoifits file.
    
   CellArrayDescription=['(1:AOIfits Filename) (2:AOI Number) (3:Upward Threshold, sigma units) (4:Down Threshold, sigma units)'...
         '(5:DetrendedMean (6:Std) (7:MeanStdFrameRange Nx2) (8:DataFrameRange Nx2) (9:TimeBase 1xM) [10:Interval array Nx7]'...
         ' 11:InputTrace 2xP  12:DetrendedTrace 2xP 13:BinaryInputTrace Lx3  '...
         '14:BinaryInputTraceDescription 15:DetrendFrameRange Lx2 16:UncorrectedTraceMean'];
   % Both InputTrace and DetrendedTrace are [(frame #)   (integrated intensity)]
     % Description of the cell array element containing the interval array information                                     
    IntervalArrayDescription=['(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
                % InputTrace is the current integrated intensity trace being detected for high/low events,
           % and the InputTrace(:,2) InputTrace(:,3) refered to in next entry
           % runs over just the frame range selected for interval detection
    BinaryInputTraceDescription=['(low or high =0 or 1) InputTrace(:,1) InputTrace(:,2)'];
                    % the IntervalDataStructure structure 
     PresentTraceCellArray=cell(1,16);  % Holds trace presently being processed 
   PresentTraceCellArray{1,14}=BinaryInputTraceDescription;
   PTCA=PresentTraceCellArray;
   PTCA{1,1}='none';
   PTCA{1,3}=3.6;                                % Upward Threshold, sigma units
   PTCA{1,4}=1;                                  % Down Threshold, sigma units
   PTCA{1,5}=0;                                  % Detrended Mean
   PTCA{1,6}=1;                                  % Std
   eval(['load ' fp_images  'header.mat']);      % Loads the vid header file
   PTCA{1,9}=vid.ttb*1E-3;                        % Time base in seconds
   PTCA{1,16} = 0;                               % Uncorrected Trace Mean
   AllTracesCellArray=cell(NumberOfAOIs,16);     % Reserve space for cumulative data from all traces
   CumulativeIntervalArray=[];                  % The interval list from all traces
  
                    % Next, following code from plotargout
                    % 'SpotIntervals_Callback' (that uses AllSpots to find events
                    % then constructs 'Intervals' structure -- here we just
                    % construct the 'Intervals' from the existing binary traces ) 
   for indxAOI=1:NumberOfAOIs           % Cycle through all the AOIs
   
       aoinumber=aoiinfo2(indxAOI,6);   % The AOI number for this loop iteration
       Bin01Trace=BinaryTraces{indxAOI,1};      % [(frm#) (# of frames)] for current AOI
       PTCA{1,8}=[min(Bin01Trace(:,1))   max(Bin01Trace(:,1))];     % Frame range over which we find intervals
                                                           % (use the entire range of frames in the binary trace)
       PTCA{1,7}=PTCA{1,8};                     % Mean and Std frame range (use same as entire trace range)
       PTCA{1,15}=PTCA{1,8};                    % Detrend frame range (use same a entire trace range)
             % Take binary trace and find all the intervals in it
                                                  %0.5=upThresh  0.5=downThresh  1=minUP  1=minDown
       %keyboard
       dat=Find_Landings_MultipleFrameIntervals(Bin01Trace,PTCA{1,8},0.5,0.5,1,1);
                % dat:  structure w/ members 'BinaryInputTrace' and  'IntervalData'
                % dat.BinaryInputTrace = [0/1/2/3   (frm #)   0/1]
       
                         % Next section just from 'Find Intervals case 10 above
       tb=PTCA{1,9};                         %Time base array
        % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
        % where InputTrace here includes only sections searched for events
        %Also mark the first interval 0s or 1s with -2 or -3 respectively,
        %and the ending interval 0s or 1s with +2 or +3 respectivley
       PTCA{1,2}=aoinumber;               % Place aoinumber into proper cell array entry
       PTCA{1,13}=dat.BinaryInputTrace;   % [(-2,-3,0,1,2,3)  frm#  0,1]
       PTCA{1,14}= BinaryInputTraceDescription;
                    % Place binary trace into input trace, b/c a raw integrated input trace MAY not by present 
       PTCA{1,11}=[PTCA{1,13}(:,2) PTCA{1,13}(:,3)];      % Just using [(frm #)  0/1] as input trace
       PTCA{1,12}=[PTCA{1,11}(:,1) PTCA{1,11}(:,2)-min( PTCA{1,11}(:,2) )];     % Place Input Trace also into DetrendedTrace entry of PTCA
                                      % Note that we subtract off and bring baseline close to zero   
     % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
     % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m  
       medianOneFrame=median(diff(tb));    % median value of one frame duration
       [IntervalsRose IntervalsCol]=size(dat.IntervalData);   % IntervalsRose = # of intervals in this AOI trace
            % ['(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
   
      PTCA{1,10}=[dat.IntervalData(:,1:4) (tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame)'  zeros(IntervalsRose,1)  PTCA{1,2}*ones(IntervalsRose,1)];            
   
      for cellindx=1:16
          AllTracesCellArray{indxAOI,cellindx}=PTCA{1,cellindx};               % Insert PresentTraceCellArray into the AllTracesCellArray
      end  
       CumulativeIntervalArray=[CumulativeIntervalArray;PTCA{1,10}];     % Add interval list to the CumulativeIntervalArray
   end
         
                
                
                
                
                
       
   
   % When saving the Intervals:
   Intervals.AllTracesCellArrayDescription=CellArrayDescription;  
   Intervals.AllTracesCellArray=AllTracesCellArray;
   Intervals.CumulativeIntervalArrayDescription=IntervalArrayDescription;
   Intervals.CumulativeIntervalArray=CumulativeIntervalArray;
   %Intervals.AllSpots=[];   
                                               % Open a dialog box for user
    %[fn fp]=uiputfile('*.*','Save the CumulativeIntervalArray and AllTracesCellArray');
    eval( ['save ' fpfn_Intervals ' Intervals' ] );                    % Save the Intervals structure
   
  pc=1;
   
%  Comment out all the stuff below (we used it to build functio above
% Can uncomment by removing the  %{ on the next line
%{      
  
  % Below is the callback from plotargout that performed the landing detection
% (using AllSpots and AllSpotsLow) followed by building of the Intervals
% structure.  We will borrow from below in building the Intervals structure
% from our BinaryTraces cell array.
function SpotIntervals_Callback(hObject, eventdata, handles)
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
 
 
 
 
 
 
% From plotargout header:
    CellArrayDescription=['(1:AOIfits Filename) (2:AOI Number) (3:Upward Threshold, sigma units) (4:Down Threshold, sigma units)'...
         '(5:DetrendedMean (6:Std) (7:MeanStdFrameRange Nx2) (8:DataFrameRange Nx2) (9:TimeBase 1xM) [10:Interval array Nx7]'...
         ' 11:InputTrace 2xP  12:DetrendedTrace 2xP 13:BinaryInputTrace Lx3  '...
         '14:BinaryInputTraceDescription 15:DetrendFrameRange Lx2 16:UncorrectedTraceMean'];
     % Both InputTrace and DetrendedTrace are [(frame #)   (integrated intensity)]
     % Description of the cell array element containing the interval array information                                     
    IntervalArrayDescription=['(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
                % InputTrace is the current integrated intensity trace being detected for high/low events,
           % and the InputTrace(:,2) InputTrace(:,3) refered to in next entry
           % runs over just the frame range selected for interval detection
    BinaryInputTraceDescription=['(low or high =0 or 1) InputTrace(:,1) InputTrace(:,2)'];
                    % the IntervalDataStructure structure 
    handles.IntervalDataStructure.PresentTraceCellArray=cell(1,16);  % Holds trace presently being processed
    handles.IntervalDataStructure.PresentTraceCellArray{1,14}=BinaryInputTraceDescription;
    %handles.IntervalDataStructure.PresentTraceCellArray{1,4}=str2num( get(handles.DownThreshold,'String') );
    %handles.IntervalDataStructure.PresentTraceCellArray{1,3}=str2num( get(handles.UPThreshold,'String') );
    handles.IntervalDataStructure.OneTraceCellDescription=CellArrayDescription;   % describes contents of cell array
    handles.IntervalDataStructure.AllTracesCellArray=cell(1,16);     % Cumulative data from all traces
    handles.IntervalDataStructure.CumulativeIntervalArray=[];        % Just the interval list from all traces
    handles.IntervalDataStructure.IntervalArrayDescription=IntervalArrayDescription;  % Describes the interval list contents
    handles.IntervalDataStructure.AllSpots=[];                      %Will hold the AllSpots structure from imscroll (spot picker option)
    
    
    % From DataOperation_Callback case 5 in plotargout
     case 5         % User Interface Save the cumulative Interval structure information
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    Intervals.AllTracesCellArrayDescription=handles.IntervalDataStructure.CellArrayDescription;
    Intervals.AllTracesCellArray=handles.IntervalDataStructure.AllTracesCellArray;
    Intervals.CumulativeIntervalArrayDescription=handles.IntervalDataStructure.IntervalArrayDescription;
    Intervals.CumulativeIntervalArray=handles.IntervalDataStructure.CumulativeIntervalArray;
    handles.IntervalDataStructure.AllSpots=FreeAllSpotsMemory(parenthandles.AllSpots);
    Intervals.AllSpots=handles.IntervalDataStructure.AllSpots;
                                                % Open a dialog box for user
    [fn fp]=uiputfile('*.*','Save the CumulativeIntervalArray and AllTracesCellArray');
    eval( ['save ' [fp fn] ' Intervals' ] );                    % Save the Intervals structure
    set(handles.AOIList,'String',[fp fn])
    guidata(gcbo,handles)
%}


    
    
    
    
    
    
    
   
    
    
    
