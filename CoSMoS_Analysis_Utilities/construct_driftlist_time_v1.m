function pc=construct_driftlist_time_v1(xy_cell,vid,CorrectionRange,SequenceLength,SG_Smooth)
%
% function    construct_driftlist_time_v1(xy_cell, vid, CorrectionRange, SequenceLength, Polyorderxy,<SG_Smooth>)
%
% xy_cell==cell array of structures containing the information gleaned from
%         gaussian tracking multiple spots for the purpose of drift correction.
%        e.g.  xy_cell{1}.dat
%              xy_cell{1}.range
%              xy_cell{1}.userange    where
% xy_cell{1}.dat ==one dat matrix containing the x
%         y coordinates of one spot tracked with a gaussian fit in imscroll.
%         Each cell array is of the form
%         obtained by processing an aoifits structure with the
%         dat=draw_aoifits_aois(aoifits,'y') function.  Therefore,
%         dat(:,4,1) contains the x coordinate and dat(:,5,1) the y
%         coordinate
% xy_cell{1}.range==[ low high] frame range that the dat matrix covers.
%         For example we might have xy_cell{1}.range=[100 500] though the
%         image sequence might be [1 2305] i.e. the dat matrx will
%         generally cover a continuous subset of all the imagee, and the data
%         will generally not be useable throughout this range.  the
%         '.range' member lists only the range over which the spot was
%         tracked for this entry, not the range over which the tracked spot
%         contains usefull data (specified in the next entry)
% xy_cell{1}.userange==[low high] useable frame range over which
%         each dat_cell entry x-y coordinates may be used for drift
%         correction.  e.g. xy_cell{1}=[150 450] where the
%         xy_cell{1}.range=[100 500] is a possibility.
% xy_cell{1}.ttb = [(frame #) time]
%              Optional time base from vid.ttb for whatever glimpse file this data
%              was obtained.  Note that the frame# range must match that of
%              the xy_cell{}.dat member.  If no *.ttb member is specified the program will
%              use the vid.ttb from the 'vid' input variable.  This allows
%              a user to specify data from different glimpse files if
%              needed.  If all data is from one glimpse file, just inputing
%              the 'vid' arguement will be sufficient.
% vid == structure from the glimpse image file header.  Among its members are
%       vid.ttb and vid.nframes for the time base (in ms) and  total number of frames
% CorrectionRange==[lowc hic] low and high frame number between which we
%         performing a drift correction in the file.  Generally, the drift
%         correction occurs over just a subset of the frames in the file
% SequenceLength == e.g. 3606 the total number of images in the glimpse
%         image file for which we will construct a driftlist
% PolyOrderxy == [n m] where n and m are integers specifying the polynomial
%         order of fit respectively applied to the x (n) and y (m) drift curves
% SG_Smooth == OPTIONAL parameter for Savitsky-Golay smoothing instead
%               of polynomial smoothing of drift.
%                =[ SG_PolyOrderX   SG_FrameX  SG_PolyOrderY    SG_FrameY]
%                where:
% SG_PolyOrder==   parameter specifying the order of polynomial (X or Y drift)
%               used in Savitsky-Golay smoothing (must be odd). e.g. = 5
% SG_Frame ==   parameter specifying the window size (number of points) used for
%              Savitsky-Golay smoothing.  (must be odd) e.g. = 41 (X or Y drift)
% OUTPUT will be a
% driftlist(SequenceLength,3)=[(frame#) (x difference) (y difference)]
% See B21p53
%
% Usage:
%(1) drifts_time= construct_driftlist_time_v1(xy_cell,vid,CorrectionRange,SequenceLength,Polyorderxy,<SG_Smooth>)
%(2) drifts=driftlist_time_interp(drifts_time.cumdriftlist,vid);
% OR if using gui_drift_correction as the step (1)
% (2) drifts=driftlist_time_interp(Drift.drift_correction_cumfit_glimpse,vid);
%foldstruc.DriftList=drifts.diffdriftlist;

% V1:  LJF 12/6/2013  Add option to use Savitsky-Golay smoothing rather
%                    than just a single polynomial fit.
%  alternatively:
% dat_cell == cell array of dat matrices.  Each dat matrix contains the x
%         y coordinates of one spot tracked with a gaussian fit in imscroll.
%         Each cell array is of the form
%         obtained by processing an aoifits structure with the
%         dat=draw_aoifits_aois(aoifits,'y') function.  For example
%         we might have dat_cell{1}=dat(:,:,2), dat_cell{2}=dat(:,:,5) etc
%         where the different dat() matrices could originate from different
%         aoifits structures.
% datrange_cell== cell array listing the frame range overwhich each
%         dat_cell entry covers.  For example we might have
%         datrange_cell{1}=[50 300] for the dat_cell{1} input,
%         datrange_cell{2}=[100 600] for the dat_cell{2} input, etc
% userange_cell== cell array listing the useable frame range over which
%         each dat_cell entry x-y coordinates may be used for drift correction.
%         e.g. datrange_cell{1}=[100 250], datrange_cell{2}=[150 575], etc
% dat_cell, datrange_cell and userange_cell should all have the same number
% of matching entries.
%
%
%  form the various variables as xcell, ycell, dxcell, dycell, dx, dy,
%  cumx,cumy, fitx, valx fity, valy, ddx, ddy, driftlist
%

[diffx1, diffy1] = calculateDisplacementBetweenFrames(xy_cell, SequenceLength);
cumx = calculateAverageCumulativeDisplacement(diffx1);
cumy = calculateAverageCumulativeDisplacement(diffy1);

crange=CorrectionRange(1):CorrectionRange(2);

% Here to apply Savitsky-Golay smoothing to the
% cumulative drift
SG_PolyOrderX=SG_Smooth(1);
SG_FrameX=SG_Smooth(2);
SG_PolyOrderY=SG_Smooth(3);
SG_FrameY=SG_Smooth(4);
valx=sgolayfilt(cumx(crange),SG_PolyOrderX,SG_FrameX);
valy=sgolayfilt(cumy(crange),SG_PolyOrderY,SG_FrameY);

% Construct the cumulative driftlist from the filtered position
cumdriftlist=zeros(SequenceLength,4);
cumdriftlist(:,1)=1:SequenceLength;
cumdriftlist(crange,2)=valx;
cumdriftlist(crange,3)=valy;

cumdriftlist(1:SequenceLength,4)=vid.ttb;          % Place the time base into the 4th column
% (time base of the glimpse file used for
% constructing this drift list.

% Construct the difference driftlist from the filtered position

ddx=diff(valx);
ddy=diff(valy);
drange=CorrectionRange(1)+1:CorrectionRange(2);
diffdriftlist=zeros(SequenceLength,4);
diffdriftlist(:,1)=1:SequenceLength;
diffdriftlist(drange,2)=ddx;
diffdriftlist(drange,3)=ddy;
diffdriftlist(1:SequenceLength,4)=vid.ttb;             % Place the time base into the 4th column
% (time base of the glimpse file used for
% constructing this drift list.
% Output the driftlist
%
pc.cumdriftlist=cumdriftlist;
pc.diffdriftlist=diffdriftlist;

pc.cumdriftlist_description='[ (frame#)  (cumulative x)  (cumulative y)  (glimpse time)]';
pc.diffdriftlist_description='[ (frame#)  dx  dy   (glimpse time)], e.g. dx(N) = cumulative x(N) - cumulative x(N-1)';
pc.xy_cell=xy_cell;
pc.vid=vid;
pc.SequenceLentgh=SequenceLength;
pc.CorrectionRange=CorrectionRange;
end

function [deltaX, deltaY] = calculateDisplacementBetweenFrames(xy_cell, SequenceLength)
nAOIs = length(xy_cell);

deltaX = zeros(SequenceLength, nAOIs);
deltaY = zeros(SequenceLength, nAOIs);
for iAOI = 1:nAOIs
    % This deals with the case that the tracked range is not the whole
    % sequence.
    trackedRange = xy_cell{iAOI}.range(1):xy_cell{iAOI}.range(2);
    
    % dat=[frm#, (),  (), xcoor, ycoord ...]    
    xyCoord = zeros(SequenceLength, 2);
    xyCoord(trackedRange, :) = xy_cell{iAOI}.dat(:, 4:5);    
    
    % Form the deltaX and deltaX lists
    % deltaX(i, iAOI) is x position difference between frame i and frame i - 1
    deltaX(2:end, iAOI) = diff(xyCoord(:, 1));
    deltaY(2:end, iAOI) = diff(xyCoord(:, 2));
    
    % Assigning deltaX and deltaY outside useRange to 0. So not using them to
    % produce average drift.
    lowuserange = xy_cell{iAOI}.userange(1);
    hiuserange = xy_cell{iAOI}.userange(2);    
    deltaX(1:lowuserange, iAOI) = 0;
    deltaX(hiuserange+1:SequenceLength, iAOI) = 0;
    deltaY(1:lowuserange, iAOI) = 0;
    deltaY(hiuserange+1:SequenceLength, iAOI) = 0;
end
end

function cumAvgDeltaX = calculateAverageCumulativeDisplacement(deltaX)

% deltaX(i, iAOI) is x position difference between frame i and frame i - 1

% Summing the displacements over all AOIs
sumDeltaX = sum(deltaX, 2);

% Summing the number of AOIs used in each displacement. This is necessary
% that the original program allows stitched drift fits, eg. AOI1 is usable
% from frame 1~100, and AOI2 is available for frame 80~200. This way the
% available displacement that can be averaged differs for each frame.
numAvailableDeltaxInEachFrame = sum((deltaX~=0), 2);

% Calculate the mean. Divide by the number of available displacements.
% To-do: change this to ./
avgDeltaX = sumDeltaX .* (numAvailableDeltaxInEachFrame.^(-1));

% At various places we divided by zero, resulting
% in NaN. We now zero out those entries.
avgDeltaX(isnan(avgDeltaX))=0;

% Sum the frame differences to a cumulative track
% of the exemplary x and y coordinate drifting in
% the file
cumAvgDeltaX = cumsum(avgDeltaX);
end

