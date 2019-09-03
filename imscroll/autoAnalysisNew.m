function out = autoAnalysisNew(csvpath,mapFileName)
addpath('D:\TYL\Google Drive\Research\All software editing\Imscroll-and-Utilities\CoSMoS_Analysis_Utilities')

[~,~,parametersIn] = xlsread(csvpath);

[mapDir, ~] = loadCommonDirPath();
dir = uigetdir();
dataDir = [dir, '\'];
mapMatrix = loadMapMatrix(mapDir,mapFileName);
nFile = length(parametersIn(:,1))-1;
for iFile = 2:nFile + 1
    input = struct;
    A = load([dataDir, parametersIn{iFile,1},'_driftfit.dat'],'-mat');
    ImagePath = A.aoifits.tifFile;
    driftfit = A.aoifits;
    
    %{
    driftlist = A.driftlist;
    %}
    A = load([dataDir, parametersIn{iFile,1},'_aoi.dat'],'-mat');
    input.aois = A.aoiinfo2;
    
%     A = load([ImagePath(1:end-4),'.dat'],'-mat');
    input.time = importTimeBase(ImagePath);
    [driftlist,param] = makeDriftlistLimited(parametersIn{iFile,2},...
        parametersIn{iFile,3},parametersIn{iFile,3}+parametersIn{iFile,4}-1,...
    input.time,driftfit);
save([dataDir, parametersIn{iFile,1},'_driftlist.dat'],'driftlist');
save([dataDir, parametersIn{iFile,1},'_driftparam.dat'],'param');


    nAOIs = length(input.aois(:,1));
    aoifits = create_AOIfits_Structure_woHandle(ImagePath,input.aois);
    imageFileProperty = getImageFileProperty(ImagePath);
    aoiinfo = input.aois;
    
    aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),mapMatrix);
    aoiProcessParameters = struct(...
        'frameRange',(parametersIn{iFile,2}:parametersIn{iFile,3}),...
        'frameAverage', parametersIn{iFile,4}...
        );
    shiftedXY = batchShitfAOI(aoiinfo(:,[3 4]),aoiinfo(1,1),...
        aoiProcessParameters.frameRange,driftlist);
    [~,aoiinfo] = removeOutOfEdgeAOIs(shiftedXY,aoiinfo,imageFileProperty);
    
    aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),getInverseMap(mapMatrix));
    shiftedXY = batchShitfAOI(aoiinfo(:,[3 4]),aoiinfo(1,1),...
        aoiProcessParameters.frameRange,driftlist);
    [~,aoiinfo] = removeOutOfEdgeAOIs(shiftedXY,aoiinfo,imageFileProperty);
    
    
    
    pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,driftlist);
    aoifits.dataRed = pc.ImageData;
    aoifits.backgroundTraceRed = pc.BackgroundTrace;
    aoifits.beforeBackgroundRed = pc.beforeBackground;
    
    
    %%
    aoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),mapMatrix);
    pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,aoiinfo,aoiProcessParameters,driftlist);
    aoifits.dataGreen = pc.ImageData;
    aoifits.backgroundTraceGreen = pc.BackgroundTrace;
    aoifits.beforeBackgroundGreen = pc.beforeBackground;
    
    save([dataDir, parametersIn{iFile,1},'_intcorrected.dat'],'aoifits');
    nAOIs = length(aoiinfo(:,1));
    traceGreen = reshape(aoifits.dataGreen(:,8),nAOIs,[]);
    traceRed = reshape(aoifits.dataRed(:,8),nAOIs,[]);
    
    traces = struct(...
        'green',traceGreen,...
        'red',traceRed...
        );
    save([dataDir, parametersIn{iFile,1},'_traces.dat'],'traces');    
    %%
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
    region = {257 imageFileProperty.width 1 imageFileProperty.height};
    AllSpotsHigh = FindAllSpots(imageFileProperty,region,aoiProcessParameters,highParameters);
    AllSpotsLow = FindAllSpots(imageFileProperty,region,aoiProcessParameters,lowParameters);
    
    radius = 1.5;
    radius_hys = 1.5;
    shiftedXY = batchShitfAOI(aoiinfo(:,[3 4]),aoiinfo(1,1),...
        aoiProcessParameters.frameRange,driftlist);
    IntervalDataStructure = SpotIntervals(aoiProcessParameters.frameRange,...
        radius,radius_hys,aoiinfo,shiftedXY,AllSpotsHigh,AllSpotsLow,input.time');
    save([dataDir, parametersIn{iFile,1},'_interval.dat'],'IntervalDataStructure');
    
    
end
fprintf('done\n');
end