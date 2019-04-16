function pc=spot_numbers_v1(fp,frames,thresholds,NdSd,frmave,varargin)
%
% function pc=spot_numbers_v1( fp,  frames,  thresholds,  NdSd, frmave, <roi> )
%
% This will determine the number of spots detected by the auto picker
% over a range of threshold values, and in the specified frames.  The spots
% detected will need to also be within the specified region of interest
%
%
% fp ==path the glimpse folder containing the image frames upon which the
%    gaussian will be superimposed
% frames == 1D vector of frame numbers in which the spots will be detected
% thresholds == vector of threshold values for which the number of spots
%            will be detected.
% NdSd ==[(Noise Diameter)  (Spot Diameter)] settings for the spot
%          detection
% frmave== frame average.  The number of frames to average prior to
%        detecting spots.
% roi == region of interest.  Optional mask defining region in which the
%           spots will be detected.  Create the mask using the command:
%            roi=roipoly;

% Copyright 2014 Larry Friedman, Brandeis University.
fn='header.mat';                 % Header file in glimpse folder
eval(['load ' [fp fn] ' -mat']) % Load the vid structure
lframes=length(frames);
lthresh=length(thresholds);
pc=cell(1,lframes);         % Output cell array.  One cell for each frame
for indx=1:lframes;                             % Initialize outputs
    pc{indx}=zeros(length(thresholds),5);       % [frame#  (Noise Diameter) (Spot Diameter) (threshold value) (number of spots)]
end
NoiseDiameter=NdSd(1);
SpotDiameter=NdSd(2);
if length(varargin)>0
    roi=varargin{1};            % Define the optional mask for spot counting w/in the frame
end

            % Loop through frames
for frmindx=1:lframes
    frames(frmindx)
    pc{frmindx}(:,1)=ones(lthresh,1)*frames(frmindx);
    pc{frmindx}(:,2)=ones(lthresh,1)*NoiseDiameter;
    pc{frmindx}(:,3)=ones(lthresh,1)*SpotDiameter;  
    
                % Average the number of frames set by 'frmave' arguement
    gframe=uint32( glimpse_image(fp,vid,frames(frmindx)) );
    gframe=gframe-gframe;                               % Zeroed array same size as the images
    for aveindx=frames(frmindx):frames(frmindx)+frmave-1         % Read in the frames and average them

       
        gframe=gframe+uint32( glimpse_image(fp,vid,aveindx) );
    end    
        gframe=gframe/frmave;                           % Normalize by number of frames averaged
       %gframe=uint16(glimpse_image(fp,vid,frames(frmindx)));         % Grab the glimpse frame
            % Now loop through the values of the threshold brightness
    for threshindx=1:length(thresholds)
        %threshindx
        dat=bpass(double(gframe),NoiseDiameter,SpotDiameter);
        pk=pkfnd(dat,thresholds(threshindx),SpotDiameter);
        pk=cntrd(dat,pk,SpotDiameter+2);
        pk=round(pk);                   % Round x y values to nearest pixel
       [gnumb colm]=size(pk);              % gnumb will be the number of spot
                                        % detected at this value of brightness
        
        if length(varargin)>0
            
            spotcount=0;                    % initialize spot count
            for spotindx=1:gnumb
                if roi(pk(spotindx,2),pk(spotindx,1))==1;    % will be true only if pk(spotindx,:) spot is w/in mask region defined by roi
                    spotcount=spotcount+1;
                end
            end
        else
                        % If there is no roi mask, we just include in the 
                        % count all the spots that were found
            spotcount=gnumb;
        end
        pc{frmindx}(threshindx,4:5)=[thresholds(threshindx) spotcount];
    end
end
        







