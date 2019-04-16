function pc=events_per_aoi_v4(cia,frmhilow,maxevents,EventRestrict,varargin)
%
% function events_per_aoi_v4(cia,frmhilow,maxevents,EventRestrict,<AOIRestrict>)
%
% cia == Cumulative Interval Array from the Intervals structure created in
%        imscroll during interval detection (e.g. dwell times of a binding
%        protein  (=Intervals.CumulativeIntervalArray )
%         Intervals.CumulativeIntervalArrayDescription=
%        [  1:(low or high =-2,0,2 or -3,1,3)      2:(frame start)        3:(frame end)   …    
%        4: (delta frames)        5:(delta time (sec))     6:(interval ave intensity)       7:AOI#   ]
% frmhilow==  [(low frame)  (high frame)]  specifies the frame range that 
%          events must begin between in order to appear in the list
% maxevents == maximum event number tabulated in output matrix output.hist
%              (see below for explanation of output.hist)
% EventRestrict == [mn  mx] =minimum and maximum high event number for the 
%            aois included in the output.ciar output array
% <AOIRestrict> == optional vector list of AOI numbers that will further
%            restrict the contents of just output.ciarh_aoi and
%            output.ciarl_aoi.  i.e those two outputs will only contain
%            high and low (respectively) cia lists from the subset of AOIs
%            specified in the AOIRestrict arguement
%
%
% OUTPUT:   [(AOI #)  (# of low events)  (# of high events) ] 
% output.eventnum ==  [(AOI #)  (# of low events)  (# of high events)]
% output.aoicells ==  A cell array where  The arrays will contain the 
%                      low events ( output.aoicells (m,1)) or high events
%                      (output.aoicells(m,2) )  for the mth AOI in the list
%                      (it may be that  m does not equal the AOI#).  The format
%                      of the cell array is the same as the
%                      Intervals.CumulativeIntervalArray
% output.hist == [(number of high events) (# of aois with that event number)]
%              provides a table listing a number of events (ranging
%              over 0:maxevents) vs the number of aois actually showing
%              that particular event number.  The last row will be:
%              [(maxevents+1)    (# of aois having and event # >=(maxevents+1)]  
% output.ciarh== restricted cia.  contains the cia array for high events for
%              only those AOIs whose event number is between EventRestrict(1)
%              and EventRestrict(2) i.e.
%              EventRestrict(1)   <= (high event number) <= EventRestrict(2)
% output.ciarl== restricted cia.  contains the cia array for low events for
%              only those AOIs whose event number is  between EventRestrict(1)
%              and EventRestrict(2) i.e.
%              EventRestrict(1)   <= (high event number) <= EventRestrict(2)
% output.timehlo= [ (AOI#)  (total low time)  (total high time)] lists the
%              total amount of time spent in the high state and in the low
%              state for each AOI 
% output.ciarh_aoi== derived from output.ciarh, but here we further
%              restrict the AOIs to only those listed in AOIRestrict 
% output.ciarl_aoi==derived from output.ciarl, but here we further
%              restrict the AOIs to only those listed in AOIRestrict

% v1 January 28 2013: added frame restriction arguement, output.hist and
%  the output.ciar
% v2 March 28_2014:  added (total low time) and (total high time) outputs 
%  a new output.timehilo matrix
%  Altered EventRestrict to specify both high AND low number of high events
% v3 May 29_2014 added optional <AOIRestric> arguement to specify a limited
%  set of AOIs that will restrict contents of output.ciarh_aoi and output.ciarl_aoi 
% v4 October 21 2014 fixed function so that it still worked even if some
% AOIs had already been removed by prior editing (so all AOI#s are not present in list)
% Also fixed it so the frmhilow limits worked properly (by allowing an 
% event to be included in the list if it begins within the frmhilow range
% but ends outside the range).
[eventnum ciacol]=size(cia);   % eventnum = number of events listed in cia 
logik=cia(:,1)<0;       % Negative number in first column occurs for start 
                        % events for each AOI
aoinum=sum(logik);      % aoinum = number of aois in list.  Some #s may be 
                        %skipped if prior editing has occurred so it may be
                        %that max(cia(:,7)~=aoinum.
aoicells=cell(aoinum,2);    % Form cell array.  The arrays will contain the 
                            % low events ( cell(m,1)) or high events
                            % (cell(m,2) )  for the mth AOI in the AOI list
starts=find(logik);     % starts = lists the row indices of cia array that enumerate
                        % the first entry for each aoi
mxfrm=max(cia(:,3));    % Highest end frame in cia matrix

for indx=1:aoinum-1
    aoievents=cia(starts(indx):starts(indx+1)-1,:);     % submatrix of cia listing events for aoi = indx
            % Find events that begin w/in the frmhilow range but end
            % outside that range, then change their end frame to be
            % frmhilow(2) so that we do include them in the list (and so we
            % do not end up with AOIs that have zero events.
       logikEventhilo=((aoievents(:,2)>=frmhilow(1))&(aoievents(:,2)<=frmhilow(2)))&(aoievents(:,3)>=frmhilow(2));
       aoievents(logikEventhilo,3)=frmhilow(2);
    logikhigh=((aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3))&(aoievents(:,2)>=frmhilow(1))&(aoievents(:,3)<=frmhilow(2));
    aoicells{indx,2}=aoievents(logikhigh,:);       % Capture and list all the high events
    logiklow=((aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2))&(aoievents(:,2)>=frmhilow(1))&(aoievents(:,3)<=frmhilow(2));
    aoicells{indx,1}=aoievents(logiklow,:);        % Capture and list all the low events
end
            % Now for the last AOI
aoievents=cia(starts(aoinum):eventnum,:);        % submatrix of cia listing events for aoi = indx
            % Find events that begin w/in the frmhilow range but end
            % outside that range, then change their end frame to be
            % frmhilow(2) so that we do include them in the list (and so we
            % do not end up with AOIs that have zero events.
       logikEventhilo=((aoievents(:,2)>=frmhilow(1))&(aoievents(:,2)<=frmhilow(2)))&(aoievents(:,3)>=frmhilow(2));
       aoievents(logikEventhilo,3)=frmhilow(2); 
logikhigh=((aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3))&(aoievents(:,2)>=frmhilow(1))&(aoievents(:,3)<=frmhilow(2));
aoicells{aoinum,2}=aoievents(logikhigh,:);       % Capture and list all the high events
logiklow=((aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2))&(aoievents(:,2)>=frmhilow(1))&(aoievents(:,3)<=frmhilow(2));
aoicells{aoinum,1}=aoievents(logiklow,:);        % Capture and list all the low events
        % Next, loop through each aoi and grab the nth event if it exists (high or low)

eventnum=zeros(aoinum,3);
timehilo=zeros(aoinum,3);            % [ (AOI#)  (total low time)  (total high time)]
%keyboard
for indx=1:aoinum
   
    % Loop through all the aois, getting the number of high and low events
    
    
    [lowrose lowcol]=size(aoicells{indx,1});    % aoicells{m,1} lists (from the rows of the cia matrix) the low events in the mth aoi
    [hirose hicol]=size(aoicells{indx,2});      % aoicells{m,2} lists (from the rows of the cia matrix) the high events in the mth aoi
    if (lowrose >=1)& (hirose>=1)
        % In case one of the matrices is empty
        eventnum(indx,:)=[aoicells{indx,1}(1,7) lowrose hirose];    %aoicells{indx,1}(1,7) is the AOI#
        timehilo(indx,:)=[aoicells{indx,1}(1,7) sum(aoicells{indx,1}(:,5)) sum(aoicells{indx,2}(:,5)) ];
    elseif (lowrose>=1)
        % Here if there were no high events so the high cell is empty
        eventnum(indx,:)=[aoicells{indx,1}(1,7) lowrose hirose];
        timehilo(indx,:)=[aoicells{indx,1}(1,7) sum(aoicells{indx,1}(:,5))   0    ];
    else
        % Here if there were no low events so the low cell is empty
        eventnum(indx,:)=[aoicells{indx,2}(1,7) lowrose hirose];    %aoicells{indx,1}(1,7) is the AOI#
        timehilo(indx,:)=[aoicells{indx,2}(1,7)   0    sum(aoicells{indx,2}(:,5)) ];
    end
    
end
pc.eventnum=eventnum;
pc.aoicells=aoicells;
pc.hist=[];                         % Output array that will list
                                % [(# of high events=event number)  (# of aois with this event number)]  
for indx=0:maxevents
    logik=pc.eventnum(:,3)==indx;
    pc.hist=[pc.hist;indx sum(logik)];
end
logik=pc.eventnum(:,3)>=maxevents+1;
pc.hist=[pc.hist;maxevents+1 sum(logik)];   % Put total # events>maxevents into the last bin
logik=(pc.eventnum(:,3)>=EventRestrict(1)) & (pc.eventnum(:,3)<=EventRestrict(2));
pc.ciarh=[];
pc.ciarl=[];
pc.timehilo=timehilo;
restricted_aois=pc.eventnum(logik,1);       % List of aois with # of high events restricted to be 
                                            % EventRestrict(1)   <= (high event number) <= EventRestrict(2)
%keyboard
for indx=1:length(restricted_aois)                    % Cycle through aois with event numbers set by EventRestrict limits
    logik=( restricted_aois(indx)==pc.eventnum(:,1) );  % Pick out the one entry in the list of AOIs matching the AOI # in our restricted_aois(indx) list
    pc.ciarh=[pc.ciarh;pc.aoicells{logik,2}];  % adding high events to the output list (from aois with event numbers <= maxrestrct 
    pc.ciarl=[pc.ciarl;pc.aoicells{logik,1}];  % adding low events to the output list (from aois with event numbers <= maxrestrct 
end
inlength=length(varargin);
                                                % Grab the AOIRestrict 
                                                % list of AOIs, if present
if inlength>0
    AOIRestrict=varargin{1}(:);         % Vector list of AOIs to include 
    ciah_aoi=[];		
    cial_aoi=[];


    for indx=1:length(AOIRestrict)		% loop through list of restricted AOI set
        logik=pc.ciarh(:,7)== AOIRestrict(indx);	
        ciah_aoi=[ciah_aoi ;pc.ciarh(logik,:)];     % High events from the restricted list
        logik=pc.ciarl(:,7)== AOIRestrict(indx);	
        cial_aoi=[cial_aoi ;pc.ciarl(logik,:)];     % Low events from the restricted list
    end
    pc.ciarh_aoi=ciah_aoi;              % Add to the list of outputs, the high and low cia list
    pc.ciarl_aoi=cial_aoi;              % that is restricted to those events listed in AOIRestrict
end



