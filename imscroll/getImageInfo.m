function imageInfo = getImageInfo(path,imageType)
% imageInfo = getImageInfo(path)
% returns the information of image stack file.
% imageInfo = struct(
% frame number
% pixel size

switch imageType
    case 1
        % Tiff stack
        imageFileInfo = imfinfo(path);
        width = imageFileInfo(1).Width;
        height = imageFileInfo(1).Height;
        NumberImages = length(imageFileInfo);
        imageInfo = struct(...
            'nFrames', NumberImages,...
            'width',width,...
            'height',height);
    case 3
        % Glimpse binary
        headerPath = [path,'header.mat'];
        load(headerPath)
        imageInfo = struct(...
            'nFrames', vid.nframes,...
            'width',vid.width,...
            'height',vid.height);
    otherwise 
        error(sprintf('Error in getImageInfo.m\nimage type not supported in this version'))
end

end