function pc=binding_event_time(cia, thyme, hilo)
%
% function binding_event_time(cia, thyme, hilo)
%
% cia == Cumulative Interval Array from the Intervals structure created in
%        imscroll during interval detection (e.g. dwell times of a binding
%        protein  (=Intervals.CumulativeIntervalArray )
%         Intervals.CumulativeIntervalArrayDescription=
%        [  1:(low or high =-2,0,2 or -3,1,3)      2:(frame start)        3:(frame end)   …    
%        4: (delta frames)        5:(delta time (sec))     6:(interval ave intensity)       7:AOI#   ]
%
% thyme == minimum time for the event.  That is, if thyme = tzero and 
%          hilo = 0 the user wants this function to return a list of events
%          that constitute the first low event from each AOI that begins at
%          a time greater than or equal to tzero (time measured in frame
%          numbes from the start of the glimplse image sequence).
%
% hilo == 0 or 1  
%         0: return low events
%         1: return high events
%
% SEE ALSO BINDING_EVENT_NUMBER, an EVENTS_PER_AOI
[eventnum ciacol]=size(cia);   % eventnum = number of events listed in cia 
logik=cia(:,1)<0;       % Negative number in first column occurs for start 
                        % events for each AOI
aoinum=sum(logik);      % aoinum = number of aois in list
aoicells=cell(aoinum,2);    % Form cell array.  The arrays will contain the 
                            % low events ( cell(m,1)) or high events
                            % (cell(m,2) )  for the mth AOI
starts=find(logik);     % starts = row indices of cia array that enumerate
                        % the first entry for each aoi
for indx=1:aoinum-1
    aoievents=cia(starts(indx):starts(indx+1)-1,:);     % submatrix of cia listing events for aoi = indx
    logikhigh=(aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3);
    aoicells{indx,2}=aoievents(logikhigh,:);       % Capture and list all the high events
    logiklow=(aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2);
    aoicells{indx,1}=aoievents(logiklow,:);        % Capture and list all the low events
end
            % Now for the last AOI
aoievents=cia(starts(aoinum):eventnum,:);        % submatrix of cia listing events for aoi = indx
 
logikhigh=(aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3);
aoicells{aoinum,2}=aoievents(logikhigh,:);       % Capture and list all the high events
logiklow=(aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2);
aoicells{aoinum,1}=aoievents(logiklow,:);        % Capture and list all the low events
        % Next, loop through each aoi and grab the nth event if it exists (high or low)
pc=10*ones(aoinum,ciacol);       % Reserve maximum space for output
eventcount=1;
if hilo==0
        % Here to grab the first low event with start of event >= thyme
    for indx=1:aoinum
        [rose col]=size(aoicells{indx,1});      % rose = number of low events for this aoi =indx
        if rose>=1          % Test that there are any events at all
            logiktime=aoicells{indx,1}(:,2)>=thyme;
            if sum(logiktime)>0   % Test that there are events with start times >= thyme 
                eventstime=aoicells{indx,1}(logiktime,:);   % List of all events with start time >=thyme
                pc(eventcount,:)=eventstime(1,:); % Grab first event with a start time >= thyme
                eventcount=eventcount+1;            % Increment event index
            end
        end
    end
elseif hilo==1
        % Here to grab the first high event low event with start of event >=thyme   
    for indx=1:aoinum
        [rose col]=size(aoicells{indx,2});      % rose = number of high events for this aoi =indx
        if rose>=1          % Test that there are any events at all
           logiktime=aoicells{indx,2}(:,2)>=thyme;
           if sum(logiktime)>0  % Test that there are events with start times >= thyme
               eventstime=aoicells{indx,2}(logiktime,:);   % List of all events with start time >=thyme
               pc(eventcount,:)=eventstime(1,:); % Grab first event with a start time >= thyme
               eventcount=eventcount+1;            % Increment event index
           end
        end
    end    
end
        % Now need to truncate the pc output because the number of
        % qualifying events can be less than the number of aois
logik=pc(:,1)~=10;      % True for all the rows that constitute actual events
actualeventnumber=sum(logik);
pc=pc(1:actualeventnumber,:);
