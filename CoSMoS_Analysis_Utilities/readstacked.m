function pc=readstacked(folder,range)
%
% function readstacked(fold,range)
%
% A utility that will read in a series of frames from a stacked tiff file
% and return a matrix of size m x n x p where m x n is the size of one
% image and p = length(range)
%
% folder = input folder name e.g. 'p:\image_data\march13\b5p76a.tif'
% range = vector of input frame numbers e.g. [3:11]
eval(['!copy ' folder ' d:\temp\tmp.tif']);
fold='d:\temp\tmp.tif';
tst=imread(fold,'tiff',range(1));                   % Get one frame, for testing size
[rows col]=size(tst);
dum=uint16(zeros(rows,col));                         
pc(:,:,length(range))=dum;                          % Establish output matrix that is
                                                    % of proper size and of
                                                    % type int16
for indx=range                           % Read in all the specified frames
    pc(:,:,indx-range(1)+1)=imread(fold,'tiff',indx);
    if indx/50 == round(indx/50)
        indx
    end
end
