function pc=getframes_StandAlone(getframesStruc)
%
% function getframes_StandAlone(getframesStruc)
%
%  Will be used with the program gauss2d_StandAlone() in order to retrieve
%  images from a glimpse file (or Tiff later on).
%
% ImageNumber == image number (frame number) of the image sequence that the 
%               subroutine will return as output arguement (may be averaged
%               if so specified by the FitStruc arguement)
% getframesStruc == input structure arguement to the gauss2d_StandAlone program.
%               Contains all the AOI, image sequence location, ave number
%               etc information specifying the fit.
% getframesStruc.ImageNumber == image number in the file that will be retrieved 
% getframesStruc.frmave == number of frames to average (going forward from ImageNumber)
% getframesStruc.gfolder == Glimpse directory holding glimpse file image sequence  
% <getframesStruc.TiffFolder. == <optional >fulldirectory to tiff file holding the stacked tiff images 

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.
if isfield(getframesStruc,'TiffFolder')
    folder=getframesStruc.TiffFolder;
end
imagenum=round(getframesStruc.ImageNumber);        % Retrieve the value of the slider
ave=round(getframesStruc.frmave);   % Fetch the number of frames to ave
                                                  % for display purposes
if isfield(getframesStruc,'TiffFolder')         % execute only if TiffFolder specified
    dum=uint32( imread([folder],'tiff',imagenum) );
    dum=dum-dum;                                % zero array same size as the images
    for aveindx=imagenum:imagenum+ave-1         % Read in the frames and average them

       % dum=imadd(dum,uint32( imread([folder],'tiff',aveindx) ) );
        dum=(dum+uint32( imread([folder],'tiff',aveindx) ) );
    end

else             % Use Glimpse folder (TiffFolder not specified)
                                                % use Glimpse file directly
     eval(['load ' getframesStruc.gfolder 'header.mat -mat'])   % Load vid header file
     dum=uint32( glimpse_image(getframesStruc.gfolder,vid,imagenum) );
     dum=dum-dum;                               % Zeroed array same size as the images
     for aveindx=imagenum:imagenum+ave-1         % Read in the frames and average them

        %dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
        dum=dum+uint32( glimpse_image(getframesStruc.gfolder,vid,aveindx) );
     end
        
     
end

%pc=imdivide(dum,ave);
pc=dum/ave;                                % Divide by number of frames to get the 
                                               % average for output to the
                                                % calling program.
