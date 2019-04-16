function pc=glimpse_from_tiff(intiffpath,frames,out_path,user)
%
% function glimpse_from_tiff(intiffpath,frames,out_path,user)
%
% Will make a glimpse file from a stacked tiff.  
%
%intiffpath == path to the tiff file 
%             e.g. C:\larry\image_data\december_22_2006\b15p111a.tif 
% user == user name  e.g. 'inna'
% frames == tiff frames that will be written to glimpse
%            e.g. [ 10:30]
%outpath== path to the folder that will contain the glimpse file
%          e.g. 'c:\larry\image_data\tst_glimpse001'
[rosefrms colfrms]=size(frames);
for indx=1:max(rosefrms,colfrms)
im=double(imread(intiffpath,'tiff',frames(indx) ));
out_glimpse(user,im,out_path);
end
pc=1;


