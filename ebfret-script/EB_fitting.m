function EB_fitting(csvpath)

maxState = 4;
restarts = 2;
dir = uigetdir();
dataDir = [dir, '\'];
[~,~,parametersIn] = xlsread(csvpath);
nFile = length(parametersIn(:,1))-1;
for iFile = 2:nFile + 1
    
    traceFile = load([dataDir, parametersIn{iFile,1},'_traces.dat'],'-mat');
    fprintf('process file %s\n',parametersIn{iFile,1});
    channels = fieldnames(traceFile.traces);
    eb_result = struct;
    isSuccess = true;
    for i = 1:length(channels)
        i_channelName = channels{i};
        i_Traces = traceFile.traces.(i_channelName);
        [TracesOut, scale] = scaleTracesTo01(i_Traces);
        
        Input = num2cell(TracesOut',1);
        try
            runs = eb_fret(Input, [1:maxState], restarts);
        catch
            isSuccess = false;
            fprintf('failed in file %s, channel %s\n', parametersIn{iFile,1},i_channelName);
            break
        end
        
        
        [Vb, Vit, Selection] = selectK(runs);
        Vit = scaleVitBack(Vit, scale);
        eb_result.(i_channelName).runs = runs;
        eb_result.(i_channelName).Vit = Vit;
        eb_result.(i_channelName).selection = Selection;
        eb_result.(i_channelName).scale = scale;
    end
    
    if isSuccess
        save([dataDir, parametersIn{iFile,1},'_eb.dat'], 'eb_result');
    end
    
end
end
