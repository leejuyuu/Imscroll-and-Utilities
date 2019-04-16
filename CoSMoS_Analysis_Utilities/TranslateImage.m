function pc=TranslateImage(inframe,deltaxy,outrange)
%
% function TranslateImage(inframe,deltaxy,outrange)
%
% This function will translate the input image frame 'inframe' by an
% amount 'deltaxy' and output the image region specified by 'outrange'.
% It is intended as an aid in aligning images for various classes of dye
% combinations prior to computing class averages.  Sub-pixel translations
% are handled by this function.  It relies on a linear interpolation 
% routine as a basis to translate the image, using repeated calls to the
% 'linear_AOI_interpolation() function (for integrating AOIs in imscroll).
%
% inframe == input image frame, typically a  single image from a Glimpse sequence
% deltaxy == [deltax  deltay] units:pixels (fractions OK),  specifies the 
%               translation DISPLACEMENT OF THE IMAGE
% outrange ==[xlow xhi ylow yhi]  units: integer pixel numbers.  
%               Defines the region of 'inframe' that will
%               be output by the function after the translation is
%               performed.  That is, the output will be
%               inframe(ylow:yhi, xlow:xhi) after the translation.

% The approach here is to calculate pixel-by-pixel the value following 
% translation for each pixel contained in the 'outrange' region.  We 
% consider each pixel w/in 'outrange' as a 1 x 1 AOI for the purpose of  
% using the linear_AOI_interpolation() function.  Translating the image by
% deltaxy here is then equivalent to translating each pixel in 'outrange'
% by -deltaxy.
% Note that the PIXEL CENTER HAS THE INTEGER COORDINATE AND THE PIXEL 
% EDGES ARE AT HALF INTEGERS
% As we cycle through each pixel, the center coordinates of each 1x1 pixel
% AOI are given just by those pixel indices.

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

xlow=outrange(1);xhi=outrange(2);ylow=outrange(3);yhi=outrange(4);
%pc=zeros(length(ylow:yhi),length((xlow:xhi)));   % Reserve space for output matrix
                    % Cycle through all the output pixels
[rose col]=size(inframe);
dumframe=zeros(rose,col);

for yindx=ylow:yhi
    for xindx=xlow:xhi
        dumframe(yindx,xindx)=linear_AOI_interpolation(inframe,[xindx yindx]-deltaxy,0.5);
    end
end
pc=dumframe(ylow:yhi,xlow:xhi);


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

