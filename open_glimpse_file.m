function open_glimpse_file(nFiles)
% cd('D:\matlab_CoSMoS');
cd('D:\TYL\Google Drive\Research\All software editing\Imscroll-and-Utilities');
path(pathdef, genpath(cd));

for iFile = 1:nFiles
    if iFile == 1
        
    foldstruct.gfolder = [uigetdir(), '\'];
    else
        foldstruct.(['gfolder', num2str(iFile)]) = [uigetdir(), '\'];
    end
end
UseDriftlist = input('use driftlist? y/n ','s');
if UseDriftlist == 'y'
    %load driftlist
    [fn, fp] = uigetfile('.dat','Select File to Open','data\');
    load([fp fn],'-mat');
    foldstruct.DriftList = driftlist;
end
imscroll(foldstruct)
end