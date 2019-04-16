function pc=RegisterImage(gfolder,aoiinfo2,HalfOutputImageSize,RoundingPixelFraction, RegisterFlag, varargin)
%
% function RegisterImage( gfolder, aoiinfo2, HalfOutputImageSize, RoundingPixelFraction, RegisterFlag, ,<InputImage>, <gfolderOut>)
%
% Will translate images by a fraction of a pixel in order to register the
% AOI center (from aoiinfo2) to the nearest integer pixel (corresponds to 
% a pixel center).  The routine uses image regions from a glimpse file as 
% specified by the xy coordinate list in the aoiinfo2 variable and the
% 'OutputImageSize' variable.
%
% gfolder == full path to the glimpse-saved folder containing the series of
%           glimpse files
% aoiinfo2 == M x 6 AOI (area of interest) list  of M locations saved by 
%                imscroll.  It specifies the (x y) coordinates AND the frame
%                numbers AND averages for the image region centers that 
%                will be registered by this routine.  If average=5 this 
%                routine will process and output 5 successive frames for 
%                the specified AOI 
%            [frm#  ave  x  y  pixnum  aoi#]
% HalfOutputImageSize == [rxLo rxHi  ryLo ryHi]  units: integer pixels.  Defines 
%            the half-dimensions of the image region that will be output.  
%            Distances are measured relative to the output AOI centers.  
%            e.g. if =[5 5 13 3] the output image will be 11 x 17 pixels.
% RoundingPixelFraction  == [RPFx  RPFy] the output image will be translated 
%            relative to the input so that the output AOI center is moved 
%            to the nearest fractional pixel specified by RoundingPixelFraction.  
%            If =[0  0] the output AOIs will all be centered on the nearest
%            pixel center, while if =[0.25  0.25 the output AOIs will offset 
%            from a pixel center by a 0.25 pixel fraction.
% RegisterFlag ==  Set to 1 if the image is not to be registered (no
%              image translation, just ignore the RoundingPixelFraction 
%              variable).  Set to 0 (will be the case most of the time) in
%              order to translate the image and register it to the nearest
%              fractional pixel specified by RoundingPixelFraction
% InputImage == OPTIONAL set of stacked input images.  If this input is
%              present the routine will ignore gfolder and use these images
%              as the images that will be registered.
% gfolderOut == OPTIONAL folder path for a glimpse file containing all the
%            translated output images.
%
%  output.frames == Output of function will be a stacked set of uint16 images containing the 
%                   image regions registered to the nearest pixel fraction speicified.  
%                    e.g. for 7 AOIs specified in aoiinfo2 and average=3 from each of those AOIS,
%                   RoundingPixelFraction=0, and HalfOutputImageSize=[5 5 13 3] the output 
%                   will be a matrix (rows, column, depth)= (17, 11,21) (NOTE: 21=7*3 because
%                   average=3 for each AOI there will be 3 images output
% output.aoiinfo2_output== [frm#  1  newx  newy  pixnum  aoi#] provides the 
%                   new x and y locations for the AOI center, ave=1 since
%                   individual frames (not averaged) will be output
%

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
sizevar=size(varargin,2);
if sizevar>=1
                % Input images specified (rather than gfolder), so grab them 
    InputImage=varargin{1};
                
    if sizevar>=2
        % Output file specified, so grab it.
        gfolderOut=varargin{1}
    end
end
AOInum=size(aoiinfo2,1);        % Number or AOIs specified (=# rows in aoiinfo2)
eval(['load ' gfolder 'header.mat -mat']);  % Load the vid file
RoundingPixelFraction=abs(RoundingPixelFraction);    % Must be positive
     % Next statement to remove any integer portion, so we translate image
     % only be a pixel fraction
RoundingPixelFraction=RoundingPixelFraction-floor(RoundingPixelFraction);

       % Compute size of the output image
HalfOutputImageSize=round(HalfOutputImageSize);     % Output image size must be integer pixels
rxHi=HalfOutputImageSize(2);
rxLo=HalfOutputImageSize(1);
ryHi=HalfOutputImageSize(4);
ryLo=HalfOutputImageSize(3);
  % Offset out dummy pixel boundaries to insure all the pixel #s are positive  
offset=round(10*(max(RoundingPixelFraction)+max(HalfOutputImageSize)));

dumxHi=round( offset+RoundingPixelFraction(1)+rxHi);      
                                                  % e.g. 9.5 to 10.4999..
                   % will all round to 10 i.e. anwhere w/in pixel 10 will
                   % produce pixel 10 as computed result
dumxLo=round( offset+RoundingPixelFraction(1)-rxLo);
dumyHi=round( offset+RoundingPixelFraction(2)+ryHi);
dumyLo=round( offset+RoundingPixelFraction(2)-ryLo);
xpixelDimension=dumxHi-dumxLo+1;
ypixelDimension=dumyHi-dumyLo+1;
FrameTotal=sum(aoiinfo2(:,2));      % Sum all the averages to obtain the
                                    % frame total
                % Space for the average frame sets
%dumAveFrame=uint16(zeros(ypixelDimension,xpixelDimension,max(aoiinfo2(:,2))));
                % Space for all the output frames
            
frames_output=uint16(zeros(ypixelDimension,xpixelDimension,FrameTotal));
aoiinfo2_output=aoiinfo2;       % We will replace for x, y and ave values below
aoiinfo2_output(:,2)=1;         % All output frames will be single frames (not averaged)
FrameCount=1;
for indx=1:AOInum
                % Cycle through the list of input AOIs
                % Grab entire image
    for aveindx=1:aoiinfo2(indx,2)
        if exist('InputImage')
            % Here if we have input an image rather than a Glimpse folder
            inputWholeImage=uint16(InputImage(:,:,FrameCount));
        else
            % Here to grab image from glimpse folder
            inputWholeImage=glimpse_image(gfolder,vid,aoiinfo2(indx,1)+aveindx-1);
        end
           % Place translated (new) AOI center at proper pixel fraction 
           if RegisterFlag==0
                    % Here to register image
               newX=round(aoiinfo2(indx,3)-RoundingPixelFraction(1))+RoundingPixelFraction(1);
               newY=round(aoiinfo2(indx,4)-RoundingPixelFraction(2))+RoundingPixelFraction(2);
              
           else
                    % Here to NOT register image
               newX=aoiinfo2(indx,3);
               newY=aoiinfo2(indx,4);
           end
           deltaX=newX-aoiinfo2(indx,3);       % Image and AOI translation distance X pixels
           deltaY=newY-aoiinfo2(indx,4);       % Image and AOI translation distance Y pixels
                    % Compute pixel coordinates in inputWholeImage for the
                    % X and Y boundries of the output sub-image
        outxHi=round( newX+rxHi);
        outxLo=round( newX-rxLo);
        outyHi=round( newY+ryHi);
        outyLo=round( newY-ryLo);
                    % Compute output translated image
                   
        frames_output(:,:,FrameCount)=uint16(TranslateImage( inputWholeImage,[deltaX deltaY],[outxLo outxHi outyLo outyHi]));
        FrameCount=FrameCount+1;        % Increment output frame index
                % replace ave and coordinates in aoiinfo2_output
                % Note the AOI centers are with respect to coordinates
                % in the output image (which is in general smaller in
                % size than the input image)
        aoiinfo2_output(indx,2:4)=[1 newX-outxLo+1 newY-outyLo+1];    
    end
end
pc.frames=frames_output;
pc.aoiinfo2_output=aoiinfo2_output; 

        
        
        
        
