function pc=events_per_aoi(cia)
%
% function events_per_aoi(cia)
%
% cia == Cumulative Interval Array from the Intervals structure created in
%        imscroll during interval detection (e.g. dwell times of a binding
%        protein  (=Intervals.CumulativeIntervalArray )
%         Intervals.CumulativeIntervalArrayDescription=
%        [  1:(low or high =-2,0,2 or -3,1,3)      2:(frame start)        3:(frame end)   …    
%        4: (delta frames)        5:(delta time (sec))     6:(interval ave intensity)       7:AOI#   ]
%
%
% OUTPUT:   [(AOI #)  (# of low events)  (# of high events)]
% output.eventnum ==  [(AOI #)  (# of low events)  (# of high events)]
% output.aoicells ==  A cell array where  The arrays will contain the 
%                      low events ( output.aoicells (m,1)) or high events
%                      (output.aoicells(m,2) )  for the mth AOI.  The format
%                      of the cell array is the same as the
%                      Intervals.CumulativeIntervalArray
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

eventnum=zeros(aoinum,3);
for indx=1:aoinum
    % Loop through all the aois, getting the number of high and low events
    [lowrose lowcol]=size(aoicells{indx,1});    % aoicells{m,1} lists (from the rows of the cia matrix) the low events in the mth aoi
    [hirose hicol]=size(aoicells{indx,2});      % aoicells{m,2} lists (from the rows of the cia matrix) the high events in the mth aoi
    eventnum(indx,:)=[indx lowrose hirose];
end
pc.eventnum=eventnum;
pc.aoicells=aoicells;


