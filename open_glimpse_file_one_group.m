function open_glimpse_file_one_group()
% cd('D:\matlab_CoSMoS');
% cd('D:\TYL\Google Drive\Research\All software editing\Imscroll-and-Utilities');
% cd('/mnt/main/git_repos/Imscroll-and-Utilities');
% path(pathdef, genpath(cd));
master_folder = uigetdir();
sub_dir_names = list_subdirectories(master_folder);

for iFile = 1:length(sub_dir_names)
    if iFile == 1
        
    foldstruct.gfolder = [master_folder, '/', sub_dir_names{1} '/'];
    else
        foldstruct.(['gfolder', num2str(iFile)]) = [master_folder, '/', sub_dir_names{iFile} '/'];
    end
end
UseDriftlist = input('use driftlist? y/n ','s');
if UseDriftlist == 'y'
    %load driftlist
    [fn, fp] = uigetfile('.dat','Select File to Open','data/');
    load([fp fn],'-mat');
    foldstruct.DriftList = driftlist;
end
imscroll(foldstruct)
end