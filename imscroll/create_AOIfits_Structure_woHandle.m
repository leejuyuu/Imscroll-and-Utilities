function aoifits = create_AOIfits_Structure_woHandle(imagePath,aoiinfo,aoiWidth,frameAverage)
% Define the output structure of the AOIfits data, called by
% Imscroll/FitAOIs callback


% error handling
if isempty(imagePath)
    error('folder not specified\n%s','')
end
if isempty(aoiinfo)
    error('aoiinfo not given\n%s','')
end
% default values
if nargin < 4
    frameAverage = 1;
end
if nargin < 3
    aoiWidth = 6;
end

aoifits.dataDescription = '[aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]';
aoifits.parameter = [frameAverage aoiWidth];
aoifits.parameterDescription='[ave pixnum]';
aoifits.tifFile=imagePath;
aoifits.centers=aoiinfo(:,3:4);
aoifits.centersDescription='[aoi_xcenters aoi_ycenters]';
aoifits.aoiinfo2Description='[(framenumber when marked) ave x y pixnum aoinumber]';
aoifits.aoiinfo2=aoiinfo;

end