function pc=getframes_v1(handles)
%
% function getframes_v1(handles)
%
% Will be called from the imscroll program in order to fetch image frames
% for display.
%
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == the folder location of the images to be read
% handles == the handles array from the GUI

% V1  eliminate dum, images, folder from arguements.  Just use handles inputs

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

fileType = get(handles.ImageSource,'Value');
 

CurrentFrameNumber = round(get(handles.ImageNumber,'Value'));        % Retrieve the value of the slider
FrameAverage = round(str2double(get(handles.FrameAve,'String')));   % Fetch the number of frames to ave
                                                  % for display purposes
switch fileType
    case 1   
        % popup menu 'Tiff_Folder'
        tiffPath = handles.TiffFolder;
        dum=uint32( imread(tiffPath,'tiff',CurrentFrameNumber) );
        dum=dum-dum;                                % zero array same size as the images
        for aveindx = CurrentFrameNumber:CurrentFrameNumber+FrameAverage-1         % Read in the frames and average them

           % dum=imadd(dum,uint32( imread([folder],'tiff',aveindx) ) );
            dum=(dum+uint32(imread(tiffPath,'tiff',aveindx) ) );
        end

    case 2
        % popup menu 'RAM'
        % Here to ave over the frames stored in 'images' variable
        images=handles.images;
        dum=sum(uint32(images(:,:,CurrentFrameNumber:CurrentFrameNumber+FrameAverage-1)),3);

    case 3
        % pupup menu 'Glimpse_Folder'
        % use Glimpse file directly
   
         dum=uint32(glimpse_image(handles.gfolder,handles.gheader,CurrentFrameNumber) );
         dum=dum-dum;                               % Zeroed array same size as the images
         for aveindx=CurrentFrameNumber:CurrentFrameNumber+FrameAverage-1         % Read in the frames and average them

            %dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
            dum=dum+uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) );
         end
         setGlimpseInfoCurrentFrame(CurrentFrameNumber,handles)
         


         
     
    case 4
        if get(handles.MagChoice,'Value')==13
            % Here if ImageSource value is 4, so the aoiImageSet must exist
            % Also MagChoice is 13 so we display only calibration images
            % near to the chosen AOI.  We use the AOI displayed in the
            % AOINumberDisplay text region, the nearby calibration image number
            % from the GlimpseNumber text region and the Class ID from the
            % ImageClass popup menu.

            NearNumber=str2num(get(handles.GlimpseNumber,'String'));    % =1 for nearest calibration image, =2 for next nearest,etc
            ClassNumber=get(handles.ImageClass,'Value');         % 1:8=[ROG RO RG OG R O G Z]
            aoiNum=str2num(get(handles.AOINumberDisplay,'String'));    % AOI # from the AOINumberDisplay
            aoiXY=handles.FitData(aoiNum,3:4);                  % (x y) of AOI# in AOINumberDisplay

            NI=Nearest_Images(aoiXY, ClassNumber, handles.aoiImageSet,NearNumber);

            FrameAverage=1;                                      % The image stored in AOIImageSet is already averaged
            dum=NI.images(:,:,NearNumber);              % Fetch one calibration image that is 'NearNumber' down in the list
                                                % of calibration images nearest to our current AOI 
        else 
            % pupup menu 'aoiImageSet'
            % image the averaged registered images
            % from the aoiImageSet
             FrameAverage=1;     % Stored image in aoiImageSet is already averaged
             aoiNum=str2num(get(handles.AOINumberDisplay,'String'));    % AOI # from the AOINumberDisplay
             dum=handles.aoiImageSet.centeredImage{aoiNum}.FrameAve;    % Averaged image registered to pixel center
        end
end

% Divide by number of frames to get the average for output to the calling program.
pc=dum/FrameAverage;                                






