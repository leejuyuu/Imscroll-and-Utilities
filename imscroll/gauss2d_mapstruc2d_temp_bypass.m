function pc=gauss2d_mapstruc2d_temp_bypass(mapstruc_cell,parenthandles,imageFileProperty)
%
% function gauss2d_mapstruc2d_v2(mapstruc_cell,parenthandles,handles)
%
% This function will apply a gaussian fit to aois in a series of images.
% The aois and frames will be specified in the mapstruc structure
% images == a m x n x numb array of input images
% mapstruc_cell == structure array each element of which specifies:
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc_cell 
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc_cell 
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == the folder location of the images to be read
%       
% parenthandles == the handles arrary from the top level gui
% handles == the handles array from the GUI
%
%  The function will make use of repeated applications of gauss2dfit.m

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



fitChoice = get(parenthandles.FitChoice,'Value');
if fitChoice == 5
    aoiProcessParameters = getAoiProcessParameters(parenthandles);
    
    pc = getAoiIntensityLinearInterp(imageFileProperty,parenthandles.FitData,...
        aoiProcessParameters,parenthandles.DriftList);
elseif fitChoice == 1
        
    if get(parenthandles.BackgroundChoice,'Value') ~= 1
        error('background choice is not supported in this version')
    end
    if ~isfield(parenthandles,'Pixnums') || isempty(parenthandles.Pixnums)
        % Here if user did not set the small AOI size for integration
        % or parenthandles.Pixnums exists but is empty, 
        % when gaussian fitting with a fixed sigma
        parenthandles.Pixnums(1) = mapstruc_cell{1,1}.aoiinf(5); % Width of aoi in first aoi
        guidata(parenthandles.FitAOIs,parenthandles)
    end
    % get the first averaged frame/aoi
    firstfrm = fetchframes_mapstruc_cell_v1(1,mapstruc_cell,parenthandles);
    
    [nFrame, nAOI] = size(mapstruc_cell);      % naois =number of aois, nfrms=number of frames
        
    % Pre-Allocate space
    
    ImageDataParallel(:,:,nFrame)=zeros(nAOI,8);
    BackgroundDataParallel(:,:,nFrame)=zeros(nAOI,8);
    
    % Pre-Allocate space
    LastxyLowHigh = zeros(nAOI,4);          
    % When gaussian tracking an aoi we must use the last xy location
    % as input to the next xy fit.  Hence we store the last set of xy values
    % for just one frame.
    
    for aoiindx = 1:nAOI
        
        % Limits for the aoi
        aoiy = mapstruc_cell{1,aoiindx}.aoiinf(4);  % Y (row) Center of aoi
        aoix = mapstruc_cell{1,aoiindx}.aoiinf(3);  % X (col)center of aoifram
        pixnum = mapstruc_cell{1,aoiindx}.aoiinf(5); % Width of aoi
        [xlow, xhi, ylow, yhi] = AOI_Limits([aoix aoiy],pixnum/2);
        LastxyLowHigh(aoiindx,:) = [xlow xhi ylow yhi];
        
        firstaoi = firstfrm(ylow:yhi,xlow:xhi);        
        inputarg0 = guessStartingParameters(firstaoi);
          
        % Now fit the first frame aoi
        outarg=gauss2dfit(double(firstaoi),double(inputarg0));
        % Reference aoixy to original frame pixels for
        % storage in output array.
        
        % aoiinf = %[(frms columun vec)  ave         x         y                           pixnum                       aoinum]
        % aoiinf is a column vector with (number of rows)= number of frames to be processed
        % The x and y coordinates already contain the shift from DriftList (see build_mapstruc.m)
        % [aoi#     frm#       amp    xo    yo    sigma  offset (int inten)]
        FirstImageData=[aoiindx   mapstruc_cell{1,aoiindx}.aoiinf(1)   outarg(1)   outarg(2)+xlow   outarg(3)+ylow   outarg(4)   outarg(5)   sum(sum(firstaoi))];
                               
        ImageDataParallel(aoiindx,:,1)=FirstImageData;  %(aoiindx, DataIndx, FrameIndx)
                
    end             % End of aoiindx loop through all the aois for the first frame
    
    
    %Now loop through the remaining frames
    for framemapindx=2:nFrame        
        
        if framemapindx/10==round(framemapindx/10)
            framemapindx
        end
        % Get the next averaged frame to process
        currentfrm=fetchframes_mapstruc_cell_v1(framemapindx,mapstruc_cell,parenthandles);
        
        for aoiindx2=1:nAOI   % Loop through all the aois for this frame
            
            pixnum=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(5); % Width of current aoi
            
            TempLastxy=LastxyLowHigh(aoiindx2,:);
            xlow=TempLastxy(1);xhi=TempLastxy(2);ylow=TempLastxy(3);yhi=TempLastxy(4);
            
            currentaoi=currentfrm(ylow:yhi,xlow:xhi);                
            
            inputarg0 = guessStartingParameters(currentaoi);
            
            % Now fit the current aoi
            outarg=gauss2dfit(double(currentaoi),double(inputarg0));
            ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(currentaoi))];
            
        end             %END of for loop aoiindx2
        
        
        if get(parenthandles.TrackAOIs,'Value')==1
            
            % Here for moving aoi (last output aoixy)
            % Save the last fit xy locations
            for aoiindx3=1:nAOI
                lastoutput=ImageDataParallel(aoiindx3,:,framemapindx);
                pixnum=mapstruc_cell{framemapindx,aoiindx3}.aoiinf(5); % Width of aoi
                [Txlow, Txhi, Tylow, Tyhi]=AOI_Limits([lastoutput(4) lastoutput(5)],pixnum/2);
                LastxyLowHigh(aoiindx3,:)=[Txlow Txhi Tylow Tyhi];
                
            end
        else
            % Here for non-moving aoi, just use fixed aoi coordinates stored in the mapstruc_cell{frm#,aoi#}
            for aoiindx4=1:nAOI
                aoiy=mapstruc_cell{framemapindx,aoiindx4}.aoiinf(4);  % Y (row) Center of aoi
                aoix=mapstruc_cell{framemapindx,aoiindx4}.aoiinf(3);  % X (col)center of aoifram
                pixnum=mapstruc_cell{framemapindx,aoiindx4}.aoiinf(5); % Width of aoi
                [xlow, xhi, ylow, yhi]=AOI_Limits([aoix aoiy],pixnum/2);
                LastxyLowHigh(aoiindx4,:)=[xlow xhi ylow yhi];
                
            end
        end
        
    end           % end of for loop framemapindx
    
    % Pre-Allocate space
    pc.ImageData(nAOI*nFrame,:)=zeros(1,8);
    pc.BackgroundData(nAOI*nFrame,:)=zeros(1,8);
    
    % ImageDataParallel(aoiindx,DataEntryIndx,FrmIndx)
    % Reshaping data matrices for output
    % The form ImageData and BackgroundData matrices was required to
    % satisfy the parallel processing loop requirements for indexing
    
    for frameindex=1:nFrame
        pc.ImageData((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=ImageDataParallel(:,:,frameindex);
        pc.BackgroundData((frameindex-1)*nAOI+1:(frameindex-1)*nAOI+nAOI,:)=BackgroundDataParallel(:,:,frameindex);
    end
else
    
    error('the chosen fitting method isn''t supported in this version')
end
end

function inputarg0 = guessStartingParameters(aoiImage)
% starting parameters for fit
%[ ampl xzero yzero sigma offset]
pixnum = length(aoiImage(:, 1));
mx = double( max(max(aoiImage)) );
mn = double( mean(mean(aoiImage)) );
inputarg0 = [mx-mn pixnum/2 pixnum/2 pixnum/4 mn];
end

