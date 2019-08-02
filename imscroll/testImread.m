FileTif='D:\TYL\PriA_project\Expt_data\20190513\L3_forkcy5_02\02_GstPriA_40nM_SaDnaD_02.tif';
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
% NumberImages=length(InfoImage);
profile on

FinalImage2=zeros(nImage,mImage,1,'uint32');
for i=1:1
   FinalImage2(:,:,i)=imread(FileTif,'tiff',i);
end
image2 = mean(FinalImage2,3);
profile off
profile viewer