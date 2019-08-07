clear;clc;close all;
path(pathdef,genpath('D:\TYL\Google Drive\Research\All software editing\Imscroll-and-Utilities\imscroll'))
cd ('D:\TYL\Google Drive\Research\All software editing\Imscroll-and-Utilities\imscroll')
NumofFiles = 1;
i = 1;
%{
while true
    [fn, fp] = uigetfile('*.tif');
    if i==1
        foldstruct.folder = [fp fn] ;
    else
        foldstruct.(sprintf('folder%d',i)) = [fp fn];
    end
    
    ifcontinue = input('enter "y" to continue loading files... ','s');
    if ifcontinue ~= 'y'
        break
    end
    
    i = i+1;
    
end
%}
%
for k = 1:NumofFiles
    [fn, fp] = uigetfile('*.tif');
    if k==1
        foldstruct.folder = [fp fn] ;
    else
        foldstruct.(sprintf('folder%d',k)) = [fp fn];
    end
    
    
end

UseDriftlist = input('use driftlist? y/n','s');
if UseDriftlist == 'y'
    %load driftlist
    [fn, fp] = uigetfile('.dat');
    load([fp fn],'-mat');
    foldstruct.DriftList = driftlist;
end
%}
% [fn, fp] = uigetfile('*.tif');
%
% foldstruct.folder = [fp 'cropped\' fn '_green.tif'] ;
% foldstruct.folder2 = [fp 'cropped\' fn '_red.tif'] ;

imscroll(foldstruct)