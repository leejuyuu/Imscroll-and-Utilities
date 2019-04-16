function pc=Events2cia(EventList,framevector,vid,AOInumber)
%
% function Events2cia(EventList,framevector,vid,AOInumber)
%
% A utility function that will use a list of high binding events for one 
% AOI to create a CumulativeIntervalArray (cia) matrix for that single AOI.
%
% EventList == M x 2 matrix listing M binding events for this AOI.  The
%              form of the matrix is: 
%               [ (starting frame)  (ending frame) ]
% framevector = vector list of frame numbers for the binding trace from
%              which this data arose
% vid == header file for the glimpse file from which this data arose
%            (used for the time base)
% AOInumber == the AOI (area of interest) number to which this list of
%            events belongs (needed just to fill in the cia
% output.EventList == EventList of just the high interval ranges
%as used by the program, meaning that the
%                list has been ordered, intervals are restricted to the 
%                range of framevector and any overlaps in the intervals
%                have been corrected
% output.HighLowIntervalList == list of high/low intervals as used by this
%                program.  The form of this matrix is:
%                 [ (-2,2,0/-3,3,1)   (starting frame)    (ending frame) ]  
% output.cia == cia matrix built from the input events
%   The form of the cia array is:
% (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#
frmnum=length(framevector);     % Number of frames 

tb=(vid.ttb-vid.ttb(1))*1e-3;   % Reference zero time to first frame, convert to seconds
delta_glimpse_time=min(diff(tb));  % Minimum time difference between frames in glimpse sequence
[rs cl]=size(tb);
if cl>rs                % If number of columns > number of rows
    tb=tb';                 % insuring that time base is a column vector
end

tb=[tb;tb(length(tb))+delta_glimpse_time]; % Append one more time point to end 
                            % of time base so we can move through entire frame   
                            % range and still reference time of (frame number)+1
    
[rose col]=size(EventList);
if rose ~=0
   % Here if EventList is not empty:  sort in ascending order of intervals
    [Y I]=sort(EventList(:,1));
    EventList=EventList(I,:);   % Store the EventList in ascending order
end
if (rose==0)|(col==0)
    % Here if there are no events (EventList is empty)
    % Do nothing b/c we treat this as a special case below in constructing
    % the HighLowIntervalList
    %cia=[0 framevector(1)  framevector(length(framevector))  (framevector(length(framevector))-framevector(1)+1) ...
    %            ( tb( framevector(length(framevector))+1)-tb(framevector(1)) )  0 AOInumber];
elseif rose==1
    % Here if there is a single high event in our list
else
    % Here if we have multiple landing events
    % First check for and remove overlaps in the events
    indx=1;                     % count index to cycle through rowe of EventList
    flagg1=1;
    while flagg1==1
       
        [rose col]=size(EventList); %Repeat this b/c the size can change
                                    % if we find overlaps
        if indx>=rose
            break               % Exits the while flagg1==1 b/c we reached the 
                                % end of the EventList matrix
                                
             % In the next line we need the '+1' in the EventList(indx,2)+1
             % b/c if the high intervals end/begin on adjacent frames then
             % those high intervals still overlap
        elseif EventList(indx,2)+1>=EventList(indx+1,1)
                                % Here if there is an overlap.
                                % Combine rows into one event, and do not
                                % increment the indx
            if EventList(indx+1,2)>=EventList(indx,2)
                EventList(indx,:)=[EventList(indx,1) EventList(indx+1,2)];
                EventList(indx+1,:)=[]; % Remove the row that overlaps with the previous row
            else
                    % Here if the indx+1 interval is entirely contained
                    % w/in the indx interval => just remove the indx+1 interval 

                EventList(indx+1,:)=[]; % Remove the row that overlaps with the previous row
            end
        else
            indx=indx+1;
        end         % end of if indx>=rose
    end
        % Here b/c we have >1 events in EventList and we have now modified
        % the list to remove overlaps
        % The following construction of HighLowIntervalList relies on the facts that:
        % EventList is strictly nonoverlapping
        % EventList is in ascending order of the first column (start of intervals) 
end

% We now have a list of ordered nonoverlapping events in EventList, and we
% will use this to construct the HighLowIntervalList as follows.

[rose col]=size(EventList);
if (rose~=0)
        % Here when EventList contains >=1 rows, and we have not modified
        % the list to remove overlaps
        % First we list just the high and low intervals
        % Initialize list of high/low intervals
        %              [ 0/1     (start frame)  (end frame)  ]
    HighLowIntervalList=[0 framevector(1) framevector(frmnum)];
    for indx=1:rose
       
        if EventList(indx,2)<framevector(1)
            % Here if interval is entirely less than framevector range: do nothing 
        elseif EventList(indx,1)<=framevector(1)
            % Here if interval begins beneath framevector range, but ends within or above it 
            % Here if current high event starts at begining, i.e. at framevector(1)
            if EventList(indx,2)>=framevector(frmnum)
                % Here if entire time will be high
                HighLowIntervalList=[1 framevector(1) framevector(frmnum)];
            else
               
                % First event is high, and
                % high interval ends before the last frame
                HighLowIntervalList=[1 framevector(1) EventList(indx,2)
                                    0 EventList(indx,2)+1  framevector(frmnum)];
            end
        elseif EventList(indx,1)<=framevector(frmnum)
            [r1 c1]=size(HighLowIntervalList);
            % Here if current interval begins within framevector range and
            % does not begin at the very first frame
            if EventList(indx,2)>=framevector(frmnum)
                % Here if current interval runs to end of framevector
          
                HighLowIntervalList=[HighLowIntervalList(1:r1-1,:)
                                    0 HighLowIntervalList(r1,2) EventList(indx,1)-1
                                    1 EventList(indx,1) framevector(frmnum)];
            else
                % Here if current high interval begins within framevector range but
                % high interval ends before the last frame
                
                HighLowIntervalList=[HighLowIntervalList(1:r1-1,:)
                                    0 HighLowIntervalList(r1,2) EventList(indx,1)-1
                                    1 EventList(indx,1) EventList(indx,2)
                                    0 EventList(indx,2)+1  framevector(frmnum)];
            end
            % If the current interval begins at a frame 
            % that is >= framevector(frmnum), then we do not add to the
            % HighLowIntervalList
        end
    end
else
    % Here if EventList contains no high events.  We then have a single 
    % low event throughout our frame range
    HighLowIntervalList=[0 framevector(1) framevector(frmnum)];
   
end

%  We now have a final HighLowIntervalList

%  Mark the ending and beginning intervals
[r2 c2]=size(HighLowIntervalList);
if HighLowIntervalList(r2,1)==0
    % Here if last interval is low
    HighLowIntervalList(r2,1)=2;
else
    % Here if last interval is high
    HighLowIntervalList(r2,1)=3;
end
if (HighLowIntervalList(1,1)==0)|(HighLowIntervalList(1,1)==2)
    % Here if beginning interval is low
    HighLowIntervalList(1,1)=-2;
else
    % Here if beginning interval is high
    HighLowIntervalList(1,1)=-3;
end
    % Now we need to fill in the CumulativeIntervalList
cia=[];     % cia = % (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#

[roseh colh]=size(HighLowIntervalList);
for indx = 1:roseh
    cia=[cia;
         HighLowIntervalList(indx,:)  HighLowIntervalList(indx,3)-HighLowIntervalList(indx,2)+1 ...
           tb(HighLowIntervalList(indx,3)+1)- tb(HighLowIntervalList(indx,2))  0   AOInumber];
end
           

   
pc.EventList=EventList;
pc.HighLowIntervalList=HighLowIntervalList;           % just a temporary end for us to test above
pc.cia=cia;                
            
                                    
                                    
                                  
