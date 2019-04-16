function out=gauss(im,mx,sz)

%
% gauss(im,mx,sz)
% adapted from cntd to use Gaussian fitting for
% sub-pixel localization
%
% INPUTS:
% im: image to process, particle should be bright spots on dark background with little noise
%   ofen an bandpass filtered brightfield image or a nice fluorescent image
%
% mx: locations of local maxima to pixel-level accuracy from pkfnd.m
%
% sz: radius of the window over which to average to calculate the centroid.  
%     should be big enough
%     to capture the whole particle but not so big that it captures others.  
%     if initial guess of center (from pkfnd) is far from the centroid, the
%     window will need to be larger than the particle size.  RECCOMMENDED
%     size is the long lengthscale used in bpass plus 2.
%     
% NOTE:
%  - if pkfnd, and cntrd return more then one location per particle then
%  you should try to filter your input more carefully.  If you still get
%  more than one peak for particle, use the optional sz parameter in pkfnd
%  - If you want sub-pixel accuracy, you need to have a lot of pixels in your window (sz>>1). 
%    To check for pixel bias, plot a histogram of the fractional parts of the resulting locations
%  - It is HIGHLY recommended to run in interactive mode to adjust the parameters before you
%    analyze a bunch of images.
%
%OUTPUT:  a N x 3 array containing, x, y and brightness for each feature
%           out(:,1) is the x-coordinates
%           out(:,2) is the y-coordinates
%           out(:,3) is the brightnesses
%           out(:,4) is the sqare of the radius of gyration
%
%adapted from cntrd by Eric R. Dufresne
%  do 2D gaussina fitting to get sub-pixel accuracy
%

%-----------------------------------------------------------------
if isempty(mx)
    warning('no peaks! check your pkfnd theshold.')
    out=[];
    return;
end
%-----------------------------------------------------------------
[nr,nc]=size(im);
%remove all potential locations within distance sz from edges of image
ind=find(mx(:,2) > 1.5*sz & mx(:,2) < nr-1.5*sz);
mx=mx(ind,:);
ind=find(mx(:,1) > 1.5*sz & mx(:,1) < nc-1.5*sz);
mx=mx(ind,:);
[Nmx,crap] = size(mx);
%-----------------------------------------------------------------
pts=[];
%loop through all of the candidate positions
for i=1:Nmx
    dat=im(mx(i,2)-sz:mx(i,2)+sz,mx(i,1)-sz:mx(i,1)+sz);
    %---------------------------------------
    %fit_arg=func_2dgaussian_fit(dat);
    [ysize xsize]=size(dat);
    y_center=ysize/2;    % set to the center of an image
    x_center=xsize/2;    % set to the center of an image
    xy_sigma=3;             % set to 3 pixels ~ 165 nm in hv scope
    offset=min(min(dat));
    amplitude=max(max(dat))-offset;
    fit_arg=[amplitude x_center y_center xy_sigma offset];
    xdata(:,:,1)=ones(ysize,xsize)*diag(1:xsize);  % x matrix 
    xdata(:,:,2)=diag(1:ysize)*ones(ysize,xsize);  % y matrix	
    gaussfun=inline('fit_arg(1)*exp(-0.5*((xdata(:,:,1)-fit_arg(2)).^2+(xdata(:,:,2)-fit_arg(3)).^2)/fit_arg(4)^2)+fit_arg(5)','fit_arg','xdata');
    options=optimset('lsqcurvefit');
    options=optimset(options,'display','off');
    fit_arg=lsqcurvefit(gaussfun,fit_arg,xdata,dat,[10 0 0 0.5 0],[1e5 50 50 50 1e4],options);
    %---------------------------------------
    intensity=sum(sum(dat));
    sigma_xy=fit_arg(4);
    %[x y int sigma];
    pts=[pts;[fit_arg(2)+mx(i,1)-sz-1 fit_arg(3)+mx(i,2)-sz-1 intensity sigma_xy]];
end
out=pts;

