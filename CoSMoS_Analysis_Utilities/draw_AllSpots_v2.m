function pc=draw_AllSpots_v2(AllSpots,frame,driftlist,varargin)
% function draw_AllSpots_v2(AllSpots,frame,driftlist,<UniqueLandingRadius>,<MinimumLandingNumber>,<DrawUniqueBoxes>,<Image4Gaussians>,<TiffFolderGaussians.)
%
% Will draw all the spots detected by the auto spot picker in imscroll and
% stored in the AllSpots structure.  The spots will be drawn at their
% location in the specified 'frame' using the driftlist to compensate for
% drift.  If UniqueLandingRadius is specified the function will output an
% aoiinfo2 structure containing a list of aois located at the landing sites.  
% Those aois (landings) are culled so that no two aois will be closer than
% a distance specified by UniqueLandingRadius (units: pixels)
%
% AllSpots == structure stored by imscroll following auto spot picking of
%            fluorescent spots throughout a specified framed range
% frame == all the detected spots will be drift corrected and plotted at
%         their xy location in this 'frame'.  
% driftlist = [frm#  deltax   deltay  (glimpse time)] driftlist that will
%           be used to correct locations of the detected spots
% UniqueLandingRadius == <optional> the list of output aois in aoiinfo2 will be culled 
%                        so that no two aois will be closer than a distance
%                        specified by UniqueLandingRadius (units: pixels)
% MinimumLandingNumber == <optional> minimum number of landings necessary to be
%                    included in the output list of unique aoi groupings
% DrawUniqueBoxes == <optional> any entry (e.g. = 0,1,'Y',etc)
%                     will mean that the unique boxes (subject to
%                     MinimumLandingNumber) are also to be drawn
% Image4Gaussians == m x n matrix containing an image upon which gaussians
%                will be superimposed.  There will be one gaussian spot
%                drawn at the location of each detected landing.  The input 
%                image can be e.g. all zeros or might be a frame taken during
%                a glimpse sequence
% TiffFolderGaussians= e.g. 'p:\image_data\image4gaussians.tif' foler in which to
%                       write the superimposed gaussian image
%  ********************************
% OUTPUT WILL BE IN THE FORM OF A STRUCTURE WITH MEMBERS DEFINED AS:
% out.xytotal = [x y] list of ALL drift-corrected landing locations
%
% out.UniqueXY = [x  y  (number of landings)] 
%       =[(unique, averaged landing group xy locations)  (number of landings in this grouping)]
%
% out.aoiinfo2 = [(frame#)    ave     x     y     pixnum     aoi#  ]
% out.Image4Gaussians = image with superimposed gaussian at locations of
%                     drift-corrected landings
%                      

% v1 Larry F. 4-18-2012 added aoiinfo2 structure as output along with the 
%    specification of unique landings (unique aois), 3 optional arguements

% Copyright 2012 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.


frms=AllSpots.FrameVector;      % List of frames over which we found spots
        
[rose col]=size(frms);
        
 hold on 
 landingcount=0;        % landingcount == total number of landings found for all the frames
for indx=1:max(rose,col)
                        % count the total number of landings
   spotnum=AllSpots.AllSpotsCells{indx,2}; % number of spots found in the current frame     
   landingcount=landingcount+spotnum;
end
xytot=zeros(landingcount,2);        % Reserve space for the list of all landing xy pairs
totindx=1;                          % Running index into the xytot matrix;
for indx=1:max(rose,col)                           % Cycle through frame range
    XYshift=[0 0];                  % initialize aoi shift due to drift
                    
                    
                                    % Fake aoiinfo structure (one entry) specification frame being the indx (i.e. frame for spot detection)  
    %aoiinfo=[indx 1 0 0 5 1];
    aoiinfo=[frms(indx) 1 0 0 5 1];
                                    % Get the xy shift that moves each spot detected in frame=indx to the current frame=imval   
    XYshift=ShiftAOI(1,frame,aoiinfo,driftlist);
                 
            
    spotnum=AllSpots.AllSpotsCells{indx,2}; % number of spots found in the current frame
    xy=AllSpots.AllSpotsCells{indx,1}(1:spotnum,:);     % xy pairs of spots in current frame
       
    xy(:,1)=xy(:,1)+XYshift(1);     % Offset all the x coordinates for the detected spots
    xy(:,2)=xy(:,2)+XYshift(2);     % Offset all the y coordinates for the detected spots
    xytot(totindx:totindx+spotnum-1,:)=xy;  % Add the xy list from this frame to the total list
    totindx=totindx+spotnum;        % Increment the index for the xytot array
    %plot(xy(:,1),xy(:,2),'ro','MarkerSize',3.0);                % Plot the spots for current frame
end
plot(xytot(:,1),xytot(:,2),'ro','MarkerSize',3.0); 
hold off
pc.XYtotal=xytot;
pc.XYtotalDescription='[x y] list of all drift-corrected landing locations'; 
inlength=length(varargin);
if inlength>0
                            % Here to make output aoiinfo2 structure for
                            % the landings.  We will remove excess landings
                            % by grouping landings into aois that are a
                            % minimum distance between one another
   
    UniqueLandingRadius=varargin{1}(:); 
    UniqueXY=Find_Unique_xy(xytot,UniqueLandingRadius);
    pc.UniqueXY=UniqueXY.UniqueList;    % List of unique xy locations at the positions of averaged grouped landings 

    pc.UniqueXYDescription='[x  y  (number of landings)] = [(unique, averaged landing group xy locations)  (number of landings in this grouping)]';
    [urose ucol]=size(pc.UniqueXY);           % Get dimensions of unique site list
    aoiinfo2=zeros(urose,6);                    % Allocate space for aoiinfo2 output matrix
        % aoiinfo2 = [(frame#)          ave           x  y     pixnum        aoi#  ] 
    %keyboard
    aoiinfo2=[frame*ones(urose,1) ones(urose,1) pc.UniqueXY(:,1:2) 5*ones(urose,1) [1:urose]'];
    pc.aoiinfo2=aoiinfo2;
    pc.aoiinfo2Description = '[(frame#)    ave     x     y     pixnum     aoi#  ]';
    
                            
end                     % end of if inlength>0
if inlength>1
                % Here to limit the aoiinfo2 list to those xy locations
                % having at least a number of landings equal to 'MinimumLandingNumber'
    MinimumLandingNumber=varargin{2}(:);
    logik=pc.UniqueXY(:,3)>=MinimumLandingNumber;   % number of landings is >= MinimumLandingNumber
    pc.aoiinfo2=pc.aoiinfo2(logik,:);
end
if inlength>2
                % Here to draw the unique aoi boxes
    draw_aois(pc.aoiinfo2,1,5,[1 0 0]);
end 
if inlength>3
                % Here to superimpose gaussians
    Image4Gaussians=double(varargin{4});        % Use this image to draw gaussians
    [ImageYRows ImageXCols]=size(Image4Gaussians);
    
    XImage=ones(ImageYRows,1)*[1:ImageXCols];     % Matrix with every entry being the column index
                                            % with same dimensions as Image4Gaussians 
                                          % e.g.  [1 2 3; 1 2 3; 1 2 3; 1 2 3]
      
    YImage=[1:ImageYRows]'*ones(1,ImageXCols);  % Matrix with every entry being the row index
                                            % with same dimensions as Image4Gaussians
                                     % e.g. [1 1 1; 2 2 2; 3 3 3; 4 4 4]
   
    amp=100;                    % Gaussian amplitude used for each spot
    sigma=2;                    % Gaussian sigma used for each spot
    [rosetot coltot]=size(xytot);   % rosetot = total number of landings
    rosetot
    for totindx=1:rosetot
                                % Sum over all drift-corrected landing coordinates xytot
                                % Add a gaussian at the location of each landing 
        Image4Gaussians=Image4Gaussians+amp*exp(-( (XImage-xytot(totindx,1)).^2 + (YImage-xytot(totindx,2)).^2)/(2*sigma^2) );
    if totindx/1000==round(totindx/1000)
        totindx
    end
    end
end
pc.Image4Gaussians=uint32(Image4Gaussians);
pc.Image4GaussiansDescription='Image with Gaussians superimposed at all drift-corrected landing locations';
if inlength>4
    TiffFolderGaussians=varargin{5};
        % Here to write image as tiff file.  We will display this in imscroll 
        % so as to easily adjust contrast/brightness
        mx=max(max(pc.Image4Gaussians));
        if mx>64000;
                    % imwrite will only write up to 16 bit images
            TiffImage=double(pc.Image4Gaussians*60000/mx);
            TiffImage=uint16(TiffImage);
        else
            TiffImage=uint16(pc.Image4Gaussians);
        end
        imwrite(TiffImage,TiffFolderGaussians,'Compression','none');
        for imindx=1:4
                    % stack 4 more identical images in the same file 
            imwrite(TiffImage,TiffFolderGaussians,'Compression','none','WriteMode','append');
        end
end
