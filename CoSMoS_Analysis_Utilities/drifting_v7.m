function pc=drifting_v7(gfolder,frmrange,frmlim,averange,fitwidth,filesource)
%
% function drifting_v7(gfolder,frmrange,frmlim,averange,fitwidth,filesource)
%
% Will use cross correlations to track the drift of a field of view during
% a GLIMPSE sequence.
%
% gfolder == path to the folder e.g.
%           'D:\temp\larry\april_14_07\b16p105c_533\'
% frmrange == [frmlow frmhigh] range of frames over which we will track the drift
% frmlim == [ylow yhigh xlow xhigh] sets the region of the frame that will
%           be used for computing the cross correlation (that will track the 
%           drift) 
% averange == e.g. 5 or 10   the sequence will be broken into sequential 
%            frame groups of this size, and each group will be frame 
%            averaged before computing the cross correlation with the next
%            frame group.
% fitwidth == the central peak of the cross correlation will be fit with a
%            gaussian function.  The full width of the region that will be 
%            fit is given by the fitwidth parameter.
% filesource == 1 for glimpse file
%               2 for tiff file
%  v3 :  use smooth_background( ) to smooth image before subtraction for 
%            auto and crosscorrelation
% v4  : fit to gaussian for defining center_peak_rose, center_peak_col
% v5  : switch to gaussian with different sigmax and sigmay
% v5a : mask with gaussian, push pixels to zero at edges
% v7: made array square, made mask size automatically matching array
pc=[];
                   % Make area square with odd # pixels in each dimension
mxlim=max(frmlim(2)-frmlim(1),frmlim(4)-frmlim(3));
     % Want an odd # pixels each dimension , and mxlim/2 must be even for pix/edge to be odd
if mxlim/2~=round(mxlim/2), mxlim=mxlim+1; end
frmlim(2)=frmlim(1)+mxlim;      % Use a square array
frmlim(4)=frmlim(3)+mxlim;
mask=gaussian_spot(1,mxlim*.3,[0 0],1,mxlim/2); % Make mask to zero frames at edges v5a

                          % Load one example frame

dum=readaframe(gfolder,filesource,1);
[m n]=size(dum);
                                        % Make space for our averages of
                                        % the grouped frames
dum1=uint32(zeros(frmlim(2)-frmlim(1)+1,frmlim(4)-frmlim(3)+1,averange));               
dum2=dum1;                               
                                        % Load the first group of frames
indx=1;
for frmindx=frmrange(1):frmrange(1)+averange-1
    fullframe=readaframe(gfolder,filesource,frmindx);
    dum1(:,:,indx)=fullframe(frmlim(1):frmlim(2),frmlim(3):frmlim(4));
    indx=indx+1;
end
                                        % And average the first frame group
dum_prior_ave=imdivide( sum(dum1,3), averange);
                                        % Get the autocorrelation to define
                                        % the nonshifted center peak
 
dum_prior_ave=dum_prior_ave-smooth_background(dum_prior_ave);
                    % Note that above we subtracted off a smoothed
                    % background
dum_prior_ave=dum_prior_ave.*mask;      % v5a push to zero at edges
autocorr=conv2(dum_prior_ave,flipud(fliplr(dum_prior_ave)),'same');


mcol=max(autocorr);                     % outputs a vector of max values for each column
[mx Icol]=max(mcol);                     % Icol is the column index of central peak in autocorr
mrose=max(autocorr');
[mx Irose]=max(mrose);                  % Irose is the row index of the central peak in autocorr
                                        % Initialize current peak of the
                                        % cross correlation, referenced to
                                        % the subframe region we used for
                                        % computing the cross correlation
     % e.g. for (10,10) matrix the max will be at (5,5), while for an
     % (11,11) matrix the max will be at (6,6) (also at (6,6) for (12,12)
     % matrix)
center_peak_col=Icol;
center_peak_rose=Irose;
    % ******* define peak of autocorr by fitting to gaussian
     ylow=round(center_peak_rose-fitwidth/2);xlow=round(center_peak_col-fitwidth/2);
    yhi=round(ylow+fitwidth-1);xhi=round(xlow+fitwidth-1);
    fitregion=autocorr(ylow:yhi,xlow:xhi);                            
    
                               % starting parameters for fit
                            %[ ampl xzero yzero sigma offset]
    
    mx=double( max(max(fitregion)) );
                                % 'fitregion' is too large for our
                                % parameter limits in gauss2dfit, just
                                % nomalize it
    fitregion_norm=fitregion/mx;
    mn=double( mean(mean(fitregion_norm)) );
    inputarg0=[1 fitwidth/2 fitwidth/2 fitwidth/4 mn];

   
   % outarg=gauss2dfit(double(fitregion_norm),double(inputarg0));
                                        %[amplitude xo sigx yo sigy bkgnd]
      outarg=gauss2dxyfit(double(fitregion_norm),double([1 fitwidth/2 fitwidth/4  fitwidth/2 fitwidth/4 mn]) );
%keyboard
                            % Reference latest_peak_col,rose to the entire
                            % subframe region we use for computing the
                            % cross correlation so we can obtain the latest_peak
                            % displacement from the unshifted
                            % center_peak_col,rose
                            
    latest_peak_col=outarg(2)+xlow;
    latest_peak_rose=outarg(4)+ylow;
    % ******* end of define peak of autocorr by fitting to gaussian
    center_peak_col=latest_peak_col;
    center_peak_rose=latest_peak_rose;

                                    % Now loop through the rest of the frames in steps
                                    % of 'averange
for frmindx=(frmrange(1)+averange):averange:frmrange(2)
                                    % Read in a group of frames
    indx=1;
    for subfrmindx=frmindx:frmindx+averange-1
        fullframe=readaframe(gfolder,filesource,frmindx);
        dum2(:,:,indx)=fullframe(frmlim(1):frmlim(2),frmlim(3):frmlim(4));
        indx=indx+1;
    end
                                    % And average the current frame group
    dum_current_ave=imdivide( sum(dum2,3), averange);
                      % In conv2(A, flipud(fliplr(B),'same' ), the peak in the cross correlation 
                      % will be shifted from the (Irose,Icol) location by
                      % the distance and direction that A is displaced from B 
    dum_current_ave=dum_current_ave-smooth_background(dum_current_ave);
    dum_current_ave=dum_current_ave.*mask;    % v5a, push to zero at edges
    crosscor=conv2(dum_current_ave,flipud(fliplr(dum_prior_ave)),'same');
                                % Replace our 'dum_prior_frame' with the
                                % one we just used
    dum_prior_ave=dum_current_ave;
                                % Now we need to fit the central peak of
                                % our crosscorrelation
                                % Set the limits of the central region to
                                % be fit. Note the e.g. last_peak_rose
                                % pixel index is referenced to the entire subframe
                                % region we used for computing the cross
                                % correlation
    ylow=round(center_peak_rose-fitwidth/2);xlow=round(center_peak_col-fitwidth/2);
    yhi=round(ylow+fitwidth-1);xhi=round(xlow+fitwidth-1);
    fitregion=crosscor(ylow:yhi,xlow:xhi);                            
    
                               % starting parameters for fit
                            %[ ampl xzero yzero sigma offset]
    
    mx=double( max(max(fitregion)) );
                                % 'fitregion' is too large for our
                                % parameter limits in gauss2dfit, just
                                % nomalize it
    fitregion_norm=fitregion/mx;
    mn=double( mean(mean(fitregion_norm)) );
    inputarg0=[1 fitwidth/2 fitwidth/2 fitwidth/4 mn];
   %keyboard 
   
    %outarg=gauss2dfit(double(fitregion_norm),double(inputarg0));
                                        %[amplitude xo sigx yo sigy bkgnd]
    outarg=gauss2dxyfit(double(fitregion_norm),double([1 fitwidth/2 fitwidth/4  fitwidth/2 fitwidth/4 mn]) );
                            % Reference latest_peak_col,rose to the entire
                            % subframe region we use for computing the
                            % cross correlation so we can obtain the latest_peak
                            % displacement from the unshifted
                            % center_peak_col,rose
                            
    latest_peak_col=outarg(2)+xlow;
    latest_peak_rose=outarg(4)+ylow;
frmindx
%keyboard
    pc=[pc; frmindx outarg' latest_peak_col latest_peak_rose (latest_peak_col)-(center_peak_col) (latest_peak_rose)-(center_peak_rose)];
end
