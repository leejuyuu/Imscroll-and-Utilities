FileTif='D:\TYL\PriA_project\Expt_data\20190513\L3_forkcy5_02\02_GstPriA_40nM_03.tif';
% InfoImage=imfinfo(FileTif);
% mImage=InfoImage(1).Width;
% nImage=InfoImage(1).Height;
% NumberImages=length(InfoImage);
profile on

FinalImage=zeros(nImage,mImage,'uint32');
for i=1:20
   FinalImage = FinalImage + uint32(imread(FileTif,'tiff',i));
end
image = FinalImage/20;
profile off
profile viewer