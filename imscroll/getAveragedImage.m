function image = getAveragedImage(fileProperty,CurrentFrameNumber,FrameAverage)
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
tempImageSum = zeros(fileProperty.height,fileProperty.width,'uint32');
switch fileProperty.fileType
    case 1
        % popup menu 'Tiff_Folder'
        for aveindx = CurrentFrameNumber:CurrentFrameNumber+FrameAverage-1
            tempImageSum = tempImageSum + uint32(imread(fileProperty.filePath,'tiff',aveindx)) ;
        end
    case 3
        % popup menu 'Glimpse_Folder'
        % use Glimpse file directly
        for aveindx=CurrentFrameNumber:CurrentFrameNumber+FrameAverage-1
            tempImageSum = tempImageSum + uint32(glimpse_image(fileProperty.filePath,fileProperty.gheader,aveindx));
        end
    otherwise
        error('Error in getAveragedImage.m \nImage type is not supported in this version%s','')
end
image = tempImageSum/FrameAverage;
end






