function out = autoFRETAnalysisNew(csvpath,mapFileName)
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
    shiftedXY = batchShitfAOI(aoiinfo,aoiProcessParameters.frameRange,input.driftlist);
    [~,aoiinfo] = removeOutOfEdgeAOIs(shiftedXY,aoiinfo,imageFileProperty);
    
    aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),mapMatrix);
    shiftedXY = batchShitfAOI(aoiinfo,aoiProcessParameters.frameRange,input.driftlist);
    [~,aoiinfo] = removeOutOfEdgeAOIs(shiftedXY,aoiinfo,imageFileProperty);
    
    aoiProcessParameters = struct(...
        'frameRange',(parametersIn{iFile,2}:parametersIn{iFile,3}),...
        'frameAverage', parametersIn{iFile,4}...
        );
        
    pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,input.driftlist);
    aoifits.dataGreen = pc.ImageData;
    aoifits.backgroundTraceGreen = pc.BackgroundTrace;
    aoifits.beforeBackgroundGreen = pc.beforeBackground;
    
    aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),getInverseMap(mapMatrix));
    pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,input.driftlist);
    aoifits.dataRed = pc.ImageData;
    aoifits.backgroundTraceRed = pc.BackgroundTrace;
    aoifits.beforeBackgroundRed = pc.beforeBackground;
    
    save([dataDir, parametersIn{iFile,1},'_intcorrected.dat'],'aoifits');
    nAOIs = length(aoiinfo(:,1));
    traceGreen = reshape(aoifits.dataGreen(:,8),nAOIs,[]);
    traceRed = reshape(aoifits.dataRed(:,8),nAOIs,[]);
    traceTotal = traceGreen + traceRed;
    FRETtrace = traceRed./(traceGreen+traceRed);
    traces = struct(...
        'donor',traceGreen,...
        'acceptor',traceRed,...
        'total',traceToTal,...
        'FRET',FRETtrace...
        );
    save([dataDir, parametersIn{iFile,1},'_FRETtraces.dat'],'traces');
end