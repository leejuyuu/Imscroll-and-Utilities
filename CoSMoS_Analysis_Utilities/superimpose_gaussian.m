function pc=superimpose_gaussian(fp,frames,folder,gamp,gsigma,xyRange,xyCenter,xyCenterRange,threshrange)
%
% function pc=superimpose_gaussian(fp, frames, folder, gamp, gsigma, xyRange, xycenter, xyCenterRange,threshrange)
%
% This function will superimpose a gaussian into a frame of existing data
% for the purpose of determining the auto spot picker brightness threshold
% necessary for detecting the gaussian spot.
%
% fp ==path the glimpse folder containing the image frames upon which the
%    gaussian will be superimposed
% frames == 1D vector of frame numbers that will be used as images upon
%           which the gausssian will be imposed.  Only one frame will be 
%           used at a time, and that will be randomly chosen from the list
% folder == full path\name to a tiff folder that will be written by this
%           function.  That tiff file will contain 10 identical images
%           consisting of the original image frame from the glimpse file
%           with the superimposed gaussina  
%           e.g.  folder='c:\larry\image_data\tiff_images\test.tif'
% gamp == gaussian amplitude as written by the gaussian_spot( ) function.
% gsigma == gaussian sigma as written by the gaussian_spot( ) function.
% xyRange == extent of the gaussian as written by the gausian_spot( )
%            function.  For example, if xyRange=20 the superimposed
%            gaussian will range from -20 to +20 in the x and y axis, so
%            the superimposed matrix will be 41 x 41 is size.
% xyCenter == [x y] coordinates for the gaussian center, with the x and y
%             coordinates references to the glimpse image.
% xyCenterRange== a single integer number.  The center coordinates for the
%                 superimposed gaussian will stochastically range over 
%                 xycenter + or - xyCenterRange.  e.g. if 
%                 xycenter=[100 100] and xyCenterRange = 10, then the x and
%                 y center of the gaussian will stochastically fall between
%                 90 and 110.
% threshrange == e.g. 0:10:200  range of thresholds used to test spot
%            detection.  User may need to adjust this to cover appropriate
%            range for the spots occuring events in a particular experiment 
% OUTPUT: the highest value of brightness
% for which the gaussian spot was detected
% i.e. for which the gframeplus image
 % had more detected spots than the gframe image 
fn='header.mat';                 % Header file in glimpse folder
eval(['load ' [fp fn] ' -mat']) % Load the vid structure
lframes=length(frames);
%tbl=[ frames' ones(lframes,1)*1/lframes];   % Probabilty table for picking a frame
tbl=[ frames' ones(lframes,1)];   % Probabilty table for picking a frame
frame=probability_steps(tbl,1);             % Stochastically pick a frame from the list
gframe=uint16(glimpse_image(fp,vid,frame));         % Grab the glimpse frame
                        % Generate an xCenter value ranging between
                        % xyCenter(1)-xyCenterRange to xyCenter(1)+xyCenterRange 
xCenter=round(xyCenter(1)+(rand(1)-.5)*2*xyCenterRange);
                        % Generate an yCenter value ranging between
                        % xyCenter(2)-xyCenterRange to xyCenter(1)+xyCenterRange 
yCenter=round(xyCenter(2)+(rand(1)-.5)*2*xyCenterRange);
timage=uint16(gaussian_spot(gamp,gsigma,[0 0],1,xyRange));
                        % Superimpose the gaussian and glimpse image
gframeplus=gframe;      % Duplicate the initial frame
                        % Superimpose the gaussian onto the grameplus
gframeplus(yCenter-xyRange:yCenter+xyRange,xCenter-xyRange:xCenter+xyRange)=uint16(gframe(yCenter-xyRange:yCenter+xyRange,xCenter-xyRange:xCenter+xyRange)+timage);
                        % Write the first frame of the output tiff file
imwrite(gframe,folder,'Compression','none');
                        % Write 4 more frames identical to the first
for indx=1:4
    imwrite(gframe,folder,'tiff','Compression','none','WriteMode','append');
end
                    % Next 5 frames have the superimposed gaussian
for indx=1:5
    imwrite(gframeplus,folder,'tiff','Compression','none','WriteMode','append');
end
pc=1;
            % *************
            % Now we will find the maximum spot brightness thrreshold that detects
            % the superimposed gaussian.  We will do this by comparing the number
            % of spots detected in the original frame and the modified
            % frame
%brightness=5:150;           % Range of spot threshold values we will test
%brightness=10:10:400;
brightness=threshrange;
lb=length(brightness);
numb=zeros(lb,2);
numbplus=zeros(lb,2);

for indx=1:lb
    dat=bpass(double(gframe),1,5);
    pk=pkfnd(dat,brightness(indx),5);
    pk=cntrd(dat,pk,5+2);
    [gnumb colm]=size(pk);              % gnumb will be the number of spot
                                        % detected at this value of brightness 
    numb(indx,:)=[brightness(indx) gnumb];
                            % Next, detect the spot in the image+superimposed gaussian
    datplus=bpass(double(gframeplus),1,5);
    pkplus=pkfnd(datplus,brightness(indx),5);
    pkplus=cntrd(dat,pkplus,5+2);
    [gnumbplus colm]=size(pkplus);              % gnumb will be the number of spot
                                        % detected at this value of brightness 
    numbplus(indx,:)=[brightness(indx) gnumbplus];
end
logik=numbplus(:,2)>numb(:,2);          % number of brightness values for 
                                        % which we detected more spots (one
                                        % more, due to the gaussian) in the
                                        % gframeplus image compared to the
                                        % gframe image
 mx=max(find(logik));                   % Find the highest index of logik indicating
                                        % that the number of spots in gframeplus exceeds 
                                        % the number found in gframe
pc=numbplus(mx,1);                      % Output the highest value of brightness
                                        % for which the gaussian spot was detected
                                        % i.e. for which the gframeplus image
                                        % had more detected spots than the gframe image 
        
      % dat=bpass(double(avefrm(ylow:yhigh,xlow:xhigh)),handles.NoiseDiameter,handles.SpotDiameter);
      % pk=pkfnd(dat,handles.SpotBrightness,handles.SpotDiameter);
      % pk=cntrd(dat,pk,handles.SpotDiameter+2);






