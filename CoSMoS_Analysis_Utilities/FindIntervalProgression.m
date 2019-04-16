function pc=FindIntervalProgression(MultiCumulativeIntervalArray, Interval1, Interval2, Interval3)
%
%function FindIntervalProgression(MultiCumulativeIntervalArray, interval1, interval2, interval3)
%
% Intended to work with MultistateIntervals( ) function.  User searches for
% a specific occupancy sequence specified by Interval1, Interval2 and
% Interval3.  The nomenclature for the Intervals1,2,3 is defined in the
% MultistateInervals( ) function header. For ex. 11 indicates
% occupancy by species 1, 25 indicates occupancy by species 2 AND 3
% 
% MultiCumulativeIntervalArray == output.MultiCumulativeIntervalArray, and
%                    output from the MultistateIntervals( ) function
% Interval1 == specifies first interval in a temporal sequence of 3 states
% Interval2 == specifies second interval in a temporal sequence of 3 states
% Interval3 == specifies third interval in a temporal sequence of 3 states
%
% outputs:  an M x 9 x 3 matrix where
% M == number of interval groups that match our search criteria
% 9 == columns from MultiCumulativeIntervalArray (we save the rows)
% 3 == matrix depth of 3 b/c we save the events for Interval1, 2 and 3
mcia=MultiCumulativeIntervalArray;      % shorten for ease
% MultiCumulativeIntervalArray== matrix summarizing the binding
%         intervals, where an occupancy change of any species represents 
%         the end of an interval.
%        1                       2                 3            4             5                   6           7           8                     9                          
%  [(occupancy state)   (zero time start)   (zero tm end)   delta time   (first event=1)    (last event =1)  AOI#  (glimpse time start)  (glimpse tm end)   ]   
%
% see also MultistateIntervals, overlap_frames

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

[rose col]= size(mcia);                 % Obtain nmber of rows for looping
count=1;                                 % Matrix for accumulating our events of interest
for indx=2:rose-1
            % Loop through the rows of mcia
  if (mcia(indx,1)==Interval2)   
                % Here only if current interval matches our Interval2
               
                % Must check that current event has both a preceeding and
                % succeding event for the same AOI, AND that the intervals
                % for those events match the intervals of Interval1 and
                % Interval2 respectively
     aoinum=mcia(indx,7);   % Current AOI number
     if ((mcia(indx-1,7)==aoinum) &(mcia(indx-1,1)==Interval1) ) & ( (mcia(indx+1,7)==aoinum) &(mcia(indx+1,1)==Interval3) )
                        % Passed our test for matching AOI, Interval1
                        % before, Interval3 after => save the event details
         pc(count,:,1)=mcia(indx-1,:);
         pc(count,:,2)=mcia(indx,:);
         pc(count,:,3)=mcia(indx+1,:);
         count=count+1;
     end
  end
end

         
     
    

