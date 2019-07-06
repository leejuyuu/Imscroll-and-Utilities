function [mapDir, dataDir] = loadCommonDirPath()
A = load('/gui_files/filelocations.dat','-mat');
mapDir = A.FileLocations.mapping;
dataDir = A.FileLocations.data;
end