function pc=Find_Unique_xy(xytot,Unique_Landing_Radius)
%
% pc=Find_Unique_xy(xytot,Unique_Landing_Radius)
% 
% This function will output an
% aoiinfo2 structure containing a list of aois located at the landing sites.  
% specified in the xytot list.  Those aois (landings) are culled so that no 
% two aois will be closer than a distance specified by UniqueLandingRadius 
%
% xytot ==[x y] m x 2 list of aoi centers.  This was originally a list of
%         landing sites found by the automatic spot picker.
% UniqueLandingRadius == the list of output aois in aoiinfo2 will be culled 
%                        so that no two aois will be closer than a distance
%                        specified by UniqueLandingRadius (units: pixels)
[landingcount colmn]=size(xytot);       % landingcount = starting # of aois in list
                                        % xolmn = 2

xytotdummy=xytot;       % Dummy matrix to save intermediate results
xyindx=1;                   % Index of xytot() designating member being tested as being a unique aoi
toptotindx=landingcount;    % Gives the remaining highest index number of aoi (landing)locations
                                % in the xytot list that have not yet been
                                % eliminated in our tests for unique aoi locations.
 % That is, in each cycle we remove entries in xytot that overlap with other aoi (landing) locations.
 % the toptotindx is just the total number remaining entries in the xytot list.  
 % If UniqueNum= (number of unique aoi sites), we only need to perform our logical test a maximum
 % of UniqueNum times in order to identify all the unique sites.  
 % 
xyindxdummy=[1:landingcount]';
while xyindx<toptotindx
                                % Measure distances from current member of xytot to all 
                                % remaining members lower in the list  
        dtest=sqrt( (xytot(:,1)-xytot(xyindx,1)).^2 + (xytot(:,2)-xytot(xyindx,2)).^2 );
        % 10000 criterion means we pick only from remaining list of xy
        % entries, not from the 1E6 entries at bottom of list
        % We also include the current xytot member under test in our logical list of TRUEs.  
        %         (10000>distance > radius) OR (entry is current member under test); 
        logik=( (dtest>Unique_Landing_Radius)&(dtest<10000) )| (xyindxdummy==xyindx);
                      % logik picks our remaining landings that differ from
                      % current test member of xytot, plus current test member of xytot
                      % (removes all other members that are from same set as current test member of xytot)  
                 
        toptotindx=sum(logik);    % Reset number of remaining members in our list
                                  % of possible unique sites
                                  % Number of maximum unique aois (landings) (keeps decreasing as we loop
        
        xytot(1:toptotindx,:)=xytot(logik,:);   % Retain only the remaining possible unique xy sites in list
        xytot(toptotindx+1:landingcount,:)=ones(length([toptotindx+1:landingcount]),2)*1E6;
        xyindx=xyindx+1;        % Advance the index of the member under test
    
                % Cycle through all the landings
end
UniqueList=[ xytot(1:toptotindx,:) zeros(toptotindx,1)];
                % Now, for each of the unique entries in pc, we find all
                % its members in the orginal list, and average their
                % positions.
for indx=1:toptotindx
    distance=sqrt( (xytotdummy(:,1)-UniqueList(indx,1)).^2 + (xytotdummy(:,2)-UniqueList(indx,2)).^2);
    logik=distance<Unique_Landing_Radius;       % Find all members of this group of landings
    UniqueList(indx,1)=mean(xytotdummy(logik,1));
    UniqueList(indx,2)=mean(xytotdummy(logik,2));
    UniqueList(indx,3)=sum(logik);              % Number of landings in this group
end
pc.UniqueList=UniqueList;
pc.XYtotal=xytot;

