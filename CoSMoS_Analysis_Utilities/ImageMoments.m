function pc=ImageMoments(frame,thresh1, thresh2)
%
% function ImageMoments(frame)
%
% This routine calculates the first and second moments for an image.
% 
% frame == input image frame with background already removed.  This image
%          data would then be in double() format so that negative values
%          are allowed.  However, the routine calculates the Xmean, Ymean
%          values using only the top 'thresh1' fraction of the spanned pixel range (to
%          catch just the peak), and X2moment, Y2moment using the top
%          'thresh2' fraction of the spanned pixel range.
% Xmean, Ymean == 1st moment coordinates of the input 'frame'
% X2moment, Y2moment== 2nd moments of the 'frame' with computed with respect
%                      to the (Xmean, Ymean) coordinate.
% thresh1 == value between 0 and 1. The routine uses only those pixels in
%            the top fraction of the spanned pixel range for the Xmean, Ymean 
%            calculation as specified by thresh1.  For example, if 
%            thresh1 = 0.25 we use only those pixels in the top 75% of the 
%            pixel range spanned within 'frame'.
% thresh2 == value between 0 and 1. The routine uses only those pixels in
%            the top fraction of the spanned pixel range for the X2moment, 
%            Y2moment calculation as specified by thresh2.  For example, if 
%            thresh2 = 0.10 we use only those pixels in the top 90% of the 
%            pixel range spanned within 'frame'.
%
% Output= [Xmean Ymean X2moment Y2moment]

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

  frame=double(frame);
  mn=min(min(frame));   % Minimum value of the frame
  mx=max(max(frame));   % Maximum value of the frame
  thresh=thresh1*(mx-mn)+mn;    % Threshold setting to select pixels with value in top 75% of spanned pixel range
  logik=frame>thresh;
  frameTop1=frame.*logik;       % Select just the peak:  top pixels in top 75% of spanned pixel range
  
  thresh=thresh2*(mx-mn)+mn;       % top 90% of range for 2nd moment calc
  logik=frame>thresh;
  frameTop2=frame.*logik;
  
 [netrose netcol]=size(frameTop1);                   % Size of our  image
 ymat=[1:netrose]'*ones(1,netcol);       % Matrix is size of frame, const in X, increaseing in Y e.g.[1 1 1; 2 2 2; etc]
 xmat=ones(netrose,1)*[1:netcol];        % Matrix is size of frame, const in Y, increaseing in X e.g.[1 2 3; 1 2 3; etc]
                       
         
 Xmean=sum(sum(frameTop1.*xmat))/sum(sum(frameTop1)); % Calculate X moment of intensity in netFrame
 Ymean=sum(sum(frameTop1.*ymat))/sum(sum(frameTop1)); % Calculate Y moment of intensity in netFrame
                % Calculate 2nd moment relative to Xmean Ymean location
 X2moment= sqrt( sum(sum(frameTop2.*((xmat-Xmean).^2)))/sum(sum(frameTop2)) );   % Calculate 2nd X moment of intensity in netFrame 
 Y2moment=  sqrt( sum(sum(frameTop2.*((ymat-Ymean).^2)))/sum(sum(frameTop2)) );   % Calculate 2nd X moment of intensity in netFrame 

 pc=[Xmean Ymean X2moment Y2moment];