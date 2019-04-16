function pc=MultiState2MultiCia(MultiStateAOI)
%
%    function MultiState2MultiCia(MultiStateAOI)
%
% This function will be called from the MultistateIntervals program and will
% process the MultiStateAOI() (multi-state data vs time from one AOI) into
% a cumulative interval list for that AOI
%
% MultiStateAOI == from the MultistateIntervals program, a matrix with the
%              time vs. occupancy information for one AOI,  defined as:
%   1           2                3 (#1 species)                4:(#2 species)   5:(#3 species)    6:(3+4+5)           7               8                9       ]       
% [AOI#   glimpse time(s)  (occupied or unoccupied=0/11)      0/12                0/13         (combined state)  (first event=0)  (last event =0)  (zero time) ] 
%                           unspecified=-44                    -48                 -52
%
% output.MultiCumulativeIntervalArray== matrix summarizing the binding
%         intervals, where an occupancy change of any species represents 
%         the end of an interval.
%        1                       2                 3            4             5                   6           7           8                     9                          
%  [(occupancy state)   (zero time start)   (zero tm end)   delta time   (first event=0)    (last event =0)  AOI#  (glimpse time start)  (glimpse time end)   ]   

% Copyright 2017 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.


% Algorithm: First find only those times for which the multistate occupancy 
% column 6 of MultiState(:,6) are >0 (meaning those occupancy states are
% specified for all three species.  We then focus on only those time limits
% and use occupancy data only between those time limits.  We find the
% occupancy transitions of only that set of data 
% i.e. (transitions =abs(diff(MultiState(lower:uppper,6)) )
% every entry of transitions>0 will then occur at a time value that is one
% time increment past the end of a transition.  This allows us to define
% the beginning and end of all events.   We start with the very first time
% point of our valid time range as the start of the first event.  We then
% go through the list of times for all the transitions to define the end of
% one and the beginning of the next event interval.  The end of the last
% event will be the final time point of the valid range of times (range of
% times for which the occupancy is defined for all three species).

logik=MultiStateAOI(:,6)>=0;         % Find all rows wtih state specified for all three species
%validMultiStateAOI=MultiStateAOI(logik,:);  % This defines the only portion of the input
                                            % matrix that has the occupancy state for
                                            % the three species defined
%keyboard
I=find(logik,1,'last');                     % I is the indx of last valid row in MultiStateAOI
F=find(logik,1,'first');                    % F is the indx of first valid row in MultiStateAOI
                  %  (glimpse time)              zero referenced time)                 (combined state occupancy) 
time_occupancy=[MultiStateAOI(logik,2) MultiStateAOI(logik,2)-MultiStateAOI(F,2)  MultiStateAOI(logik,6)];

timenum=length(time_occupancy(:,1));    % Number of time points in the valid range where occupancy is defined
delta_time=min( diff(time_occupancy(:,1)) );   % Minimum time difference between time points in valid range
        % To find the edges of intervals, we take the difference of the list of occupancy states.
        % Then, each abs(diff()) >0 will occur one time interval beyond the
        % end of each event interval
                    % (glimpse time)      (zero ref time)   (occupancy)    | diff(occupancy)|(where >0 indicates occupancy transition)
interval_indicator=[time_occupancy(2:timenum,:) abs(diff(time_occupancy(:,3)))];
        % Now add one time point at the BOTTOM of our list of valid time
        % The length of interval_indicator will be therefore=timenum
        % The last row is not a valid time point, but we can always refer 
        % to the indx+1 row index of our valid times
 if max(interval_indicator(:,1)) < max(MultiStateAOI(:,2))
 
            % Here if last valid time point is not the maximum time from MultiStateAOI
            % => we can access the next time point from MultiStateAOI
     interval_indicator=[interval_indicator;MultiStateAOI(I+1,2) MultiStateAOI(I+1,2)-MultiStateAOI(1,2) interval_indicator(timenum-1,3:4)];
 else
            % Here if last valid time point IS the maximum time from
            % MultiStateAOI => just add a minimum time interval to obtain the
            % next time point
      % timenum  
      if (MultiStateAOI(1,1)==660)
       keyboard
      end
      
     interval_indicator=[interval_indicator;interval_indicator(timenum-1,1:2)+delta_time interval_indicator(timenum-1,3:4)];
 end


intervals=[];       % Initialize list of intervals
start_time=time_occupancy(1,1:2);   % Note we use first point of time_occupancy rather
                                    % than from interval_indicator in order
                                    % to initialize start time of first interval
                                        % [(glimpse time}  (zero ref time)]
%keyboard
for indx=1:timenum-1
                     % Runs to timenum-1 b/c that is the number of valid
                     % differences from our list of timnum time points 
    if interval_indicator(indx,4)>0;    % True if end of event
                              % (glimpse time)      (zero ref time)   (occupancy)    | diff(occupancy)|(where >0 indicates occupancy transition)
        if indx==1
                                % g time start   g time end              delta time                    z time start    z  time end     occupancy
            intervals=[intervals; start_time(1) start_time(1)   interval_indicator(1,1)-start_time(1)   start_time(2) start_time(2)  time_occupancy(1,3)];
            start_time=interval_indicator(indx,1:2);     % Start of next interval
        elseif indx==timenum-1
                    % Last row entry in interval_indicator, so we mark the 
                    % end of an event AND the very
                    % last time point will itself be a one time point event
                    % (this will not happen very often)
                        % First mark the end of an event
                         %        g time start   g time end                            delta time                        z time start        Z time end             occupancy
            intervals=[intervals; start_time(1) interval_indicator(indx-1,1) interval_indicator(indx,1)-start_time(1)   start_time(2) interval_indicator(indx-1,2) interval_indicator(indx-1,3)];
                        % Then mark final time point as an event
                         %        g time start                     g time end                   (delta time)                                       z time start                 Z time end             occupancy
            intervals=[intervals;interval_indicator(indx,1) interval_indicator(indx,1) interval_indicator(indx+1,1)-interval_indicator(indx,1) interval_indicator(indx,2) interval_indicator(indx,2) interval_indicator(indx,3)];
                        % No need to define start_time b/c this is the end of the loop 
        else
                    % Here if this time marks the end of an event AND we
                    % are not at the beginning or end of the valid time range 
                    %               g time start      g time end                   (delta time)                       z time start          Z time end               occupancy
            intervals=[intervals; start_time(1) interval_indicator(indx-1,1) interval_indicator(indx,1)-start_time(1)  start_time(2) interval_indicator(indx-1,2) interval_indicator(indx-1,3)];
            start_time=interval_indicator(indx,1:2);     % Start of next interval
        end
    elseif indx==timenum-1
            % Not detecting an event end, but this is the last entry, so 
            % we must still mark this last time point as the end of an event
                     %          g time start      g time end                   (delta time)                       z time start         Z time end               occupancy
         intervals=[intervals;start_time(1) interval_indicator(indx,1)  interval_indicator(indx+1,1)-start_time(1)  start_time(2) interval_indicator(indx,2)  interval_indicator(indx,3)];
    end
    % Did not detect an event end for this value of indx, and we are not at
    % the end of the valid time points yet, so just keep going through the
    % list of time points.
end
    % Now we need to build up the output matrix
[rose col]=size(intervals);

pc=zeros(rose,9);                           % Pre-alocate size
pc(:,1)=intervals(:,6);                     % Occupancy during events
pc(:,2:3)=intervals(:,4:5);                 % zero time reference start and end times for events
pc(:,4)=intervals(:,3);                     % delta time for events
pc(:,8:9)=intervals(:,1:2);                 % glimpse start and end times for events

pc(:,7)=MultiStateAOI(1,1)*ones(rose,1);   % AOI number

%        1                       2                 3            4             5                   6           7           8                     9                          
%  [(occupancy state)   (zero time start)   (zero tm end)   delta time   (first event=0)    (last event =0)  AOI#  (glimpse time start)  (glimpse time end)   ]   



 pc(1,5)=1;                                 % Marking first event
 pc(rose,6)=1;                              % Marking last event
        
    


