function pc=cia2timepoints(cia,vid,timevector,AOInumber)
%
% function cia2timepoints(cia,vid,timevector,AOInumber)
% 
% Will convert a cia matrix intervals into a matrix of time points that
% specify the occupancy state at each time point.
%
%                1                  2                               3                         4                       5               6                7      
% output== [(time (zero ref))   occupancy no/yes=0/1      (first event=0, else=1)    (last event =0, else=1)   (frame number)  (glimpse time sec)   AOINumber  ]
%                                  unspecified = -4
% cia == cia matrix specifying occupany state of a molecular species
%       Obtained from the awesome gui program imscroll
%              1                        2             3             4           5                      6                7 
% [(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#]  
%
% vid == vid structure from the glimpse sequence header file (need time base from this)
%
% timevector === vector of time points at which the occupancy of this AOI
%                will be specified in the output matrix
% AOInumber == specifies which AOI in the cia matrix will be processed
%
% First time for which an AOI is specifed as occupied:
%    (earliest time) >= (time of cia frame specifying event start frame)  
% First time for which an AOI is specified as unoccupied
%    (latest time) < (time of cia frame specifying beginning of next event) 


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

tb=vid.ttb*1e-3;        % Time base for the glimpse file from which the
                        % cia matrix was derived.  1e-3 converts ms to sec
delta_glimpse_time=min(diff(tb));  % Minimum time difference between frames in glimpse sequence
[rs cl]=size(tb);
if cl>rs                % If number of columns > number of rows
    tb=tb';                 % insuring that time base is a column vector
end
nframes=vid.nframes;    % Number of frames in original glimpse file
%keyboard
tb=[tb;tb(length(tb))+delta_glimpse_time]; % Append one more time point to end 
                            % of time base so we can move through entire frame   
                            % range and still reference time of (frame number)+1

logik=(cia(:,7)==AOInumber);    % Find all entries for the specified AOi number
subcia=cia(logik,:);        % subcia is the portion of the cia matrix that
                            % is relevant to the specified AOI number
output=zeros(length(timevector),7);     % Reserve space for the output
output(:,2)=-4;             % Occupancy default is unspecified as -4.  Later we overwrite as occupied/unoccupied=1/0   
output(:,7)=AOInumber;      % Last column contains the AOI number
[rs cl]=size(timevector);
if cl>rs
    timevector=timevector';     % Insuring that timevector is a column matrix
end
output(:,6)=timevector;         % Populate column 6 of output with vector of time points
output(:,1)=timevector-timevector(1); % Column 1 is time refereced to zero for timevector(1)
    % Pick out instances of occupied/unoccupied   first/last event for this specific AOI number 
    % First, unoccpied events:
logik=(subcia(:,1)==0)|(subcia(:,1)==-2)|(subcia(:,1)==2);
cia_un=subcia(logik,:);
    % Next, occupied events
logik=(subcia(:,1)==1)|(subcia(:,1)==-3)|(subcia(:,1)==3);
cia_occ=subcia(logik,:);
    % Next, first event
logik=(subcia(:,1)<0);        % First event -2/-3 for unoccupied/occupied
cia_first=subcia(logik,:);
    % Next, last event
logik=(subcia(:,1)>1);        % Last event 2/3 for unoccupied/occupied
cia_last=subcia(logik,:);
%keyboard
    % Now go through output table and mark appropriate rows
    % Our time base tb extends to tb(nframes+1) (see above)
    % so we are OK in always refering to tb(indx+1)
    % First occupied times
[rose col]=size(cia_occ);
for indx=1:rose             % Loop through all events in this sub cia matrix 
                            % (time >= first event frame) AND (time < last event frame)  
    logik=(timevector>=tb(cia_occ(indx,2)))&(timevector<tb(cia_occ(indx,3)+1));
                            % Above:  need +delta_glimpse_time to include time interval of last frame  
    output(logik,2)=1;      % occupied times marked as 1 in column2
end
    % Next unoccupied times
[rose col]=size(cia_un);
for indx=1:rose             % Loop through all events in this sub cia matrix
                            % (time >= first event frame) AND (time < last event frame)  
    logik=(timevector>=tb(cia_un(indx,2)))&(timevector<tb(cia_un(indx,3)+1));
    output(logik,2)=0;      % Unoccupied times marked as 0 in column 2
end
    % Next First event
[rose col]=size(cia_first);
output(:,3)=0;              % Default is that event is the first one

for indx=1:rose             % Loop through all events in this sub cia matrix
                            % for first event: (time >= first event frame) AND (time < last event frame)  
                            %logik=(timevector>=tb(cia_first(indx,2)))&(timevector<tb(cia_first(indx,3)));
            % Find all times not within first event  
    logik=(timevector>= tb(cia_first(indx,3)+1));   % time >= beginning time of next event
    output(logik,3)=1;      % Not First event marked as 1 in column 3
end
    % Next Last event
[rose col]=size(cia_last);
output(:,4)=0;              % Default is that event is the last one
for indx=1:rose             % Loop through all events in this sub cia matrix
                            % for last event(time >= first event frame) AND (time < last event frame)  
                            %logik=(timevector>=tb(cia_last(indx,2)))&(timevector<tb(cia_last(indx,3)));
             % Find all times not within last event: time < (first frame of last event)
    logik=( timevector< tb(cia_last(indx,2)) );
    output(logik,4)=1;      % Not First event marked as 1 in column 4
end

%Finally, we need to populate the #5 frame column of the output.  Note that the frames will
%reference just the particular glimplse sequence relevant for this cia matrix

time_begin=timevector(1);
time_end=timevector(length(timevector));
logik=(tb>=time_begin);   % Find all glimpse times >= input time vector start
minfrm=min( find(logik) );  % Frame number of glimpse file corresponding to min time in time vector
logik=(tb(1:nframes)>=time_end);     % Find all glimpse times >= input time vector end
maxfrm=min([nframes min( find(logik))] );   % Frame number of glimpse file corresponding to max time in time vector
                                     % Will equal nframes if time_end is > time for last frame 

    % Now loop through all relevant frames
    % maxfrm is maximally equal to vid.nframes, but our time base tb
    % extends to tb(nframes+1) so we are OK in always refering to tb(indx+1) 
for indx=minfrm:maxfrm
            % Find (time vector entries >= current frame time)AND (time vector entries)< next frame time)   
    logik=(timevector>=tb(indx))&(timevector<tb(indx)+tb(indx+1));
    output(logik,5)=indx;   % mark column 5 of such rows as belonging to current frame
end
    % wrt first/last events:  Consider case where time vector extends
    % beyond the glimpse time base of a cia matrix => default should be to
    % mark columns as first and last event, then override
pc=output;




%   1      2         3 (#1 species)    4:(#2 species)   5:(#3 species)   6 (3+4+5)              7               8             9       10      11]       
% [AOI#   time(s)  (Low or High=0/101)      0/102             0/103     (combined state)  (first event=0)  (last event =0)   xtra1   xtra2  xtra3] 