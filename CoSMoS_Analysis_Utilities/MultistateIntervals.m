function pc=MultistateIntervals(timevector,cia1,vid1,cia2,vid2,cia3,vid3)
% 
% function MultistateIntervals(timevector,cia1,vid1,cia2,vid2,cia3,vid3)
%
% This function is a tool for viewing the occupancies of multiple 
% colocalized binding species.  The function will construct a matrix that
% for each time point and each AOI summarizes the occupancy state of multiple
% binding species.  It will also produce a matrix summarizing the binding
% intervals, where an occupancy change of any species represents the end of
% an interval.
%
% timevector === vector of glimpse time points throughout which the interval detections   
%                will be defined.  For example if we run from frame 207  to
%                1223 of cia1 with steps of 0.1 s, then timevector is given by
%                [vid1.ttb(207)*1e-3: 0.1: vid1.ttb(1223)*1e-3]
%                Note these are glimpse times converted to seconds
% cia1, 2 or 3 == Intervals.CumulativeIntervalArray number 1, 2 and 3, each summarizing the
%      occupancy intervals for a single species.  The Intervals structure
%      is produced from the awesome imscroll gui program.
%      e.g. cia1 for U1 snRNA, cia2 for U2 snRNA and cia3 for U5 snRNA landings.
%               1                        2             3             4           5                      6                7 
% [(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#]  
% vid1,2 or 3 == vid header files from the glimpse sequences for cia1,2 and 3  
%
% output.MultiBinaryCells{i}.occupancy == cell arrays (one cell array for each AOI i )
%       Describes the occupancy state for each AOI at each time point of 'timevector' .
%   1           2                 3 (#1 species)    4:(#2 species)   5:(#3 species)     6:(3+4+5)              7               8               9     ]       
% [AOI#   (glimpse time(s))  (Low or High=0/11)      0/12             0/13           (combined state)  (first event=0)  (last event =0) ]  (zero time)  
%                              unspecified=-44        -48              -52
% output.MultiCumulativeIntervalArray== matrix summarizing the binding
%         intervals, where an occupancy change of any species represents 
%         the end of an interval.
%        1                       2                 3            4             5                   6           7           8                     9                          
%  [(occupancy state)   (zero time start)   (zero tm end)   delta time   (first event=1)    (last event =1)  AOI#  (glimpse time start)  (glimpse tm end)   ]   
%
% see also overlap_frames, FindIntervalProgression

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

% Convert time bases to seconds
tb1=vid1.ttb*1e-3;      % time base initially in millisec, converting to sec 
tb2=vid2.ttb*1e-3;
tb3=vid3.ttb*1e-3;

[rs cl]=size(timevector);     % Vector of time points at which we will determine occupancy states
if cl>rs                % If number of columns > number of rows
    timevector=timevector';                 % insuring that timebase is a column vector
end
tnum=length(timevector);    % Number of time points in our timevector
                    % Enumerate list of AOIs in our cia's
AOIvector=[];
for indx=min(cia1(:,7)):max(cia1(:,7))
    if any(indx==cia1(:,7))     % Is AOI#=indx in list of AOis?
        AOIvector=[AOIvector;indx]; % If yes, add it to our list
    end
end
aoinum1=length(AOIvector);          % Number of AOIs in each of our three cia matrices

pc.MultiBinaryCells=cell(aoinum1,1);              % Reserve space for cell  array of AOI occupany states
pc.MultiCumulativeIntervalArray=[];             % Initialize final Interval Array for multiple species
for indxAOI=1:aoinum1
    
    pc.MultiBinaryCells{indxAOI}=zeros(tnum,9);    % Again reserving space.  Initialize all the cells.
end
MultiStateAOI=zeros(tnum,8);
for indxAOI=1:aoinum1           % Loop through all AOIs
    %keyboard
    AOIvector(indxAOI)
    MultiStateAOI(:,1)=ones(tnum,1)*AOIvector(indxAOI);   % Set column 1 to AOI number
    MultiStateAOI(:,2)=timevector;                 % Set column 2 to time vector
      % Obtain the occupancies vs. time for all three species for this AOI 
    timepts1=cia2timepoints(cia1,vid1,timevector,AOIvector(indxAOI));     % Occupancy of species 1 low/high = 0/11
    timepts2=cia2timepoints(cia2,vid2,timevector,AOIvector(indxAOI));     % Occupancy of species 2 low/high = 0/12
    timepts3=cia2timepoints(cia3,vid3,timevector,AOIvector(indxAOI));     % Occupancy of species 3 low/high = 0/13
    % timepts== [(time (zero ref))   occupancy no/yes=0/1      (first event=0, else=1)    (last event =0, else=1)   (frame number)  (glimpse time sec)   AOINumber  ]
    %                                  unspecified = -4
    MultiStateAOI(:,3)=timepts1(:,2)*11;
    MultiStateAOI(:,4)=timepts2(:,2)*12;
    MultiStateAOI(:,5)=timepts3(:,2)*13;
    MultiStateAOI(:,6)=MultiStateAOI(:,3)+MultiStateAOI(:,4)+MultiStateAOI(:,5);    % Combined occupancy
    MultiStateAOI(:,7)=timepts1(:,3)+timepts2(:,3)+timepts3(:,3);  % first event no/yes = 1/0
    MultiStateAOI(:,8)=timepts1(:,4)+timepts2(:,4)+timepts3(:,4);  % last event no/yes = 1/0
    MultiStateAOI(:,9)=timevector-timevector(1);                 % zero reference time base
    % MultiStateAOI contents:
    %   1           2                 3 (#1 species)    4:(#2 species)   5:(#3 species)     6:(3+4+5)              7               8               9     ]       
    % [AOI#   (glimpse time(s))  (Low or High=0/11)      0/12             0/13           (combined state)  (first event=0)  (last event =0) ]  (zero time)  
    %                              unspecified=-44        -48              -52
    pc.MultiBinaryCells{indxAOI}=MultiStateAOI;
    pc.MultiCumulativeIntervalArray=[pc.MultiCumulativeIntervalArray; MultiState2MultiCia(MultiStateAOI)];
end
pc.MultiCumulativeIntervalArrayDescription='1:(occupancy state)   2:(zero time start)   3:(zero tm end)   4:delta time   5:(first event=0)    6:(last event =0)    7:AOI#   8:(glimpse time start)    9:(glimpse tm end) ' ; 
pc.MultiBinaryCellsDescription='[1:AOI#   2:(glimpse time(s))  3:(#1 species Low/High/Unspecified=0/11/-44)    4:( #2 L/H/Un=0/12/-48)    5:( #3 L/H/Un=0/13/-52)     6:(combined state)  7:(first event=0)  8:(last event =0)  9:(zero time) ';




% MultiStateAOI == MultiBinaryCells=MultiBinaryMatrix structures
%   1      2         3 (#1 species)    4:(#2 species)   5:(#3 species)   6 (3+4+5)              7               8           ]
% [AOI#   time(s)  (Low or High=0/11)      0/12             0/13     (combined state)  (first event=0)  (last event =0) ] 
%                   unspecified=-44         -48              -52        
        
%pc.MultiBinaryMatrix=zeros(tnum*aoinum1,8);       % Reserve space for our time vs occupancy matrix for all AOIs
% output.MultiBinaryMatrix== one large matrix containing all of 
%        output.MultiBinaryCells{i}.occupancy concatenated together.
%        i.e. = [output.MultiBinaryCells{1}.occupancy;
%                output.MultiBinaryCells{2}.occupancy;...etc]