function RefaoifitsMinusBkgnd = SmoothBackground_v5(Bkgndaoifits, SGsmooth, Refaoifits,~)
%
% function SmoothBackground_v5(bkgndaoifits, SGsmooth, Refaoifits, <parenthandles>)
%
% Used to smooth the background traces recorded via imscroll gui by choosing
% AOIs made with 'make bkgnd AOI circle'
% There will be several background AOIs associated with each reference AOI,
% and this routine will ave and smooth those background AOIs (removing bad
% outlier jumps in the background traces.
%
% Bkgndaoifits == aoifits structure (stored by imscroll) for the background
%            AOIs chosen using the  'make bkgnd AOI circle' operations
% AOInums == 1 x N vector list of AOIs for which the function will obtain
%            smoothed background traces.  There is a reference set of AOIs
%            and each background trace is associated with one of the
%            reference AOIs.  This list of AOInums refers to the index
%            running over the reference AOIs.
% Refaoifits == aoifits structure (stored by imscroll) for the reference
%            AOIs.  It is the traces from these referece AOIs for which we
%            we seek to subtract a background.  Once the background is
%            subtracted, the trace baseline should be at zero.
% SGsmooth == [ SG_PolyOrder   SG_Frames]  parameter for Savitsky-Golay
%            smoothing of background traces, where
% SG_PolyOrder==   parameter specifying the order of polynomial
%               used in Savitsky-Golay smoothing
% SG_Frame ==   parameter specifying the window size (number of points) used
%              for Savitsky-Golay smoothing.  (must be odd) e.g. = 41
% Output.data == data member same as Refaoifits.data, but the output has
%             had the smoothed background trace subtracted off
% Output Bkdata == a data listing containing the smoothed background data
% v4  This version differs from version 2 in that we fit the integrated
%    intensity values from the background AOIs to a plane in order to
%    determine the appropriate background value at the reference AOI.  In
%    version 2 we were just averaging the values from the background AOIs
%    to determine the background value at the reference AOI.
% v5 We still use fitting to a plane in this version.  We have added a
%     detrending of the final smoothed trace using the function
%     DetrendAfterBackgroundSubtraction.m  This helps to remove a small
%     amount of baseline offset in some of the traces (see that function for
%     more explanation).

% Copyright 2018 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

% Protocol:   Our Reference AOIs (Refaoifits) are circled by several close
% background AOIs (Bkgndaoifits).  We first average the data trace from the
% background AOIs, and smooth that averaged trace.  The background traces
% might still show nonspecific landings or dirt noise we would like to
% avoid so we frame-by-frame compute the std dev of the background AOI values
% We then compute the mean value of that std dev along the trace. = MeanStd
% We then re-compute the average background trace, eliminating outliers
% (that deviate from the prior average trace by more than 4*MeanStd).  That
% re-computed average is then smoothed and subtracted from the data AOI
% trace.
%.....................................................................................
%% allocate space and getting informations
% Save space for output.  We will later replace the data traces.
RefaoifitsMinusBkgnd=Refaoifits;
%Replicate the data list.  We will replace these with the final
% smoothed background traces that we use
RefaoifitsMinusBkgnd.Bkdata=Refaoifits.data;

% List of AOI numbers in our reference Refaoifits
AOInums=Refaoifits.aoiinfo2(:,6);

% Will store a list of those reference AOIs for which
% we are unable to subtract a background (b/c there are
% no neighboring AOIs associated with them in the
% background AOI set we chose).


nAOIs = length(AOInums);
nFrames = length(Refaoifits.data(:,2))/nAOIs;
% Will store a list of those reference AOIs for which
% we are unable to subtract a background (b/c there are
% no neighboring AOIs associated with them in the
% background AOI set we chose).
isAOIsWithoutBkgndSubtraction = false(nAOIs,1);
frameCol = Refaoifits.data(1:nAOIs:end,2);

%% Subtract background one by one
for iAOI = AOInums'
    if iAOI/20==round(iAOI/20)
        fprintf('processing AOI %d\n',iAOI);
    end
    
    iRefAOI = AOInums(iAOI);
    
    %picking out the x, y coordinates and intensities of this ref AOI
    logikRef = Refaoifits.data(:,1) == iRefAOI;
    refTrace = Refaoifits.data(logikRef,8);
    refXY = Refaoifits.data(logikRef,[4,5]);
    
    
    % Pick out the aoiinfo2 list of background AOIs that pair with the
    % current value of reference AOI
    %[(framenumber when marked) ave x y pixnum aoinumber]
    BkgndaoiNumbers=Bkgndaoifits.aoiinfo2(Bkgndaoifits.RefAOINearLogik{iRefAOI},6);
    nBkgAOIs = length(BkgndaoiNumbers);
    
    if nBkgAOIs > 0
        
        % Here if we are able to subtract background AOIs for the current
        % reference AOI specified by iAOInum
        
        % Picking out the x, y coordinates and intensities of those
        % background aois
        bkgTrace = zeros(nFrames,nBkgAOIs);
        % The strange indexing here is because later we need to get xy coordinates
        % without yeilding a 3D matrix (so nFrames is the last dimensions)
        bkgXY = zeros(nBkgAOIs,2,nFrames);
        
        for iBkgAOI=1:nBkgAOIs
            logikBkgAOI=Bkgndaoifits.data(:,1)==BkgndaoiNumbers(iBkgAOI);
            bkgTrace(:,iBkgAOI) = Bkgndaoifits.data(logikBkgAOI,8);
            bkgXY(iBkgAOI,:,:) = Bkgndaoifits.data(logikBkgAOI,[4,5])';
        end
        
        medianBkgTrace = median(bkgTrace,2);
        % Large deviations of baseline do not show up in these values of median,
        % just the noise of the pts in each
        % frame.  Median is less subject to large deviations by a single bkgnd AOI
        
        SmoothedMedianTrace=sgolayfilt(medianBkgTrace,SGsmooth(1),SGsmooth(2));
        % Find the background trace with the smallest std deviation from
        % the smoothed median background trace.
        
        % Calculate std for the difference (bkgnd trace) - (smoothed median background trace)
        Std_SmoothedMedianBkg = zeros(nBkgAOIs,1);
        for iBkgAOI = 1:nBkgAOIs
            Std_SmoothedMedianBkg(iBkgAOI) = std(bkgTrace(:,iBkgAOI)-SmoothedMedianTrace);
        end
        % Minimum standard deviation of (bkgnd trace)-(smoothed median trace)
        [MinSDBkTraceMinusMedianTrace, I]=min(Std_SmoothedMedianBkg);
        
        % Now we look frame-by-frame for outliers among the bkgnd AOIs
        % We throw out pts that are more than 4*MeanStd off the SmoothedAveTrace trace
        
        AveBkgndTraceNoOuts = zeros(nFrames,1);
        for iFrame=1:nFrames
            
            % Excluding outliers
            % Retain bkgnd values only within 4*MinSDBkTraceMunusMedianTrace of smoothed background
            logikPassedBkgAOI=abs(bkgTrace(iFrame,:)-SmoothedMedianTrace(iFrame))<4*MinSDBkTraceMinusMedianTrace;
            if sum(logikPassedBkgAOI)>2
                % Need at least three points to fit to a plane
                % planedata = (x,y,z) vectors
                planedata = [bkgXY(logikPassedBkgAOI,:,iFrame), bkgTrace(iFrame,logikPassedBkgAOI)'];
                % Outputs [A1  A2  A3] where z=A1*x + A2*y + A3
                Aparm = fitLinearLeastSquare3DPlane(planedata);
                % Interpolate background on the ref aoi coordinate using that fitted plane
                AveBkgndTraceNoOuts(iFrame) = sum(Aparm.*([refXY(iFrame,:),1]));
            elseif sum(logikPassedBkgAOI)>0
                % Here if we cannot fit to a plane (<3 background points) but
                % we still have 1 or 2 good background points
                
                % Form ave of all the bkgnd traces (having frame-by-frame removed the outlier bkgnd AOIs)
                AveBkgndTraceNoOuts(iFrame)=mean(bkgTrace(iFrame,logikPassedBkgAOI));
            else
                % If all the traces contain outliers, the we just retain the
                % dataonly(I,:) value from above, which is the value from
                % the one bkgnd trace with minimum std dev of (bkgnd trace)-(smoothed median trace)
                AveBkgndTraceNoOuts(iFrame) = bkgTrace(iFrame,I);
            end
        end
        % Smooth the averaged background trace
        SmoothedAveTraceNoOuts = sgolayfilt(AveBkgndTraceNoOuts,SGsmooth(1),SGsmooth(2));
        
        % Subtract the smoothed background trace from reference AOI trace.
        RefTraceMinusBkgnd = refTrace- SmoothedAveTraceNoOuts;
        
        % At this point RefTraceMinusBkgnd still has a little baseline offset sometimes
        % So for this version 5 we use DetrendAfterBackgroundSubtraction to help remove that
        % small amount of offset
        RefTraceMinusBkgnd_subBaseline=DetrendAfterBackgroundSubtraction([frameCol, RefTraceMinusBkgnd],MinSDBkTraceMinusMedianTrace);
        % output=[(frame number)  (final trace)]
        
        % Replace field 'Bkdata' with the smoothed ave bkgnd trace
        RefaoifitsMinusBkgnd.Bkdata(logikRef,8)=SmoothedAveTraceNoOuts;
        % Replace the data entries for the current AOI
        % with background corrected, baseline-corrected data
        RefaoifitsMinusBkgnd.data(logikRef,8)=RefTraceMinusBkgnd_subBaseline(:,2);
        
    else
        % Here if we are UNABLE to subtract background AOIs for the current
        % reference AOI specified by refAOInum=AOInums(indxroot)
        
        % Add this reference AOI to our list of AOIs for which we did
        % not subtract the background
        isAOIsWithoutBkgndSubtraction(iRefAOI) = true;
        sprintf('No background AOIs for ref AOI number %i',iRefAOI)
    end
end
% Add member listing reference AOIs for which we were
% unable to subtract a background (no
% neighboring AOIs in our chosen bkgnd AOI set)
RefaoifitsMinusBkgnd.AOIsWithoutBkgndSubtraction = AOInums(isAOIsWithoutBkgndSubtraction);
% Output an aoifits structure containing a pc.data with background
% corredted data, and pc.Bkdata containing a data
% listing with the smoothed background data.
end
% We formed the ave and median trace of all the background AOIs for a particular Reference AOI (=SmoothedMedianTrace).
%{ We found the trace with the minimum deviation from the SmoothedMedianTrace, and the std dev of that difference:-->MinSDBkTraceMinusMedianTrace
%{ Averaged all the background traces, but omitted points in a trace that are more than 4*MinSDBkTraceMinusMedianTrace away from the SmoothedMedianTrace
%{ -->AveBkgndTraceNoOuts  (average background trace with no outliers included) - -
%{ Smoothed the AveBkgndTraceNoOuts-->SmoothedAveTraceNoOuts, then subtracted it from the associated Reference AOI data trace -->  RefaoifitsMinusBkgnd.data
%{ Also retained the SmoothedAveTraceNoOuts for each Reference AOI -->  RefaoifitsMinusBkgnd.Bkdata


