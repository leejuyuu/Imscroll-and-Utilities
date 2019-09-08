function autoAnalysisGlimpseMultichannel(csvpath)
addpath('D:\TYL\Google Drive\Research\All software editing\Imscroll-and-Utilities\CoSMoS_Analysis_Utilities')

channelConfig = readtable(csvpath, 'Sheet', 'channels');

[~,~,parametersIn] = xlsread(csvpath);

[mapDir, ~] = loadCommonDirPath();
% dataDir = uigetdir('','Select Data Directory');
% dataDir = [dataDir, '\'];
dataDir = 'D:\TYL\PriA_project\Analysis_Results\20190907\imscroll\';
% imageMainDir = uigetdir('','Select Image Directory');
% imageMainDir = [imageMainDir, '\'];
imageMainDir = 'D:\TYL\PriA_project\Expt_data\20190907\L3\';
% mapMatrix = loadMapMatrix(mapDir,mapFileName);
nFile = length(parametersIn(:,1))-1;
for iFile = 2:nFile + 1
    input = struct;
    
    A = load([dataDir, parametersIn{iFile,1},'_driftfit.dat'],'-mat');
    %     ImagePath = A.aoifits.tifFile;
    driftfit = A.aoifits;
    
    A = load([dataDir, parametersIn{iFile,1},'_aoi.dat'],'-mat');
    input.aois = A.aoiinfo2;
    
    fileImageDir = [imageMainDir, parametersIn{iFile,9}];
    
    sub_dir_names = list_subdirectories(fileImageDir);
    
    image
    A = load([fileImageDir,'\', sub_dir_names{1}, '\header.mat']);
    ttb = A.vid.ttb;
    AOIImagePath = [fileImageDir,'\', sub_dir_names{1}, '\'];
    
    
    
    
    [driftlist,param] = makeDriftlistLimited(parametersIn{iFile,2},...
        parametersIn{iFile,3},parametersIn{iFile,3}+parametersIn{iFile,4}-1,...
        ttb,driftfit);
    save([dataDir, parametersIn{iFile,1},'_driftlist.dat'],'driftlist');
    save([dataDir, parametersIn{iFile,1},'_driftparam.dat'],'param');
    
    aoiProcessParameters = struct(...
        'frameRange',(parametersIn{iFile,2}:parametersIn{iFile,3}),...
        'frameAverage', parametersIn{iFile,4}...
        );
    
    aoifits = create_AOIfits_Structure_woHandle(AOIImagePath,input.aois);
    AOIimageFileProperty = getImageFileProperty(AOIImagePath);
    aoiinfo = input.aois;
    
    shiftedXY = batchShitfAOI(aoiinfo(:,[3 4]),aoiinfo(1,1),...
        aoiProcessParameters.frameRange,driftlist);
    isGoodAOI = cell(1, 3);
    [~,~, isGoodAOI{1}] =...
        removeOutOfEdgeAOIs(shiftedXY,aoiinfo,AOIimageFileProperty);
    
    map = cell(1, 3);
    for iChannel = 2:3
                
        map{iChannel} = ...
            loadMapMatrix(mapDir, char(channelConfig{iChannel, 'mapFileName'}));
        iaoiinfo = aoiinfo;
        iaoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]), map{iChannel});
        shiftedXY = batchShitfAOI(iaoiinfo(:,[3 4]),iaoiinfo(1,1),...
            aoiProcessParameters.frameRange,driftlist);
        [~,~, isGoodAOI{iChannel}] =...
            removeOutOfEdgeAOIs(shiftedXY,iaoiinfo,AOIimageFileProperty);
        
        
        
    end
    isGoodAOI = [isGoodAOI{:}];
    isGoodAOI = ~any(~isGoodAOI, 2);
    aoiinfo = aoiinfo(isGoodAOI, :);
    nAOIs = length(aoiinfo(:,1));
       
    
    for iChannel = 1:3
        iChannelName = char(channelConfig{1, 'name'});
        imagePath = [fileImageDir,'\', sub_dir_names{channelConfig{iChannel, 'order'}}, '\'];
        imageFileProperty = getImageFileProperty(imagePath);
        if iChannel == 1
            iaoiinfo = aoiinfo;
        else
            iaoiinfo = aoiinfo;
            iaoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),map{iChannel});
        end
        pc = getAoiIntensityLinearInterpWithBackground(imageFileProperty,iaoiinfo,aoiProcessParameters,driftlist);
        aoifits.(['data', iChannelName]) = pc.ImageData;
        aoifits.(['backgroundTrace', iChannelName]) = pc.BackgroundTrace;
        aoifits.(['beforeBackground', iChannelName]) = pc.beforeBackground;
        traces.(iChannelName) = reshape(pc.ImageData(:,8),nAOIs,[]);
    end
    save([dataDir, parametersIn{iFile,1},'_intcorrected.dat'],'aoifits');      
    save([dataDir, parametersIn{iFile,1},'_traces.dat'],'traces');
    
    for iChannel = 2:3
        iChannelName = char(channelConfig{iChannel, 'name'});
        highParameters = struct(...
            'noiseDiameter',1,...
            'spotDiameter',5,...
            'spotBightness',parametersIn{iFile,iChannel*2+1}...
            );
        lowParameters = struct(...
            'noiseDiameter',1,...
            'spotDiameter',5,...
            'spotBightness',parametersIn{iFile,iChannel*2+2}...
            );
        switch iChannelName
            case 'green'
                region = {121, 378, 1, 256};
            case 'red'
                region = {127, 38, 257, 512};
            otherwise
                error('error in autoAnalysisGlimpseMultichannel\n%s',...
                    'channel not supported')
        end
        imagePath = [fileImageDir,'\', sub_dir_names{channelConfig{iChannel, 'order'}}, '\'];
        imageFileProperty = getImageFileProperty(imagePath);        
        AllSpotsHigh = FindAllSpots(imageFileProperty,region,aoiProcessParameters,highParameters);
        AllSpotsLow = FindAllSpots(imageFileProperty,region,aoiProcessParameters,lowParameters);
        
        radius = 1.5;
        radius_hys = 1.5;
        iaoiinfo = aoiinfo;
            iaoiinfo(:,[3 4]) = mapXY(aoiinfo(:,[3 4]),map{iChannel});
        shiftedXY = batchShitfAOI(iaoiinfo(:,[3 4]),iaoiinfo(1,1),...
            aoiProcessParameters.frameRange,driftlist);
        intervals.(iChannelName) = SpotIntervals(aoiProcessParameters.frameRange,...
            radius,radius_hys,iaoiinfo,shiftedXY,AllSpotsHigh,AllSpotsLow,ttb');
        
    end
    save([dataDir, parametersIn{iFile,1},'_interval.dat'],'intervals');
    
end
fprintf('done\n');
end