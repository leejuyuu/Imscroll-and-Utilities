function pc=AOISpotLanding2(AOInum,radius,radius_hys,AllSpots,AllSpotsLow,shiftedXY)
%
% function AOISpotLanding(AOInum,radius,handles,aoiinfo2,radius_hys)
%
% Will determine whether the spots landing in the field of view (stored in
% handles.AllSpots) occur within the AOI specified by AOInum.  Output will
% be an array [(frame number)  0,1] specifying whether the aoi contained a
% spot during each frame number covered by the handles.AllSpots cell array
%
% AOInum == number of the AOI in the handles.AllSpots.aoiinfo2 list
% radius == pixel radius, proximity of the spot to the AOI center in order
%          to be counted as a landing
% handles == handles structure containing members
%        AllSpots, Driftlist
% aoiinfo2 == [frm#  ave  x  y  pixnum  aoi#]  listing of information about the aois in use

% Copyright 2015 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.


frameRange = AllSpots.FrameVector;  
nFrames = length(frameRange);   
[nFramesAllspotCells, ~] = size(AllSpots.AllSpotsCells);

if nFramesAllspotCells~=nFrames
    error('Error in AOISpotLanding: FrameRange and AllSpot sizes disagree')
end
pc = zeros(nFrames,2);  
AmpHighLow=0;
for iFrame = 1:nFrames
   
    xycoord = shiftedXY(AOInum,:,iFrame);     
    
    % This is for the spots found with the High amplitude threshold
    % Distances btwn our AOI and spots found using high amplitude threshold
    distanceshigh = spotsDistance(xycoord,AllSpots.AllSpotsCells{iFrame,1});
    
    % Distances btwn our AOI and spots found using Low amplitude threshold
    distanceslow = spotsDistance(xycoord,AllSpotsLow.AllSpotsCells{iFrame,1});
    if any(distanceshigh<radius)
       
        AmpHighLow=1;
            elseif (AmpHighLow==1) && any(distanceslow<radius*radius_hys)
        % Here if the last frame was high and this frame
        % satisfies only a relaxed criteria (hysterisis) for
        % being in a high state (lower amplitude spots, larger
        % distance between spots and AOI center)
            else
        % Here is there was no spot close to our AOI center
        AmpHighLow=0;
        
    end
    % [frame number, AmpHighLow]
    pc(iFrame,:)=[AllSpots.AllSpotsCells{iFrame,3}, AmpHighLow];
end

end
