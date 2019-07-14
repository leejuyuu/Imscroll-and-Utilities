function out = autoAnalysisNew(csvpath,mapFileName)
[~,~,parametersIn] = xlsread(csvpath);

[mapDir, dataDir] = loadCommonDirPath();
mapMatrix = loadMapMatrix(mapDir,mapFileName);
nFile = length(parametersIn(:,1))-1;
for iFile = 2:nFile + 1
    input = struct;
    A = load([dataDir, parametersIn{iFile,1},'_driftfit.dat'],'-mat');
    ImagePath = A.aoifits.tifFile;
    
    input.driftlist = A.driftlist;
    A = load([dataDir, parametersIn{iFile,1},'_aoi.dat'],'-mat');
    input.aois = A.aoiinfo2;
    
    A = load([ImagePath(1:end-4),'.dat'],'-mat');
    input.time = A.vid.ttb;
    
    nAOIs = length(input.aois(:,1));
    aoifits = create_AOIfits_Structure_woHandle(ImagePath,input.aois);
    imageFileProperty = getImageFileProperty(ImagePath);
    aoiinfo = input.aois;
    
    aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),mapMatrix);
    aoiProcessParameters = struct(...
        'frameRange',(parametersIn{iFile,2}:parametersIn{iFile,3}),...
        'frameAverage', parametersIn{iFile,4}...
        );
    shiftedXY = batchShitfAOI(aoiinfo,aoiProcessParameters.frameRange,input.driftlist);
    [~,aoiinfo] = removeOutOfEdgeAOIs(shiftedXY,aoiinfo,imageFileProperty);
    pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,input.driftlist);
    aoifits.data = pc.ImageData;
    aoifits.backgroundTrace = pc.BackgroundTrace;
    aoifits.beforeBackground = pc.beforeBackground;
    save([dataDir, parametersIn{iFile,1},'_intcorrected.dat'],'aoifits');
    
    highParameters = struct(...
        'noiseDiameter',1,...
        'spotDiameter',5,...
        'spotBightness',parametersIn{iFile,5}...
        );
    lowParameters = struct(...
        'noiseDiameter',1,...
        'spotDiameter',5,...
        'spotBightness',parametersIn{iFile,6}...
        );
    region = {1 imageFileProperty.width 1 imageFileProperty.height};
    AllSpotsHigh = FindAllSpots(imageFileProperty,region,aoiProcessParameters,highParameters);
    AllSpotsLow = FindAllSpots(imageFileProperty,region,aoiProcessParameters,lowParameters);
    
    radius = 1.5;
    radius_hys = 1.5;
    shiftedXY = batchShitfAOI(aoiinfo,aoiProcessParameters.frameRange,input.driftlist);
    IntervalDataStructure = SpotIntervals(aoiProcessParameters.frameRange,...
        radius,radius_hys,aoiinfo,shiftedXY,AllSpotsHigh,AllSpotsLow,input.time');
    save([dataDir, parametersIn{iFile,1},'_interval.dat'],'IntervalDataStructure');
end