function rv=read_image(imtype,fpath,findx,option)

% read_image(imtype,fpath,findx,option)
%
% master function for reading in images of different formats
% used in the Gelles lab.  It's written so that different formats
% can be added to it later without having to extensively modify
% the image reading commands in any program.
%
% imtype == 'tiff' or 'glimpse'
% fpath == tiff file path and name or glimpse file folder.
% findx == frame number to be read.
% option == 'stacked' for tiff file or other parameters for other file format
%


switch imtype
%---------------------------------------------
%----- tiff files ----------------------------
case {'tiff','tif'}
    if option=='stacked'
        rv=double(imread(fpath,'tiff',findx));
    else
        rv=double(imread(tiff_name_series(fpath,findx),'tiff'));
    end
%---------------------------------------------


%---------------------------------------------
%----- glimpse files -------------------------
case 'glimpse'
    load([fpath '\header.mat']);
    %vid is the loaded glimpse file header
    fid=fopen([fpath '\' num2str(vid.filenumber(findx)) '.glimpse'],'r','b');
    fseek(fid,vid.offset(findx),'bof');
    if isfield(vid,'wi')    %old width & height format
        rv=fread(fid,[vid.wi vid.ht],'int16=>double');
    else                    %current width & height format
        rv=fread(fid,[vid.width vid.height],'int16=>double');
    end
    rv=rv+2^15; %adding 2^15 sets the pixel values to be the same as tiff image
    %rv=fread(fid,[glimpse_header.wi glimpse_header.ht],'int16=>int16');
    %rv=uint16(rv+32768);
    fclose(fid);
% glimpse_header = 
%      moviefile: 'd:\glimpse\jchung00005\header.glimpse'
%       username: 'jchung'
%    description: [1x0 char]
%        nframes: 2729
%          time1: 3.2526e+009
%            ttb: [1x2729 double]
%          depth: 1
%         offset: [1x2730 double]
%     filenumber: [1x2730 double]
%          width: 300
%         height: 512
%---------------------------------------------


%---------------------------------------------
end % end of pragram
%---------------------------------------------
%rv(end,end)
