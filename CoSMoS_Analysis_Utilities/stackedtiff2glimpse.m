function rv=stackedtiff2glimpse(tiff_path,frames,out_path,user,dt)
%
% stackedtiff2glimpse(tiff_path,frames,out_path,user,dt)
%
% make a glimpse file from a stacked tiff.    
%
% tiff_path == path to the stacked tiff file 
%             e.g. 'C:\larry\image_data\december_22_2006\b15p111a.tif'
%      user == user name  e.g. 'silvia'
%    frames == tiff frames that will be written to glimpse
%             e.g. [ 10:30]
%   outpath == path to the folder that will contain the glimpse file
%             e.g. 'E:\others\Silvia\silvia001'
%        dt == approximate time between frames in seconds, or specified 
%              frame time.
%
% modified from Silly Larry's glimpse_from_tiff, Apr 2014
%

if isempty(frames)  %convert all frames if no specific frames are selected
  [nframes n]=size(imfinfo(tiff_path,'tif'));
  frames=1:nframes;
end
disp([num2str(length(frames)) ' frames']);

for indx=frames
  im = double(imread(tiff_path,'tiff', indx));
  %out_glimpse(user,im,out_path);
  if indx==frames(1)
    [im_width im_height]=size(im);
    %create and write to a binary file:
    binary = fopen([out_path '\0.glimpse'],'a');
    %create vid structure:
    if nargin == 4
      ftime = [0:0.25:0.25*(length(frames)-1)];
    else
      if isempty(dt)
        ftime = [0:0.25:0.25*(length(frames)-1)];
      elseif length(dt)==1
        ftime = [0:dt:dt*(length(frames)-1)];
      else
        ftime = dt;
      end
    end
    
    vid = struct('moviefile', [out_path '\header.glimpse'], ...
                 'username', user, ...
                 'description', 'converted from stacked tiff', ...
                 'nframes', length(frames), ...
                 'time1', 32342343, ...
                 'ttb', ftime, ...
                 'depth', 1, ...
                 'offset', [], ...
                 'filenumber', zeros(1,length(frames)), ...
                 'width', im_width, ...
                 'height', im_height);
    %0 file location offset for reading the first frame
    vid.offset=0;
    %write image to binary file
    im = im-2^15;
    fwrite(binary,im,'int16','b');
    fclose(binary);
    
  else
    %open and append to binary file already created
    binary = fopen([out_path '\0.glimpse'],'a');
    im = im-2^15;
    fwrite(binary,im,'int16','b');
    fclose(binary);
    %add a file location offset for reading individual frames
    vid.offset=[vid.offset (vid.offset(end)+(im_width*im_height*2))];
    
  end

end
%save header information
save([out_path '\header'],'vid');




