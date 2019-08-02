function pc=fetchframes_mapstruc_cell_v1(mapentry,mapstruc_cell,handles)
%
% function fetchframes_mapstruc_cell_v1(mapentry,mapstruc_cell,handles)
%
% Will be called from the gauss2d_mapstruc program in order to fetch image frames
% for fitting spot parameters.
%
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% mapentry == the index into the mapstruc_cell
% mapstruc_cell == structure array each element of which specifies:
% mapstruc_cell == structure array each element of which specifies:
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc
%                           =2 use last [amp aoix aoiy sigma offset]
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc
%                           =-2 guess new [amp sigma offset], but aoixy from last output
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =3 to use glimpse files
%                           =2 to use 'images' array as image source
%                           =1 to use folder as image source

% V1 remove dum, images,folder from arguements
% We use mapstruc_cell{mapentry,1} throughout, taking frame number, pixnum etc all from the first aoi =1 

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

if isfield(handles,'TiffFolder')
    folder=handles.TiffFolder;
end

frameAverage = mapstruc_cell{mapentry,1}.aoiinf(2);       % Number of frames to ave (first frame)
framenumber = mapstruc_cell{mapentry,1}.aoiinf(1); % First frame number
if mapstruc_cell{mapentry,1}.folderuse ==1         %  = 0 for using folder
    dum=uint32(imread([folder],'tiff',framenumber));
    dum=dum-dum;                               % zeroed array same size as the images
    for aveindx=framenumber:framenumber+frameAverage-1         % Read in the frames and average them
        
        %dum=imadd(dum,uint32(imread([folder],'tiff',aveindx)));
        dum=dum+uint32(imread([folder],'tiff',aveindx));
    end
    
elseif mapstruc_cell{mapentry,1}.folderuse ==2
    % Here to ave over the
    % frames in 'images'
    dum=sum(images(:,:,framenumber:framenumber+frameAverage-1),3);
elseif mapstruc_cell{mapentry,1}.folderuse ==3          % Here to Glimpse file images
    dum=uint32( glimpse_image(handles.gfolder,handles.gheader,framenumber) );
    dum=dum-dum;                           % zeroed array same size as the images
    for aveindx=framenumber:framenumber+frameAverage-1        % Read in the frames and average them
        
        
        %dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
        dum=dum+uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) );
        
    end
end

%pc=imdivide(dum,ave);                           % Divide by number of frames to get the 
pc=dum/frameAverage;                                                % average for output to the
                                                % calling program.


