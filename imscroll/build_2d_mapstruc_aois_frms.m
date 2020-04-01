function mapstruc_cell = build_2d_mapstruc_aois_frms(handles)
%
% function build_2d_mapstruc_aois_frms(folder,handles)
%
% This function will be called from imscroll.  It is part of a renovation
% that will enable us to process all aois in a frame rather than loading a frame
% to process a single aoi.  Previously the mapstruc was built to direct the
% processing of a single aoi (a 1D array of structures for one, one
% structure per frame).  This function will build a 2D array of structures,
% with one dimension (first index, rows),for all the frames (as before) and 
% the other dimension for all the aois (second dimension, columns).
% 
% folder == file path and name locating the folder for the tiff file (if used)
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source

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

% Fetch the pixel number (aoi width)
pixnum = str2double(get(handles.PixelNumber,'String')); 

frameRange = eval([get(handles.FrameRange,'String') ';']');
% Vector of frames that will be processed
nFrames = length(frameRange);

frameAverage = round(str2double(get(handles.FrameAve,'String')));  % Number of frames to average
aoiinf = handles.FitData;                         % AOIs selected earlier (AOI button, tag=CollectAOI)
%[framenumber ave x y pixnum aoinumber];
[maoi, ~] = size(aoiinf);                       % maoi is the number of aois
% Now successively fit each AOI over the
mapstruc_cell = cell(nFrames,maoi);                 % cell array of structures, runs over(aois,frames)
% specified frame range

% Find out if user wants a fixed or moving aoi, startparm=1 for fixed, startparm=2 for moving
startparameter = get(handles.StartParameters,'Value');
switch startparameter                          % This switch is not necessary yet, but will be when
    % more choises are added
    case 1
        inputstartparm = 1;                      % Fixed AOI
    case 2
        inputstartparm = 2;                      % Moving AOI
    case 3
        inputstartparm = 2;
    case 4
        inputstartparm = 2;
end

for iAOI = 1:maoi
    aaa = [1, frameAverage, aoiinf(iAOI,3), aoiinf(iAOI,4), pixnum, aoiinf(iAOI,6)];
    oneaoiinf = repmat(aaa,nFrames,1);
    oneaoiinf(:,1) = frameRange;
    
    % build column of mapstruc_cell.  Column is an array of structures
    % for a single aoi, all frames
   
    mapstruc_cell(:,iAOI)=build_mapstruc_cell_column(oneaoiinf,inputstartparm,handles);

end

end

