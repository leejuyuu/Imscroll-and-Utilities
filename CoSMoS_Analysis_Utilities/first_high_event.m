function pc=first_high_event(cia,minfrm)
%
% function first_high_event(cia minfrm)
%
% Will output a cia-like list of events in a cia matrix that are first high
% events in an AOI.  These first high events must also be greater than or
% equal to minfrm.
%
% cia == input cia array
% minfrm == high events must be >= minfrm frames in duration
% firstframe == flag to set =1 => include events that begin on first frame (-3 type events) 
%                           =0 do not include first frame events
% 
% OUTPUT.landsf == cia-like array list of qualifying events
% OUTPUT.ciaindx == list of indices into the input cia array for those
%                    qualifying events

[rose col]=size(cia);
landsf=[];
ciaindx=[];
flag=0;     % Initialize flag=0 means do not get events
for indx=1:rose
    if flag==1      % Here if we are looking for first high event
                    % that will satisfy length criteria
        if ( (cia(indx,1)==1)|(cia(indx,1)==3) )&(cia(indx,4)>=minfrm)
            landsf=[landsf;cia(indx,:)];
            ciaindx=[ciaindx;indx];
            flag=0;
        end
    elseif cia(indx,1)==-2  % Here if we are not searching for the first
                            % high event (we already found one and flag=0).  We are
                            % instead looking for the beginning of a new
                            % AOI.
        flag=1;             % Set flag to 1 when we have found the line in cia
                            % indicating a new AOI.  This occurs b/c
                            % cia(indx,1)==2 is true
    end
end
pc.landsf=landsf;
pc.ciaindx=ciaindx;

