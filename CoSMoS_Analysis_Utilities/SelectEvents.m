function pc=SelectEvents(aoifits,vid,fignum)
%
% function SelectEvents(aoifits,vid,fignum)
% 
% Will assist in finding the landing of a second colocalized protein.  We
% automatically cycle through all the AOIs and have the user click on the
% regions in the trace that contain events with two bound dye-proteins.
% If a displayed trace contains such twofer events the user will hit a 'y' key. 
% The user should apply two left clicks at the box corners that enclose 
% an event.  When finished with identifying events the user should right
% click.  In order to advance to the next trace the user should hit the
% space bar.
% aoifits == aoifits output from the awesome imscroll gui program.  The
%          form of aoifits.data is:
%   [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]
% vid == header for this glimpse sequence (need the time base)
% fignum == figure number to use
% output.cia == cia matrix defining all intervals with twofer events
%   The form of the cia array is:
% (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#
% output.EventCells== cell array listing the user specified high events for
%                 each AOI.  Form of cell for ith AOI is: 
%        output.EventsCells{i} = [(starting frame)  (ending frame)]
% output.ciaCells == cell array containing one cia for each AOI
%
% input keys:  
%     SP(spacebar)== done with this AOI, move onto next
%     a== repeat current AOI (user made a mistake and wants to repeat
%     f== move forward by one AOI (no additional results stored)
%     b== move backward by one AOI (no additional results stored)
%     i== input AOI number (program then jumps to that AOI number)
%     l== load file containing ongoing EventCells and ciaCells
%     s== store results up to this point in EventCells.dat

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

 

tb=(vid.ttb-vid.ttb(1))*1e-3;   % Reference zero time to first frame, convert to seconds
load FileLocations.dat -mat     % Load this file to save intermediate results in the data directory

                    % Note that the AOI numbers need not be continuous.
                    % Enumerate list of AOIs in data set
data=aoifits.data;
AOIvector=[];
for indx=min(data(:,1)):max(data(:,1))
    if any(indx==data(:,1))     % Is AOI#=indx in list of AOis?
        AOIvector=[AOIvector;indx]; % If yes, add it to our list
    end
end
aoinum=length(AOIvector);          % Number of AOIs in our data set


[mdat ndat]=size(data);

                            % Break data into stacked matrices, one for
                            % each aoi
aoirows=(mdat/aoinum);
dat=zeros(aoirows,ndat,aoinum);
for indx=1:aoinum
    logik=data(:,1)==indx;       % pick out all rows for this aoi
                                % Fill in output stacked matrix
    dat(:,:,indx)=data(logik,:);
  
end
%cia=[];                             % Initialize output cia
ciaCells=cell(aoinum,1);              % Initialize output cia cells
EventCells=cell(aoinum,1);          % Initialize output EventCell matrix
indx=1;
while indx<=aoinum
    if indx<1
        indx=1;        % Error check in case user does something wrong
    end
                    % cycle through all the AOIs
                    %subcia=[];      % cia for just this AOI
    frmvec=dat(:,2,indx);           % Vector of frame numbers for this AOI   

    flagg1=0;
                    % Using two while loops in order to start over on this
                    % AOI in case user makes a mistake
  
    while flagg1==0
                       % flagg1=1 when we finish with this AOI and wish to
                       % increment indx to indx+1 and begin working on the
                       % next AOI
        if indx<1
        indx=1;        % Error check in case user does something wrong
        end               
                                          % Plot one AOI and input twofer events
        EventList=[];           % List of twofer intervals
        figure(fignum);hold off;plot(dat(:,2,indx),dat(:,8,indx),'b');hold on;title(['AOI number ' num2str(AOIvector(indx))]);shg    % Plot frame vs (integrated intensity)
        flagg2=0;               % flagg2=1 until we finish marking events for this AOI
                                % alternatively flagg2=1 if the user wishes to jump
                                % to another AOI and begin to mark it
                                % instead (user alters indx)
        while flagg2==0

        [xycorner button]=func_gbox; % Draw a box or signal an end or restart for this AOI
                                % xycorner =[x1 x2 y1 y2]= [xmin xmax ymin ymax]  
                        % a ==again for this AOI,  b==back to prior AOI ,
                        % f== forward by one AOI, i==user input AOI number
                        % l==load prior EventCells, 's'==store results up to this point 
            if (button~=32)&(button~='a')&(button~='b')&(button~='f')& (button~='i')&(button~='l')&(button~='s')   
                                % Here if user did NOT hit a space bar (32) or the 'a' key
                                % or the 'b' (backup), 'f' (forward by one)
                                % or the 'i' (input an indx valu),or the 'a', 'l' or 's' keys
                                % record the box that the user did outline
                                % Find the trace points w/in the drawn box
               logik=(dat(:,8,indx)>=xycorner(3))&(dat(:,2,indx)>=xycorner(1))&(dat(:,2,indx)<=xycorner(2));
               subdat=dat(logik,:,indx);   % highlight just those points w/in box
               %keyboard
               figure(fignum);plot(subdat(:,2),subdat(:,8),'go');shg
                    % Add the min and max frame numbers for this event to the event list  
               EventList=[EventList;min(subdat(:,2)) max(subdat(:,2))]  
                            % flagg1 and flagg2 still = 0, so we will go
                            % grab another event
           elseif button ==32
            % Here if user hits space bar => to to next AOI
                flagg1=1;
                flagg2=1;
                [r3 c3]=size(EventList);
                if r3~=0
                    [Y I]=sort(EventList(:,1));
                    EventCells{indx}=EventList(I,:);    % Store the EventList in ascending order
                end
            elseif button=='a'
            % Here if user hits 'a' for 'again' in order to start over on this AOI
                flagg2=1;
                    % flagg1 still = 0 so we will reinitialize EventList
                    % and start over for this AOi
            elseif button=='b'
                    % 'b' to go back one AOI and redo it
                indx=indx-1;
                flagg2=1;
            elseif button=='f'
                    % 'b' to go forward one AOI 
                indx=indx+1;
                flagg2=1;
            elseif button=='i'
                    % 'i' to input an AOI number
                userAOI=input('input an AOI number')
                logik=(AOIvector==userAOI);       % Get the index of the user-specified AOI number
                if sum(logik)==0
                    sprintf('AOI out of range')
                else
              
                indx=find(logik);               % Set our index such that AOIvector(indx)=userAOI.
                flagg2=1;
                end
            elseif button=='l'
                    % 'l' to load EventCells ciaCells from ongoing work
                 [fn fp]=uigetfile;
                 eval(['load ' [fp fn] ' -mat']);
                 flagg2=1;
            elseif button=='s'
                    % 's' to save intermediate results for later continuation
                    % The user can then cntrl/C out of the program
                 cia=[];      % Initiate output cia
                 rosecia=0;   % Initialize row count for output cia matrix
                 for indxx=1:aoinum
                    [roseonecia colcia]=size(ciaCells{indxx});
                    rosecia=rosecia+roseonecia; % Counting all the rows for the output cia matrix
                 end
                 cia=zeros(rosecia,7);       % initialize output cia matrix
                 rcount=1;
                 for indxx=1:aoinum
                    [rc cc]=size(ciaCells{indxx});
                    cia(rcount:rcount+rc-1,:)=ciaCells{indxx};
                    rcount=rcount+rc;       % increment row index for cia matrix
                 end
                 
                 eval(['save ' FileLocations.data 'EventCells.dat EventCells ciaCells cia']);
                 flagg2=1;
            end     % end of if (button ...)    
        end         % End of flagg2
    end             % End of flagg1
    onecia=Events2cia(EventList,frmvec,vid,AOIvector(indx));    % Get single cia matrix for this AOI
    ciaCells{indx}=onecia.cia;

    indx=indx+1;    % increment index for cycling through AOIs
                    % Saving intermediate arrays
    eval(['save ' FileLocations.data 'EventCells_auto.dat EventCells ciaCells']);
end                 % End of while indx <=aoinum
                % We now have a list of event start and ending frames for each AOI in
                % the EventCells cell array, and we need to create a
                % CumulativeIntervalArray (cia) from that list

cia=[];      % Initiate output cia
rosecia=0;   % Initialize row count for output cia matrix
for indx=1:aoinum
    [roseonecia colcia]=size(ciaCells{indx});
    rosecia=rosecia+roseonecia; % Counting all the rows for the output cia matrix
end
cia=zeros(rosecia,7);       % initialize output cia matrix
rcount=1;
for indx=1:aoinum
    [rc cc]=size(ciaCells{indx});
    cia(rcount:rcount+rc-1,:)=ciaCells{indx};
    rcount=rcount+rc;       % increment row index for cia matrix
end
 eval(['save ' FileLocations.data 'EventCells.dat EventCells ciaCells cia']);       
pc.ciaCells=ciaCells;
pc.cia=cia;
pc.EventCells=EventCells;
   
        
            
            
