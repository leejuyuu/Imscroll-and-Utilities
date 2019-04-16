function pc = overlap_event_time(cia1,cia2,thymebase1,thymebase2,aoinum)
%
% overlap_event(cia1,cia2,thymebase1,thymebase2,aoinum)
%
% Function will locate overlapping events in the 
% Intervals.CumulativeIntervalArray specified by cia1 and cia2.
% The user specifies an aoi number ('aoinum') (in both cia1 and cia2).
% For each high event in cia1 (for that particular aoi) the function will
% find any events in cia2 (for that same aoi) that begin during the event 
% cia1.  This function looks for overlap in time using the time base 
% information in thymebase1 and thymbase2.  Compare to overlap_event()
% function that just compares the frame numbers to find overlaps (the
% latter does not work if the cia1 and cia2 are from different glimpse
% sequences, hence the need for ovrelap_event_time() function.
% cia1=Intervals.CumulativeIntervalArray for species 1
% cia2=Intervals.CumulativeIntervalArray for species 2
% thymebase1 == vid.ttb time base from the glimpse image sequence
%             asslciated with cia1
% thymebase2 == vid.ttb time base from the glimpse image sequence
%             asslciated with cia2 (frequently will be the same as thymebase1)
% aoinum=[vector of aoi numbers in cia1]
% cia =               1                         2           3           4               5                     6                7   
%        (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#

% Output:
% output.allouts=cumulative listing in one matrix of all the ovelap events
%  [(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#  (1 or 2)]
%   where the last entry of (1 or 2) refers to cia1 or cia2 respecively
%
% output.outcell= vector of cell arrays, where each cell array lists only
%            one event from cia1 and the overlap events(s) from cia2
tb1=thymebase1;
tb2=thymebase2;
num=length(aoinum);     % number of aois we will be processing
count=0;                % Count number of events in cia1 that overlap with cia2 events
allcount=0;             % Count total number of rows needed for the allouts matrix (cumulative listing of all overlaps)
for aoiindx=1:num       % Loop through all the aois first just to count the number of overlaps
    % Find all high events in one aoi from cia1
    logik=(cia1(:,7)==aoinum(aoiindx))&((cia1(:,1)==-3)|(cia1(:,1)==1)|(cia1(:,1)==3) );
    lands1=cia1(logik,:);
    [rose col]=size(lands1);        % rose = number of high events in cia1 for this aoinum value
                    % Find all high events in cia2 for this aoinum
    logik=(cia2(:,7)==aoinum(aoiindx))&((cia2(:,1)==-3)|(cia2(:,1)==1)|(cia2(:,1)==3) );
    lands2=cia2(logik,:);
    
                    % For each high event in lands1, find the same aoi in
                    % lands2 and find any event that begins during the high
                    % event in lands1
                    % First loop really just counts the number of
                    % overlapping events (number of cia1 events that
                    % overlap)
    
    for indx=1:rose     % For this AOI, loop through each high event
        oneouts=[];
        logik=(lands2(:,7)==aoinum(aoiindx))&(tb2(lands2(:,2))>=tb1(lands1(indx,2)))&(tb2(lands2(:,2))<=tb1(lands1(indx,3)));
        if sum(logik)>0
            count=count+1;  % When we find an overlap, increment the overlap count index
           oneouts=[oneouts;lands1(indx,:) 1];  
           oneouts=[oneouts;lands2(logik,:) 2*ones(sum(logik),1)];
           [roseone colone]=size(oneouts);
           allcount=allcount+roseone;       % Running count of rows needed for the allouts matrix
        end
    
    end   
end
            % At this point, 'count'  gives the number of aois from cia1 
            % that overlap events from cia2
            % Initialize the output cell array
outcell=cell(count,1);

            % Now cycle through the aois again, this time saving all the
            % overlap results into a cell array.  Each cell of the cell
            % array will store the overlap 
count=0;

allouts=zeros(allcount,colone);     % Initialize output matrix for cumulative list of all overlap events
allcount=1;
for aoiindx=1:num       % Loop through all the aois first just to count the number of overlaps
    % Find all high events in one aoi from cia1
    logik=(cia1(:,7)==aoinum(aoiindx))&((cia1(:,1)==-3)|(cia1(:,1)==1)|(cia1(:,1)==3) );
    lands1=cia1(logik,:);
    [rose col]=size(lands1);        % rose = number of high events in cia1 for this aoinum value
                    % Find all high events in cia2 for this aoinum
    logik=(cia2(:,7)==aoinum(aoiindx))&((cia2(:,1)==-3)|(cia2(:,1)==1)|(cia2(:,1)==3) );
    lands2=cia2(logik,:);
    
                    % For each high event in lands1, find the same aoi in
                    % lands2 and find any event that begins during the high
                    % event in lands1
                    % First loop really just counts the number of
                    % overlapping events (number of cia1 events that
                    % overlap)
    
    for indx=1:rose
        oneouts=[];
        logik=(lands2(:,7)==aoinum(aoiindx))&(tb2(lands2(:,2))>=tb1(lands1(indx,2)))&(tb2(lands2(:,2))<=tb1(lands1(indx,3)));
        if sum(logik)>0
            
            count=count+1;  % When we find an overlap, increment the overlap count index
           oneouts=[oneouts;lands1(indx,:) 1];  
           oneouts=[oneouts;lands2(logik,:) 2*ones(sum(logik),1)];
           outcell{count}=oneouts;      % Save the overlap events in one cell array
           [roseone colone]=size(oneouts);
                                        % Save the cumulative list of all
                                        % overlap events
          %keyboard
           allouts(allcount:allcount+roseone-1,:)=oneouts;
                                        % Increment the index of the
                                        % allouts matrix
           allcount=allcount+roseone;   
           
           
        end
    
    end   
end
pc.allouts=allouts;
pc.outcell=outcell;
end










%