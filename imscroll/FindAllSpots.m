function pc=FindAllSpots(handles,maxnum,imageFileProperty)
%
%  function FindAllSpots(handles,maxnum)
% gfolder,frmrange,frmlimits,NoiseDiameter,SpotDiameter,SpotBrightness
% Will use spot picking algorithm to find all the spots in each frame
% defined by the frmrange.
% handles == handles structure of the calling program ( imscroll() )
% maxnum == maximum # of spots in each frame (for preallocating arrays:
%       too high means you have too many spots, nonspecific interactions or
%       some other problem)

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


FrameRange = eval([get(handles.FrameRange,'String') ';']);
frameAverage = round(str2double(get(handles.FrameAve,'String')));

nFrames = length(FrameRange);
% preallocate the arrays for
% storing spot information
AllSpots.AllSpotsCells=cell(nFrames,3);  % Will be a cell array {N,3} N=# of frames computed, and
% AllSpots{m,1}= [x y] list of spots, {m,2}= # of spots in list, {m,3}= frame#

AllSpots.AllSpotsCellsDescription='{m,1}= [x y] list of spots in frm m, {m,2}= # of spots in list, {m,3}= frame#]';
AllSpots.FrameVector=FrameRange;         % Vector of frames whose spots are stored in AllSpotsCells
AllSpots.Parameters=[ handles.NoiseDiameter handles.SpotDiameter handles.SpotBrightness];
AllSpots.ParametersDescripton='[NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots';
AllSpots.aoiinfo2=handles.FitData;       % List of AOIs user has chosen
AllSpots.aoiinfo2Description='[frm#  ave  x  y  pixnum  aoi#]';



xlow=1;
xhigh=imageFileProperty.width;
ylow=1;
yhigh=imageFileProperty.height;
% Initialize frame limits
if get(handles.Magnify,'Value')==1                  % Check whether the image magnified (restrct range for finding spots)
    limitsxy=eval( get(handles.MagRangeYX,'String') );  % Get the limits of the magnified region
    % [xlow xhi ylow yhi]
    xlow=limitsxy(1);xhigh=limitsxy(2);            % Define frame limits as those of
    ylow=limitsxy(3);yhigh=limitsxy(4);            % the magnified region
    
end



for iFrame = FrameRange            % Cycle through all frames, finding the spots
    if iFrame/500==round(iFrame/500)
        fprintf('processing frame %d\n', iFrame);
    end
    
    currentFrameImage = getAveragedImage(imageFileProperty,iFrame,frameAverage);
    % Fetch the current frame (appropriately averaged)
    % If the handles.BackgroundChoice is set to show the user
    % a background-subtracted image, then use that background
    % subtracted image in which to find spots.
    if any(get(handles.BackgroundChoice,'Value')==[2 3])
        % Here to use rolling ball background (subtract off background)
        
        currentFrameImage=currentFrameImage-rolling_ball(currentFrameImage,handles.RollingBallRadius,handles.RollingBallHeight);
    elseif any(get(handles.BackgroundChoice,'Value')==[4 5])
        % Here to use Danny's newer background subtraction(subtract off background)
        
        currentFrameImage=currentFrameImage-bkgd_image(currentFrameImage,handles.RollingBallRadius,handles.RollingBallHeight);
    end
    
    dat=bpass(double(currentFrameImage(ylow:yhigh,xlow:xhigh)),handles.NoiseDiameter,handles.SpotDiameter);
    pk=pkfnd(dat,handles.SpotBrightness,handles.SpotDiameter);
    pk=cntrd(dat,pk,handles.SpotDiameter+2);        % This is our list of spots in this frame FrameRange(frmindx)
    
    [nAOIs,~]=size(pk);
    
    if nAOIs~=0       % If there are spots
        pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
        pk(:,2)=pk(:,2)+ylow-1;
        
        AllSpots.AllSpotsCells{iFrame,1}=pk;
        AllSpots.AllSpotsCells{iFrame,2}=nAOIs;                         % Number of detected spots we store
        AllSpots.AllSpotsCells{iFrame,3}=iFrame;            % Frame number
        
    end
    
end


fprintf('process finished\n');

pc=FreeAllSpotsMemory(AllSpots);                        % Output structure containing cell array with spot record