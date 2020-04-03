function [driftlist,param] = makeDriftlistLimited(fstart,fend,sequenceLength,...
    time,driftfit)


%Limited to the cases where the markers lives throughout the sequence

%define parameters

range = [fstart fend];
userange = [fstart fend];

CorrectionRange = [fstart fend];
poly = [2 11 2 11];
vid.ttb = time;

dat = extract_aoifits_aois(driftfit);
[~,~,numAOI] = size(dat);
xy_cell = cell(1,numAOI);
for i = 1:numAOI
    xy_cell{i}.dat = dat(:,:,i);
    xy_cell{i}.range = range;
    xy_cell{i}.userange = userange;
end
drifts_time = construct_driftlist_time_v1(xy_cell,vid,CorrectionRange,sequenceLength,poly);
drifts = driftlist_time_interp(drifts_time.cumdriftlist,vid);
driftlist = drifts.diffdriftlist;

param = struct(...
    'xy_cell',xy_cell,...
    'SequenceLength',sequenceLength,...
    'CorrectionRange',CorrectionRange,...
    'vid',vid...
    );
% %save parameters
% [fn, fp] = uiputfile('.dat','Select File to Write','data\');
% save([fp fn], 'xy_cell','SequenceLength','CorrectionRange','vid');
% 
% %save driftlist
% [fn, fp] = uiputfile('.dat','Select File to Write','data\');
% save([fp fn], 'driftlist');







end