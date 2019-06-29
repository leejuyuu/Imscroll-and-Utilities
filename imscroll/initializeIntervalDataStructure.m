function IntervalDataStructure = initializeIntervalDataStructure()
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
    IntervalDataStructure.PresentTraceCellArray=cell(1,16);  % Holds trace presently being processed
    IntervalDataStructure.PresentTraceCellArray{1,14}=BinaryInputTraceDescription;
    %handles.IntervalDataStructure.PresentTraceCellArray{1,4}=str2num( get(handles.DownThreshold,'String') );
    %handles.IntervalDataStructure.PresentTraceCellArray{1,3}=str2num( get(handles.UPThreshold,'String') );
    IntervalDataStructure.OneTraceCellDescription=CellArrayDescription;   % describes contents of cell array
    IntervalDataStructure.AllTracesCellArray=cell(1,16);     % Cumulative data from all traces
    IntervalDataStructure.CumulativeIntervalArray=[];        % Just the interval list from all traces
    IntervalDataStructure.IntervalArrayDescription=IntervalArrayDescription;  % Describes the interval list contents
    IntervalDataStructure.AllSpots=[];   
end