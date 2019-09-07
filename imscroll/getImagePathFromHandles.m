function imagePath = getImagePathFromHandles(handles)
fileType = get(handles.ImageSource,'Value');
switch fileType
    case 1
        imagePath = handles.TiffFolder;
    case 3
        imagePath = handles.gfolder;
    otherwise
        error('Error in getImagePathFromHandles, the image type is not supported in this version')
end

end