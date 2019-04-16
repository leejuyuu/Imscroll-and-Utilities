%out_glimpse(user,image,out_path) 
%
%saves or appends an image to a glimpse file
%
%INPUTS:
%  user - The name of the user the file will be attributed to (only if the file is being created) 
%  image - The image to be added to the glimpse file (input format is a
%          matrix)
%  out_path - The directory path the file and header file will be saved to.
%            For eaxample, 'd:\glimpse\wawa0001'
%
%OUTPUTS:   0.glimpse
%           header.mat
%
%This program loads in an image and adds it in signed 16 bit format to a
%binary file similar to the old glimpse format. Labview's 32bit pointers
%are enough for only one file, so the only file will be 0.glimpse
%It also creates the matlab header 'header.mat'
%
%Alex Okonechnikov, July 17, 2009
%
%Ver 1.1, now fully functional and gives error message when old glimpse
%limit is reached
%
%Johnson Chung, 20 Jan 2010
%added more comments at the beginning of the function


function out_glimpse(user,image,out_path)
[im_width im_height]=size(image);

if exist([out_path '\header.mat'],'file')      
    %use header already in place
    if exist([out_path '\0.glimpse'],'file')   
        %add to image file already in place
        load([out_path '\header.mat']);
        vid.nframes=vid.nframes+1; %#ok<NODEF>
        vid.ttb=[vid.ttb,vid.ttb(end)+333];
        if vid.offset(end)+im_width*im_height*2>=2^32
           ['the old glimpse will not be able to read this file any further than frame ' num2str(vid.nframes)]
        end
        vid.offset=[vid.offset (vid.offset(end)+(im_width*im_height*2))];
        vid.filenumber=[vid.filenumber 0];
        %overwrite old header information
        save([out_path '\header'],'vid');
        %open and append to binary file
        binary = fopen([out_path '\0.glimpse'],'a');
        image=image-2^15;
        fwrite(binary,image,'int16','b');
        fclose(binary);
    else
       %ABORT, header exists without a file
       'there is a header with no file!'
       'abort!'
       return;
    end
    
else
    %no header, will create new header
    if exist([out_path '\0.glimpse'],'file')    
        %ABORT, file exists with no header
        'there is a file with no header!'
        'abort!'
        return;
    else
        %no file, no header: will make and write to file
        %header = fopen([out_path '\header.m'],'a');
        binary = fopen([out_path '\0.glimpse'],'a');
        %create vid structure
        vid = struct('moviefile', [out_path '\header.glimpse'], 'username', user, 'description', '', 'nframes',0, 'time1', 32342343, 'ttb', [], 'depth', 1, 'offset', [], 'filenumber', [], 'width', im_width, 'height', im_height);
        %append an image to header
        vid.nframes=vid.nframes+1;
        vid.ttb=0;
        vid.offset=0;
        vid.filenumber=[vid.filenumber 0];
        %save updated header file
        save([out_path '\header'],'vid');
        %write image to binary file
        image=image-2^15;
        fwrite(binary,image,'int16','b');
        fclose(binary);
    end
    
end
