function pc=split_glimpse_file(fp,vid,step,frames,output_files)
%
% function split_glimpse_file(fp,vid,step,frames,output_files)
%
% This function will read in frames from a glimpse image sequence and write
% a number of output tiff files.  The frames from the glimpse file will be
% sorted into the output tiffs according to the 'step' parameter.  This is
% intended to take a sequence containing frames from a number of different
% fields of view, and put all the frames from one field of view into a 
% single file.  The 'step' parameter will equal the number of FOVs in the
% glimpse sequence, and hence gives the number of frames to step between
% in order to reach the next image from the same FOV.
%  fp == full path to the glimpse-saved folder containing the series of
%           glimpse files
%  vid == structure contained in the 'header.mat' file within the folder
%          specified by 'folder' variable.  The gheader members will be
%          for example:
%           moviefile: 'd:\glimpse\larryfj00269\header.glimpse'
%         username: 'larryfj'
%        description: [1x0 char]
%            nframes: 13206
%           time1: 3.2470e+009
%                ttb: [1x13206 double]
%          depth: 1
%         offset: [1x13207 double]
%     filenumber: [1x13207 double]
%          width: 302
%         height: 512
%  step == number of FOVs in the glimpse file.  Gives the number of frames
%       in between images of the same FOV
%  frames== [(start)  (end)]  high and low limits of the frame numbers that
%        will be sorted into the output files
%  output_files == [output1; output2; ... outputN] an alphanumeric matrix
%         that is step x 1 in size, listing the path and output file names
%         for the tiff files, e.g.
%         ['d:\temp\larry\out1.tif' ;  'd:\temp\larry\out2.tif' ;  etc ]
for fileindx=1:step
    imageindx=frames(1)+fileindx-1;    % index for the images in the glimpse file
    
                        % Loop through and read/write the first frame in
                        % each of the output tiff files
    image=glimpse_image(fp,vid,imageindx);
    imwrite(image,output_files(fileindx,:),'tiff','Compression','none');       % Write the first image into each file
end
 % Now we have to retrieve the remaindier of the images and append them to
 % the files
 
 for imageindx=frames(1)+step:frames(2)
     fileindx=1+rem( (imageindx-frames(1)-step),step);  % The file index will cycle between 1 and step
     image=glimpse_image(fp,vid,imageindx);
     imwrite(image,output_files(fileindx,:),'tiff','Compression','none','WriteMode','append');
     if imageindx/20==round(imageindx/20),imageindx,end
 end
 
