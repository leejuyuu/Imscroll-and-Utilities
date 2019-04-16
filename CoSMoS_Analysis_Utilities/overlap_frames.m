function pc=overlap_frames(cia,ATCA,noFL,hilow)
%
%function overlap_frames(cia,ATCA,noFL,hilow)
%
% A utility that will assist in quantifying and listing overlapping high
% frames (=-3/1/3) in two data sets.  'cia' contains the CumulativeIntervalArray 
% that lists only the  high frames (hilow=1) or only the low frames (hilow=0)
% in the first data set, and ATCA contains the 
% Intervals.AllTracesCellArray from the second data set.  Use in testing
% the Bayesian spot pick (D. Theobald) where we are here searching for high
% events in our high signal reference channel ('cia') and asking whether
% those co-localizations were also detected in our low signal channel
% ('ATCA'). 
%
% cia == CumulativeIntervalArray from imscroll that lists high events in
%          our first data set when hilow=1, and will list low events in our first
%          data set for hilow=0.
%  (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#
% ATCA ==  AllTracesCellArray from our second data set.  Will be used to
%        inspect individual traces to determine whether frames from high intervals
%         listed in cia are also high in the traces of ATCA (second data
%         set)
% noFL== will be 1 if we are to ignore the first and last frames of each
%        event b/c they are likely partial frames and thus of low S/N
%        (in which case the events in cia should be chosen so as to be >= 3
%        frames in duration).  (ignore 1 frame on each end for hilow=1, and
%        ignore 5 frames on each end for hilow=0).
% hilow==1/0 Set to '1' for the program to find overlapping high frames
%        (in which case 'cia' lists' only frames known to be high) and set 
%        to '0' for the program to find overlapping low frames (in which 
%        case the 'cia' listst only frames known to be low)
% output == lists individual frames from the input cia of high (low) events with
%       each frame specified as being detected as a high (low) event in the second data
%       set (1) (will be 1 for detection of a high event (highlow=1) and will
%       also be set to 1 for detection of a low event (hilow=0) or not detected 
%       as a high (low) event in the second data set (0)
%  (low or high =-2,0,2 or -3,1,3) (frame #) (1/0=detected/(not detected) )  (delta frames) (delta time (sec)) (interval ave intensity)  AOI#
%
%  For example, with hilow=1 and cia containing a list of high events the
%  program 'output' will list '1' in column 2 for overlapping high events
%  and with hilow=0 and cia containing a list of low events the program
%  'output' will list '1' in column 2 for overlapping low events.
%
% see also MultistatIntervals

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

[rose col]=size(cia);           % rose =# of events listed in cia
if hilow==1
    AddSubFrames=1;             %  When noFL==1 we ignore 1 frame on each end of a high interval
else
    AddSubFrames=2;             %  Wneh noFL==1 we ignore 5 frames on each end of a low interval
end

% First get a count of the size for the output matrix
ciadum=cia;
if noFL==1
    ciadum(:,2)=ciadum(:,2)+AddSubFrames;
    ciadum(:,3)=ciadum(:,3)-AddSubFrames;
    ciadum(:,4)=ciadum(:,4)-AddSubFrames*2;
end
outsize=sum(ciadum(:,4));       % This will be the number of rows in the 
                                % output matrix (one row per frame).



count=1;            % Initialize count of coincident high frames in the two data sets
FrameEvent=zeros(outsize,7);
for eventindx=1:rose
    
    
            % cycle through all the events
    Event=cia(eventindx,:);          % This high event
    aoinum=Event(1,7);         % AOI for this event

    if noFL==1             
                            % Here if we ignore the beginning and ending
                            % frame for this event
        Event(1,2)=Event(1,2)+AddSubFrames;    % Increment starting frame by 1
        Event(1,3)=Event(1,3)-AddSubFrames;   % Decrement ending frame by 1
    end
    
    for frmindx=Event(1,2):Event(1,3)
                        % Cycle through all frames of this event
    logikfrm=ATCA{aoinum,13}(:,2)==frmindx;    % Pick out row for this frame number
    onefrmevent=Event;                 % row from input cia
    if ATCA{aoinum,13}(logikfrm,3)==hilow             % True if this frame is also high (low)
                                                    % i.e. if this frame agrees with the hi/low
                                                    % state listed in the
                                                    % cia input for the first data set 
                                 % Increment count of coincident high frames
        
        onefrmevent(1,2)=frmindx;          % Alter beginning and ending frame to be the same
                                           % since we are recording coincidences for single frames
        onefrmevent(1,3)=1;                 % Mark colmn 3 as a 1 since co-localization was detected in second data set of ATCA
    else
                % Here if frame  was not detected high in second data set
                % of ATCA
        onefrmevent(1,2)=frmindx;          % Alter beginning and ending frame to be the same
                                           % since we are recording coincidences for single frames
        onefrmevent(1,3)=0;                 % Mark colmn 3 as a 0 since co-localization was NOT detected in second data set of ATCA
    end                      % end of if ATCA{ } ...
    FrameEvent(count,:)=onefrmevent;
    count=count+1;                          % increment frame count
    
    end                                 % End cycling through frames for this event
end                         % End cycling through events of the cia
pc=FrameEvent;
