function pc = remove_tiff_frames(input_tiff,input_timebase,output_tiff, output_timebase, input_frames)
%
%    function remove_tiff_frames(input_tiff, input_timebase, output_tiff, output_timebase, input_frames)
%
% This function will take the 'input_tiff' file and output another tiff
% file 'output_tiff' containing only those frames 'input_frames'.  That is,
% the 'output_tiff' file contains only a subset of frames from the
% 'input_tiff' file as specified by those frames listed in 'input_frames'
%
% input_tiff == name of input tiff file, e.g. = 'G:\September_21_2013\B29p24a_248\B29p24a_248_fov1.tif'
% input_timebase == derived from vid.ttb, usually as produced using the
%               function split_glimpse_file_v1.  The length(input_timebase)
%               matches the number of frames in 'input_tiff' file
% output_tiff == name of output tiff file e.g.
%            'G:\September_21_2013\B29p24a_248\B29p24a_248_fov1subset.tif'
% output_timebase == name of file into which we place the time base for the output file
%           e.g. 'G:\September_21_2013\B29p24a_248\B29p24a_248_fov1subsetTB.dat'
% input_frames == vector list of frame numbers (referenced to input_tiff file)
%             that will be included in the output_tiff file
%
% OUTPUT: time base of the output_tiff

dum=imread(input_tiff,'tif',input_frames(1)); % Read first image frame
imwrite(dum,output_tiff,'tiff','Compression','none');   % Write the first frame to a new file
                % Read and write the rest of the images
for indx=2:length(input_frames)
    dum=imread(input_tiff,'tif',input_frames(indx));
    imwrite(dum,output_tiff,'tiff','Compression','none','WriteMode','append');

end
tb=input_timebase(input_frames);    % time base for the output file
eval(['save ' output_timebase ' tb -mat'])
pc=tb;                  % Also output the timebase

