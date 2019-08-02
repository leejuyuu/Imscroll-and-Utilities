

FileTif='D:\Google Drive\Research\Microscope construction\Capture\20190525-16-10-qd655_10nM-gain20-10ms.tif';
% warning off tifflib:TIFFReadDirectory:libraryWarning
% InfoImage = imfinfo(FileTif);
% mImage = InfoImage(1).Width;
% nImage = InfoImage(1).Height;
% NumberImages = length(InfoImage);

profile on
FileID = tifflib('open',FileTif,'r');

warning('off','last')

nImage = tifflib('getField',FileID,Tiff.TagID.ImageLength);
mImage = tifflib('getField',FileID,Tiff.TagID.ImageWidth);



FinalImage = zeros(nImage,mImage,1,'uint16');
rps = min(tifflib('getField',FileID,Tiff.TagID.RowsPerStrip),nImage);
 
for i=1:1
   
    tifflib('setDirectory',FileID,i-1);
   
    % Go through each strip of data.
   
   for r = 1:rps:nImage
      row_inds = r:min(nImage,r+rps-1);
      stripNum = tifflib('computeStrip',FileID,r-1);
      FinalImage(row_inds,:,i) = tifflib('readEncodedStrip',FileID,stripNum-1);
   end
   
end

tifflib('close',FileID);

profile off
profile viewer