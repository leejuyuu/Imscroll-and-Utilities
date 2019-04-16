function pc=plot_spot_number_v2(fp,frames,thresholds,NdSd,roi,aoiRadius,SequenceLength,ProbZ,frmave,bkgnd,fignum)
%
% function   plot_spot_number_v2(fp,frames,thresholds,NdSd,roi,aoiRadius,SequenceLength,Probz,frmave,bkgnd,fignum)
%
% This will determine the number of spots detected by the auto picker
% over a range of threshold values and in the specified frames, and then
% plot the results.  The spots detected will need to also be within the 
% specified region of interest
%
%
% fp ==path the glimpse folder containing the image frames upon which the
%    gaussian will be superimposed
% frames == 1D vector of frame numbers in which the spots will be detected
% thresholds == vector of threshold values for which the number of spots
%            will be detected.
% NdSd ==[(Noise Diameter)  (Spot Diameter)] settings for the spot
%          detection
% roi == region of interest.  Mask defining region in which the
%           spots will be detected.  Create the mask using the command:
%            roi=roipoly;
% aoiRadius == radius used in auto event detection.  A spot within this distance
%             from an aoi center will be counted as contributing to a landing event
% SequenceLength == frames in the glimpse sequence.  The output plot will show the
%            threshold setting predicted to result in a probability=Probz of having
%            no spurious noise-generated event in a random AOI over the course of 
%            a sequence having a number of frames equal to 'SquenceLength'
% Probz == desired probability of there being zero noise-generated events in a random AOI
%            during a sequence of length SequenceLength (can be a vector
%            of values).  Also see b27p72c.fig
% frmave == frame average.  The number of frames to average prior to
%         detecting spot.
% bkgnd == set =1 in order to perform a background subtraction on the 
%         images using the program 'bkgnd_image' with Radius=5 Height=2
% Function will output the spots (from the function spot_number) and
% will also plot the results
% User must click on the curve 4 times to set starting fit parameters
% First 2 clicks: on fast (noise-generated) region, last 2 clicks: on slow (data) portion of curve 
% Verticle dotted line at threshold necessary to achieve the desired ProbZ probability  
% V1 3/26/2014  LJF   added the 'frmave' arguement to allow frame averaging
% V2 9/5/2014   LJF   added optional background subtraction


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


frmnum=length(frames);          % The number of different frames in which
                                % we detect spots
spots=spot_numbers_v2( fp,  frames,  thresholds,  NdSd, frmave, bkgnd, roi );
                                % Clear the present figure, then prepare
                                % to display a series of plots
figure(fignum);
%hold off;clf;hold on
for indx=1:frmnum
     figure(fignum);plot(spots{indx}(:,4),spots{indx}(:,5),'.');
end
xlabel('SpotThreshold Brightnes (AU)');
ylabel('Detected Spot Number');shg
xdata=spots{1}(:,4);
ydata=spots{1}(:,5);
                    % Get the starting parameters for fit to first frame
                    % data , then fit to biexponential  
args=twoexp_click_and_fit(xdata,ydata,fignum)
tm=round(min(xdata)):0.1:round(max(xdata));         % Fine grid of threshold settings for evaluating fit
                    % Plot the twoexp fit to the first frame data
figure(fignum);hold on;plot(tm,args(1,1)*exp(-tm*args(2,1))+args(3,1)*exp(-tm*args(4,1)),'r');shg
                    % Plot just the first term (spots detected due to background noise) 
figure(fignum);plot(tm,args(1,1)*exp(-tm*args(2,1)),'g',tm,args(3,1)*exp(-tm*args(4,1)),'k');
prob=pi*aoiRadius^2/sum(sum(roi));      % Probability/frame that a random event will
                                        % fall within a particular AOI
SpecPercent=1-ProbZ.^(1/SequenceLength)   %  SpecPercent = AOI event Probability/frame that will result in a 
                            % probability=ProbZ of NOT detecting an event during the sequence containing
                            % a number of frames equal to 'SequenceLength'
                            % i.e.  ProbZ = (1-SpecPercent)^SequenceLength
                            % where (1-SpecPerent)^SequenceLength is the
                            % first term in the (p+q)^SequenceLength 
                            % expansion with q=SpecPercent and p=1-q
            % p = prob of no event in the aoi for one frame
            % q = prob of one event in the aoi for one frame
                            % e.g. SpecPercent=1.745E-4 for 4000 frames and 0.5 = Probz 
Numz=SpecPercent/prob;             % Number of spots/frame that will result in there
                       % being a Probz probability of zero spurious noise 
                       % spots occuring in a random aoi over a (frame number)=SequenceLength sequence.  
        % e.g. SpecPercent = 1.745E-4 probability for 4000 frames and prob = 1.4E-4 of a spot falling in a
        % random AOI per frame results in a 50% probability of there being
        % no spot fall in a random AOI during 4000 frames for Numz = 1.24 spots/frame
% i.e. if 1.24 spots/frame fall in the FOV from the noise background, then the probability/frame of an event falling w/in a random AOI
% will be 1.24*pi*aoiRadius^2/sum(sum(roi)) =(total probability) = TP ( = SpecPercent <<1)
% Then the probabilty of there being NO noise-generated events in a random AOI during our sequence will be (1-TP)^SequenceLength
% = 0.5 by this construction b/c Numz*pi*aoiRadius^2/sum(sum(roi)) = SpecPercent*sum(sum(roi))/(pi*aoiRadius^2)*(pi*aoiRadius^2)/sum(sum(roi) = SpecPercent. 

% Now use the fit from the first (noise-generated) term to find the
% threshold setting that will result in an event number = Numz defined above

%(event number,   threshold, Numz)
%Th=interp1(args(1,1)*exp(-tm*args(2,1)),tm,Numz)
Th=-(1/args(2,1))*log(Numz/args(1,1))
for indx=1:length(Th)
figure(fignum);plot([Th(indx) Th(indx)],[0 args(1,1)*exp(-tm(1)*args(2,1))],'k--');shg
text(Th(indx),1,num2str(ProbZ(indx)));
end

pc.spots=spots;     %[frame#  (Noise Diameter) (Spot Diameter) (threshold value) (number of spots)] Cell array spot{1} will be for the first frame listed in 'frames', spot{2} for the second, etc
pc.args=args;       % Fit parameters for the biexponential
pc.ProbZ=ProbZ;     % User-specified probabilty that there will be zero noise-generated events in a random AOI
pc.Th=Th;           % Threshold setting(s) to achieve a probability=ProbZ of zero noise-generated events in a random AOI 
pc.spotsDescription ='[frame#  (Noise Diameter) (Spot Diameter) (threshold value) (number of spots)] Cell array spot{1} will be for the first frame listed in ''frames'', spot{2} for the second, etc';
pc.argsDescription='Fit parameters for the biexponential.  e.g. arg(1)  CI_0.95_low  CI_0.95_high, etc';
pc.ProbZDescription='User-specified probabilty that there will be zero noise-generated events in a random AOI';
pc.ThDescription ='Threshold setting(s) to achieve a probability=ProbZ of zero noise-generated events in a random AOI'; 