function pc = RemovePriorLandings(PriorLandingAOIs, ciaLandings)
%
%  function RemovePriorLandings(PriorLandingAOIs,  ciaLandings)
%
% PriorLandingAOIs== vector list of AOI numbers in which we have previously
%                 recorded landing events. 
% ciaLandings == CumulativeIntervalArray (cia) format matrix listing
%            first landing events.  To obtain this apply the function e.g.
%            pc=first_high_event(cia,20), and the pc.landsf member will be
%            the ciaLandingNew matix
%
% OUTPUT:
% out.PriorLandingAOIs== contains the vector list of AOI numbers from the
%              PriorLandingAOIs input plus those AOIs with landings from
%              the ciaLandingsNew matrix
% out.ciaLandingsNew == cia format matrix listing new first landing events
%                  culled from the ciaLandings input to this function. 
%                  That is, this function will process the ciaLandings
%                  input matrix by removing any AOIs in that matrix that
%                  appear in the PrioLandingAOIs list.  The remaining
%                  events contained in out.ciaLandingsNew are those in AOIs
%                  not appearing in the PriorLandingAOIs.

%  cia description =          column (1)                   (2)         (3)           (4)            (5)               (6)                 (7)  
%                    (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#
  
[PLArose PLAcol]=size(PriorLandingAOIs);
if PLArose<PLAcol
    PriorLandingAOIs=PriorLandingAOIs';     % Insures that PriorLandingAOIs is a column vector hereafter
end

pc.ciaLandingsNew=[];
[rose col]=size(ciaLandings);
for indx=1:rose
    logik=ciaLandings(indx,7)==PriorLandingAOIs;    % Compare AOI number for each event in ciaLandings with those in PriorLandingAOIs
    if ~any(logik)
        pc.ciaLandingsNew=[pc.ciaLandingsNew;ciaLandings(indx,:)];
    end
end

[roses cols]=size(pc.ciaLandingsNew);
if roses==0
    NewAOIs=[];     % Here if there were no new landings
else
    NewAOIs=pc.ciaLandingsNew(:,7);
end
pc.PriorLandingAOIs=[PriorLandingAOIs;NewAOIs];     % Concatenate list of prior landings with list of AOIs haveing new landings

end


