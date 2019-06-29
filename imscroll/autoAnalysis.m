function out = autoAnalysis(csvpath,map)
[~,~,parametersIn] = xlsread(csvpath);
A = load('/gui_files/filelocations.dat','-mat');
mapDir = A.FileLocations.mapping;
dataDir = A.FileLocations.data;
input = struct;
A = load([dataDir, parametersIn{2,1},'_driftfit.dat'],'-mat');
redImagePath = A.aoifits.tifFile;
greenImagePath = strrep(redImagePath,'red','green');
A = load([dataDir, parametersIn{2,1},'_driftlist.dat'],'-mat');
input.driftlist = A.driftlist;
A = load([dataDir, parametersIn{2,1},'_aoi2.dat'],'-mat');
input.aois = A.aoiinfo2;
A = load([mapDir,map,'.dat'],'-mat');
input.map = A.fitparmvector;
A = load([redImagePath(1:end-12),'.dat'],'-mat');
input.time = A.vid.ttb;

nAOIs = length(input.aois(:,1));
aoifits = create_AOIfits_Structure_woHandle(greenImagePath,input.aois);
imageFileProperty = getImageFileProperty(greenImagePath);
aoiinfo = input.aois;

aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),getInverseMap(input.map));
aoiProcessParameters = struct(...
    'frameRange',(parametersIn{2,2}:parametersIn{2,3}),...
    'frameAverage', parametersIn{2,4}...
    );
pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,input.driftlist);
aoifits.data = pc.ImageData;
out = aoifits;

highParameters = struct(...
'noiseDiameter',1,... 
'spotDiameter',5,...
'spotBightness',parametersIn{2,5}...
);
lowParameters = struct(...
'noiseDiameter',1,... 
'spotDiameter',5,...
'spotBightness',parametersIn{2,6}...
);
region = {1 imageFileProperty.width 1 imageFileProperty.height};
AllSpotsHigh = FindAllSpots(imageFileProperty,region,aoiProcessParameters,highParameters);
AllSpotsLow = FindAllSpots(imageFileProperty,region,aoiProcessParameters,lowParameters);

radius = 1.5;
radius_hys = 1.5;
shiftedXY = batchShitfAOI(aoiinfo,aoiProcessParameters.frameRange,input.driftlist);
IntervalDataStructure = SpotIntervals(aoiProcessParameters.frameRange,...
    radius,radius_hys,aoiinfo,shiftedXY,AllSpotsHigh,AllSpotsLow,input.time');
out = IntervalDataStructure;
end