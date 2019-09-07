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
    
    redTraces = traceFile.traces.red;
    [redTracesOut, redscale] = scaleTracesTo01(redTraces);
    
    redInput = num2cell(redTracesOut',1);
    redruns = eb_fret(redInput, [1:maxState], restarts);
    
    % save('runstemp0810','runs');
    [redVb, redVit, redSelection] = selectK(redruns);
    redVit = scaleVitBack(redVit, redscale);
    
    
    greenTraces = traceFile.traces.green;
    [greenTracesOut, greenscale] = scaleTracesTo01(greenTraces);
    
    greenInput = num2cell(greenTracesOut',1);
    greenruns = eb_fret(greenInput, [1:maxState], restarts);
    
    % save('runstemp0810','runs');
    [greenVb, greenVit, greenSelection] = selectK(greenruns);
    greenVit = scaleVitBack(greenVit, greenscale);
    
    save([dataDir, parametersIn{iFile,1},'_eb.dat'],...
        'greenruns','redruns','greenVit','redVit','greenSelection','redSelection',...
        'greenscale', 'redscale');
    
end
end
