% This is a portion of code saved from the FitAois callback within imscroll
% Should be placed in the location marked by
% *** filler_for_imscroll_fit_aois_callback  placed here


for indx=1:maoi                                 % For loop over the different AOIs

                                                % Find out if user wants a
                                                % fixed or moving aoi
                                                % startparm=1 for fixed
                                                % startparm=2 for moving
 startparameter=get(handles.StartParameters,'Value');
 switch startparameter                          % This switch is not necessary yet, but will be when
                                                % more choises are added
     case 1
         inputstartparm=1;                      % Fixed AOI
     case 2
         inputstartparm=2;                      % Moving AOI
     case 3 
         inputstartparm=2;
     case 4
         inputstartparm=2;
 end
         

 folderuse=get(handles.ImageSource,'Value');    % Defines source of images (=1 for tiff folder, 2 for ram images, 3 for glimpse folder)
                                                % 
 if naoi==7
                    % naoi== # of columns in aoiinfo2
                        % Here for Danny's case where we add an extra
                        % column to aoiinfo2 and wish to integrate
                        % according to the specified pixnum (rather than
                        % the pixnum set in the gui.  The 7th column merely
                        % identifies the original AOI number for which the
                        % intermediate and large AOIs were constructed to
                        % surround.
           %[(frms columun vec)  ave         x                            y                           pixnum                       aoinum]           
      oneaoiinf=[frms  ave*ones(mfrms,1) aoiinf(indx,3)*ones(mfrms,1) aoiinf(indx,4)*ones(mfrms,1) aoiinf(indx,5)*ones(mfrms,1) aoiinf(indx,6)*ones(mfrms,1)];
 else
      oneaoiinf=[frms  ave*ones(mfrms,1) aoiinf(indx,3)*ones(mfrms,1) aoiinf(indx,4)*ones(mfrms,1) pixnum*ones(mfrms,1) aoiinf(indx,6)*ones(mfrms,1)];
 end
                        % build mapstruc for a single aoi: (How about building mapstruc for ALL aois here?) 
 mapstruc=build_mapstruc(oneaoiinf,inputstartparm,folder,folderuse,handles);

 

 size(mapstruc);
                        % Use that mapstruc to fit a single aoi over the
                        % specified frame range (see build_mapstruc or
                        % gauss2d_mapstruc_v2 for listing of what 
                        % mapstruc contains
 oneargoutsStructure=gauss2d_mapstruc_v2(mapstruc,handles);

%   argouts=gauss2d_seq_ave(dum,images,folder,frms,xypt,pixnum,handles);       
                                                   
   [mcol mrose]=size(oneargoutsStructure.ImageData);
                                                    % Add column specifying
                                                    % the AOI number
   oneargoutsStructure.ImageData=[ones(mcol,1)*aoiinf(indx,6) oneargoutsStructure.ImageData]; 
   oneargoutsStructure.BackgroundData=[ones(mcol,1)*aoiinf(indx,6) oneargoutsStructure.BackgroundData]; 
   
   if naoi==7
                        % naoi== # of columns in aoiinfo2
                        % Here for Danny's case where we generate 2 extra
                        % aois (of size specified in foldstruc.Pixnums)
                        % for each original aoi.  Add 2 columns to the
                        % argouts to maintain identify of the orignal aoi #
                        %   [  ....       pixnum    (original aoi#) ]
        oneargoutsStructure.ImageData=[oneargoutsStructure.ImageData ones(mcol,1)*aoiinf(indx,5) ones(mcol,1)*aoiinf(indx,7)];
        oneargoutsStructure.BackgroundData=[oneargoutsStructure.BackgroundData ones(mcol,1)*aoiinf(indx,5) ones(mcol,1)*aoiinf(indx,7)];

   end

   argoutsImageData=[argoutsImageData;oneargoutsStructure.ImageData];
   argoutsBackgroundData=[argoutsBackgroundData;oneargoutsStructure.BackgroundData];

                                                    
                                                    
    if indx/5==round(indx/5)     % periodically save the output data file
                                 % just in case the loop is interrupted
        aoifits.data=argoutsImageData;
        aoifits.BackgroundData=argoutsBackgroundData;   
        eval(['save ' handles.FileLocations.data outputName ' aoifits']);
        handles.aoifits1=aoifits;                        % store our structure in the handles structure
        handles.aoifits2=aoifits;
        guidata(gcbo,handles);
    end

%imageset=images;

%keyboard
                                      
%axes(handles.axes2);
%plot(argouts(:,1),argouts(:,5),'r')
sprintf('indx=%f',indx)
end

