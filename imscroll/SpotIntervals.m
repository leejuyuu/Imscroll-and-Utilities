function IntervalDataStructure = SpotIntervals(frameRange,radius,radius_hys,aoiinfo,shiftedXY,AllSpots,AllSpotsLow,tb)
%

frameInterval = [frameRange(1), frameRange(end)];

aoivector=aoiinfo(:,6);    % Vector of aoi numbers
nAOIs = length(aoivector);
ATCA = cell(nAOIs,16);
traces  = cell(nAOIs,1);
cumulatedInterval = cell(nAOIs,1);
for iAOI = aoivector'
    aoinumber=aoivector(iAOI);   % Current AOI
    fprintf('processing AOI %d\n',iAOI);
    % Bin01Trace = [(frm #)  0/1]
    Bin01Trace = AOISpotLanding2(aoinumber,radius,radius_hys,AllSpots,AllSpotsLow,shiftedXY);          % 1/0 binary trace of spot landings
    
    % Take binary trace and find all the intervals in it
    %0.5=upThresh  0.5=downThresh  1=minUP  1=minDown
    dat = Find_Landings_MultipleFrameIntervals(Bin01Trace,frameInterval,0.5,0.5,1,1);
    % dat:  structure w/ members 'BinaryInputTrace' and  'IntervalData'
    % dat.BinaryInputTrace = [0/1/2/3   (frm #)   0/1]
    
    
    % Next section just from 'Find Intervals case 10 above
    
    % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
    % where InputTrace here includes only sections searched for events
    %Also mark the first interval 0s or 1s with -2 or -3 respectively,
    %and the ending interval 0s or 1s with +2 or +3 respectivley
    PTCA{1,2}=aoinumber;               % Place aoinumber into proper cell array entry
    traces{1} = dat.BinaryInputTrace;   % [(-2,-3,0,1,2,3)  frm#  0,1]
    
    
    if isempty(tb)
        error('User must input time base file prior to building IntervalData array')
    else
        % add the deltaTime value to the 5th column to the IntervalData
        % array, and subtract mean from event height
        %IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
        
        [IDrose,~]=size(dat.IntervalData);
        
        % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
        % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m
        medianOneFrame=median(diff(tb));    % median value of one frame duration
        
        cumulatedInterval{iAOI} = [dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame PTCA{1,2}*ones(IDrose,1)];
        
    end
    
end             % End of cycling through the AOIs
IntervalDataStructure.AllTracesCellArray=traces;
IntervalDataStructure.CumulativeIntervalArray=cell2mat(cumulatedInterval);
% Add the AllSpots structure (for saving) used for finding intervals
% AllSpots structure defined in imscroll gui
IntervalDataStructure.AllSpots = AllSpots;
IntervalDataStructure.AllSpotsLow = AllSpotsLow;
% Add the proximity radius used in computing the intervals to the
% AllSpots structure (so it will be there when saved)
IntervalDataStructure.radius = radius;
IntervalDataStructure.radius_hys = radius_hys;

end
