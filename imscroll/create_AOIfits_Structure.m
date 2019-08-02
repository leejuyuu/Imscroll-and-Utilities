function aoifits = create_AOIfits_Structure(handles)
% Define the output structure of the AOIfits data, called by
% Imscroll/FitAOIs callback

folder=handles.TiffFolder;
% next four lines because 'folder' cannot be empty, or we get an error
% message when referencing folder(1,:) in build_mapstruc.m
[aa, bb]=size(folder);
if (aa==0)&&(bb==0);
    folder='folder not specified';
end


aoiWidth = str2double(get(handles.PixelNumber,'String')); % Fetch the pixel number (aoi width)

frameAverage = round(str2double(get(handles.FrameAve,'String')));

aoiinf = handles.FitData; 

aoifits.dataDescription='[aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]';
aoifits.parameter=[frameAverage aoiWidth];
aoifits.parameterDescription='[ave pixnum]';
aoifits.tifFile=folder;
aoifits.centers=aoiinf(:,3:4);
aoifits.centersDescription='[aoi_xcenters aoi_ycenters]';
aoifits.aoiinfo2Description='[(framenumber when marked) ave x y pixnum aoinumber]';
aoifits.aoiinfo2=handles.FitData;
aoifits.AllSpotsDescription='aoifits.AllSpots{m,1}=[x y] spots in frm m;  {m,2}=# of spots,frame m; {m,3}=frame #; {1,4}=[firstframe:lastframe]; {2,4}=NoiseDiameter  SpotDiameter  SpotBrightness]'  ;
'{2,4}=NoiseDiameter  SpotDiameter  SpotBrightness]'  ;
aoifits.AllSpots=FreeAllSpotsMemory(handles.AllSpots);
aoifits.FarPixelDistance=handles.FarPixelDistance;      % See MapButton callback
aoifits.NearPixelDistance=handles.NearPixelDistance;    % case 20 and case 21
aoifits.Refaoiinfo2=handles.Refaoiinfo2;                % to see what these
aoifits.RefAOINearLogik=handles.RefAOINearLogik;        % are for. (part of background subtraction method)
aoifits.RefAOINearLogikDesc=' e.g. Bkgndaoifits.aoiinfo2(aoifits.RefAOINearLogik{12},:) for AOIs near to reference AOI #12 in aoifits.Refaoiinfo2';

end