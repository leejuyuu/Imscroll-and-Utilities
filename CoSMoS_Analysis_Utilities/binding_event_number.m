function pc=binding_event_number(cia, n, hilo)
%
% function binding_event_number(cia, n, hilo)
%
% cia == Cumulative Interval Array from the Intervals structure created in
%        imscroll during interval detection (e.g. dwell times of a binding
%        protein  (=Intervals.CumulativeIntervalArray )
%         Intervals.CumulativeIntervalArrayDescription=
%        [  1:(low or high =-2,0,2 or -3,1,3)      2:(frame start)        3:(frame end)   �    
%        4: (delta frames)        5:(delta time (sec))     6:(interval ave intensity)       7:AOI#   ]
%
% n == number of the binding event from each AOI.  That is, if n = 3 and 
%      hilo = 0 the user wants this function to return a list of events
%      that constitute the third low interval from each AOI  
%
% hilo == 0 or 1  
%         0: return low events
%         1: return high events
%
% SEE ALSO BINDING_EVENT_TIME, an EVENTS_PER_AOI
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
        % Here to grab the low events
    for indx=1:aoinum
        [rose col]=size(aoicells{indx,1});      % rose = number of low events for this aoi =indx
        if rose>=n
            pc(eventcount,:)=aoicells{indx,1}(n,:); % Grab nth row (nth low event) from this aoi
            eventcount=eventcount+1;            % Increment event index
        end
    end
elseif hilo==1
        % Here to grab the high events
    for indx=1:aoinum
        [rose col]=size(aoicells{indx,2});      % rose = number of high events for this aoi =indx
        if rose>=n
            pc(eventcount,:)=aoicells{indx,2}(n,:); % Grab nth row (nth high event) from this aoi
            eventcount=eventcount+1;            % Increment event index
        end
    end    
end
        % Now need to truncate the pc output because the number of
        % qualifying events can be less than the number of aois
logik=pc(:,1)~=10;      % True for all the rows that constitute actual events
actualeventnumber=sum(logik);
pc=pc(1:actualeventnumber,:);
