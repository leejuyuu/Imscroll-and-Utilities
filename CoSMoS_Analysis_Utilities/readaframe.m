function pc=readaframe(gfolder,filesource, imagenum)
%
% function readaframe(gfolder,filesource)
%
% written for the drifting() function
% Will return one image frame
%
% gfolder == filepath to file
%
% filesource ==1 for glimps file
%              2 for tiff file
% imagenum == number of the image
if filesource ==1
   fn = 'header.mat';                      % header file in the GLIMPSE folder
   eval(['load ' [gfolder fn] ' -mat']);   % loads the vid structure from the GLIMPSE folder
                                           % Load one example frame
   pc=glimpse_image(gfolder,vid,imagenum); 
elseif filesource ==2
    pc=imread(gfolder,'tiff',imagenum);
end
