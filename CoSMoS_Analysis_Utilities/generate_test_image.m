function generate_test_image()
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
outpath = '/run/media/tzu-yu/linuxData/Git_repos/python_for_imscroll/python_for_imscroll/test/test_data/fake_im'
nFrames = 20;
imsize = [300, 200];
nPixels = imsize(1) * imsize(2);
user = 'lee';
for iFrame=1:nFrames
    image = reshape(iFrame:iFrame+nPixels-1, imsize);
    size(image)
out_glimpse(user,image,outpath);
end
end
