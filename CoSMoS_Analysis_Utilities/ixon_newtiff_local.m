function pc=ixon_newtiff_local(folder,range,rot90_arg,base_filename)
%
%function ixon_newtiff_local(folder,range,rot90_arg,[base_filename])
%
% This mfile will read in a list of tiff files stored by version 4 of the
% ixon software (august 2005).  The specified images will be stored as a
% stacked array as uint16 numbers.  The files are intended to be read from
% the local disk.
%
% folder == e.g. ''c:\temp\'.  The actual files
%            are named spool.tif, spool_x2.tif, spool_x3.tif etc, but this
%            function will append the actual name to the specified folder
%            as needed 
% range ==  (low frame #):(high frame #) e.g. = [0:79]
%images_per_file === the maximum number of images stored in each tiff file written
%           by the ixon software.  The user must determine this by using
%           'imread' function from the command mode (the number varies by
%           the image size).  User may also get this number by loading one
%           of the tiff files into the roper Win32 program (very easy: the
%           program tells the user the # of images read in)
% rot90_arg == argument 'N' into rot90(image,N) function for rotating the images.  Seems
%           to be N=1 is appropriate.
% base_filename[OPTIONAL]== the base name for the tiff files.  The default
%           in the ixon software is simply 'spool'


if nargin <4
                                        
    base_filename='spool';
                                                    % if the base_filename was not entered, it 
                                                    % will default to 'spool' 
end


%eval(['!copy ' folder ' c:\temp']);                 % copy all files to local disk
%localfold='c:\temp\';              % In ixon_newtiff_local.m we assume the
                                    % *.tif files are already on the local
                                    % disk
localfold=folder;
foldtst=[localfold  base_filename '.tif'];
[dmm images_per_file]=size(imfinfo(foldtst));       % Look at one file to see # of images
images_per_file;
tst=imread(foldtst,'tif',1);                        % read one image to obtain size
[rose col]=size(tst);
dum=rot90(uint16(zeros(rose,col)),rot90_arg);                        % one frame of appropriate size
pc(:,:,length(range))=dum;                          % reserve space for output images
filenum=ceil(max(range)/images_per_file);           % Number of tiff files written
limitmat=[1 images_per_file];                       % A matrix whose two entry rows will list the limits
                                                    % of the image numbers in each file
filenamecell{1}=[base_filename '.tif'];                        % Contains the names of the tiff files written
if filenum >1
    for ind=2:filenum
                                                    % Expand limitmat to list image index limits for all
                                                    % the '.tif' files written
                                  
    limitmat=[limitmat
             (ind-1)*images_per_file+1  ind*images_per_file];
    filenamecell{ind}=[base_filename '_x' num2str(ind) '.tif'];   % Expand filenamcell to list all names of the tiff
                                                    % files written.  The limits of each row in
                                                    % limitmat matches the name indexed in 
                                                    % the filenamecell array
                                                    
    end
end
                                                    % Now cycle through the
                                                    % requested images
for imindx=range
                                                    % Find the line in
                                                    % limitmat that
                                                    % brackets image index
                                                    %
                                                    % First, a logical
                                                    % array with a 1 in the
                                                    % appropriate line
    limitindx= (imindx>=limitmat(:,1) )& (imindx<=limitmat(:,2));
    linenumber=find(limitindx);                      % Number specifying the matrix row
                                                    % in limitmat whose
                                                    % entries bracket the present
                                                    % image index imindx
    filename=filenamecell{linenumber};                  % Fetch the correct filename
    offset=imindx-limitmat(linenumber,1)+1;         % Define the index within the file where we find
                                                    % the image we seek
                                                    %
                                                    % Now get the specific
                                                    % image
    pc(:,:,imindx-range(1)+1)=rot90(imread([localfold filename],'tif',offset),rot90_arg);
    if imindx/30 == round(imindx/30)
        imindx
        linenumber
    end
end
