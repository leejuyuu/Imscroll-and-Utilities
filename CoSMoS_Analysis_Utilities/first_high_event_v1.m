function pc=first_high_event_v1(cia,minfrm,firstframe)
%
% function first_high_event_v1(cia minfrm,firstframe)
%
% Will output a cia-like list of events in a cia matrix that are first high
% events in an AOI.  These first high events must also be greater than or
% equal to minfrm.
%
% cia == input cia array
% minfrm == high events must be >= minfrm frames in duration
% firstframe == set to =1 => include events that begin on first frame (-3 type events) 
%                           =0 do not include first frame events
% 
% OUTPUT.landsf == cia-like array list of qualifying events
% OUTPUT.ciaindx == list of indices into the input cia array for those
%                    qualifying events
% LJF 9/16/2013:  v1 put in 'firstframe' arguement
[rose col]=size(cia);
landsf=[];
ciaindx=[];
flag=1;     % Initialize flag=1 => search for first high event
for indx=1:rose
    if flag==1      % Here if we are looking for first high event
                    % that will satisfy length criteria
            %               -3 here in case AOI #1 (we initialize loop w/ flag=1) begins w/ high event  
        if (( (cia(indx,1)==-3)&(firstframe==1)) |(cia(indx,1)==1)|(cia(indx,1)==3) )&(cia(indx,4)>=minfrm)
            landsf=[landsf;cia(indx,:)];
            ciaindx=[ciaindx;indx];
            flag=0; % Already found first high event for this AOI, do not search anymore until the next AOI
        end
    elseif ( (cia(indx,1)==-3)&(firstframe==1))&(cia(indx,4)>=minfrm)
        landsf=[landsf;cia(indx,:)];    % Here if we are looking for next AOI and found next AOI that begins w/ a high event  
        ciaindx=[ciaindx;indx];
        flag=0; % Already found first high event for this AOI, do not search anymore until the next AOI
    elseif cia(indx,1)==-2  % Here if we are not searching for the first
                            % high event (we already found one and flag=0).  We are
                            % instead looking for the beginning of a new
                            % AOI, and cia(indx,1)==-2 says we found a new AOI.   
        flag=1;             % Set flag to 1 when we have found the line in cia
                            % indicating a new AOI.  This occurs b/c
                            % cia(indx,1)==-2 is true
    end
end
pc.landsf=landsf;
pc.ciaindx=ciaindx;

