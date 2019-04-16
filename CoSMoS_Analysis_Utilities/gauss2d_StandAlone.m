function pc=gauss2d_StandAlone(FitStruc)
%
% function gauss2d_StandAlone(FitStruc)
%
% A stand alone program encompassing some of the fitting tasks currently
% performed by imscroll.  Initially intended for using the computer cluster 
% to gaussian fitlarge data sets.
%
% FitStruc.gfolder== fp    Path to the glimpse image sequence folder
%              e.g. 'C:\larry\image_data\november_09_2013\b29p61a_295\'
% FitStruc.FrameRange == [vector list of frame numbers that will be fit]
% FitStruc.FrameAve == number of images to average prior to fitting.  The
%                  program will fetch this number of frames from the list
%                  in FitStruc.FrameRange, average those frames together
%                  then fit the averaged image.
% FitStruc.gheader == vid header file within the folder FitStruc.gfolder.
%                 User can fetch this using
%                >> eval(['load ' FitSTruc.gfolder 'header.mat'])     
%                >> FitStruc.gheader=vid;
% FitStruc.aoiinfo2 == aoiinfo2 matrix listing information for the AOIs
%                that will be fit by this function.  Matrix of the form:
%                [frm#  ave  x  y  pixnum  aoi#]
% FitStruc.PixelNumberFit== specifies AOI size that will be used in the
%                  gaussian fit (e.g. = 10).  The AOI dimension will be 
%                  (FitStruc.PixelNumberFit)x(FitStruc.PixelNumberFit) 
% FitStruc.PixelNumberInt== specifies AOI size that will be integrated
%                  (e.g. = 3).  The AOI dimension will be 
%                  (FitStruc.PixelNumberFit)x(FitStruc.PixelNumberFit) 
% 










% just for reference:
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source

