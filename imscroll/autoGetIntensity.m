function out = autoGetIntensity(csvpath,map)
[~,~,parametersIn] = xlsread(csvpath);
A = load('/gui_files/filelocations.dat','-mat');
mapDir = A.FileLocations.mapping;
dataDir = A.FileLocations.data;
input = struct;
A = load([dataDir, char(parametersIn(2,1)),'_driftfit.dat'],'-mat');
redImagePath = A.aoifits.tifFile;
greenImagePath = strrep(redImagePath,'red','green');
A = load([dataDir, char(parametersIn(2,1)),'_driftlist.dat'],'-mat');
input.driftlist = A.driftlist;
A = load([dataDir, char(parametersIn(2,1)),'_aoi.dat'],'-mat');
input.aois = A.aoiinfo2;
A = load([mapDir,map,'.dat'],'-mat');
input.map = A.fitparmvector;








end