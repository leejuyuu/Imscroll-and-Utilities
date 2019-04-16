function pc=ImageClassBySum(ImageClass,InputImage)
%
% Will compare the InputImage with image class averages (or fits) stored in
% the ImageClass cell array using a sum-of-squares difference.  The routine
% will output a value for the sum-of-squares difference for each image
% class provided in the ImageClass cell array
%
% ImageClass == cell array of images that are the same dimension,
%             orientation and pixel registry as that in InputImage
% InputImage == uint16 image of M x N pixels.  A sum-of-squares difference
%             will be computed for this image and each image from the
%             ImageClass array.
%
%  Output:  vector of values for the sum-of-squares differences computed 
%           using the single InputImage and each of the images in the
%           ImageClass cell array

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
classNum=length(ImageClass);            % Number of images classes
pc=zeros(1,classNum);                   % Reserve space for output
for indx=1:classNum
                % Compute sum-of-squares difference between InputImage and
                % each image contained in the ImageClass cell array
    %imageSquareDiff=( double(ImageClass{indx})-double(InputImage) ).^2;
                % Next line imposes the same mean-above-offset for both the
                % ImageClass and InputImage
    imageSquareDiff=( (double(ImageClass{indx})-100)-( double(InputImage)-100)*( (mean(mean(ImageClass{indx}))-100)/(mean(mean(InputImage))-100)) ).^2;
    pc(indx)=sum(sum(imageSquareDiff));
end