function tests = testAutoAnalysis
    tests = functiontests(localfunctions);
end

function testFindAllSpots(testCase)
csvpath = '/run/media/tzu-yu/linuxData/Git_repos/Imscroll/imscroll/test/test_data/20200228parameterFile.xlsx';
channelConfig = readtable(csvpath, 'Sheet', 'channels');
nChannels = height(channelConfig);
[~,~,parametersIn] = xlsread(csvpath);

imageMainDir = '/run/media/tzu-yu/linuxData/Git_repos/Imscroll/imscroll/test/test_data/';
for iFile = 2
    fileImageDir = [imageMainDir, parametersIn{iFile,9}];
    sub_dir_names = list_subdirectories(fileImageDir);
    aoiProcessParameters = struct(...
        'frameRange',(parametersIn{iFile,2}:parametersIn{iFile,3}),...
        'frameAverage', parametersIn{iFile,4}...
        );
    for iChannel = 2:nChannels
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
        A = load('MagxyCoord.dat', '-mat');
        switch iChannelName
            case 'green'
                region = num2cell(A.MagxyCoord(8,:));
            case 'red'
                region = num2cell(A.MagxyCoord(3,:));
            otherwise
                error('error in autoAnalysisGlimpseMultichannel\n%s',...
                    'channel not supported')
        end
        imagePath = [fileImageDir,'/', sub_dir_names{channelConfig{iChannel, 'order'}}, '/'];
        imageFileProperty = getImageFileProperty(imagePath);        
        AllSpotsHigh = FindAllSpots(imageFileProperty,region,aoiProcessParameters,highParameters);
        AllSpotsLow = FindAllSpots(imageFileProperty,region,aoiProcessParameters,lowParameters);
        allspot = load('test/test_data/L2_allspots.mat');
        verifyEqual(testCase, AllSpotsHigh, allspot.AllSpotsHigh)
        verifyEqual(testCase, AllSpotsLow, allspot.AllSpotsLow)
        
    end
    
end
end