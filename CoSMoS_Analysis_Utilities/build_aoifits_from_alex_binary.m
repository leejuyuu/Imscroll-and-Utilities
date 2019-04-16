function pc=build_aoifits_from_alex_binary(Path2Results,aoinums,aoifits)
%
%   function build_aoifits_from_alex_binary(Path2Binary,aoinums,aoifits)
%
% Will use the output from the Alex gui_spot_model to build an aoifits
% structure that may be input and viewed from within imscroll.  The
% binary event traces are stored in a 'results' directory by gui_spot_model
% and binary traces will be imported into this function and 
% then substituted for the integrated trace data in the aoifits stucture
% supplied as an input arguement.  This will be output in the form of an 
% aoifits structure.
%
% Path2Results == path to the 'results' directory output by gui_spot_model.
%          Just use [fn fp]= uigetfile to navigate to one file in the
%          directory and use Path2Binary = fp
% aoinums == vector of integer values that specify the aoi numbers
%             e.g. =[1:122]  when aoifits = b26p110b.dat
% aoifits == a dummy input aoifits structure that contains the
%         integrated traces corresponding to the binary traces output by
%         the gui_spot_model.  Only the aoifits.data portion will be
%         altered by this function, substituting the binary traces for the
%         'offset' arguement (column 7).  This will allow the user to 
%         view both the binary and integrated traces (since the latter will 
%         still be present).
% [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]
% 
% OUTPUT:
% an aoifits structure from the input arguement, where the binary traces
% from the gui_spot_model program have been substituted for the column 7
% 'offset' values in the aoifits.data matrix.
pc=aoifits;         % aoifits will be output again after substituting the binary traces
for indxaoi=aoinums
                % Loop through all the Aois'
    eval(['load ' Path2Results num2str(indxaoi) '.mat -mat'])    % Loads the 'results' variable
                             % pick out aoifits.data lines matching
                              % this aoi
    logik=(aoifits.data(:,1)==indxaoi);
    
                             % And put the 'high' value output into the
                            % 'offset' column for this aoi and frame number
    pc.data(logik ,7)=results.classes(:,2);
   
end
    %keyboard
   



%pc=aoifits;         % aoifits will be output again after substituting the binary traces
%for indxaoi=aoinums
                % Loop through all the Aois'
%    eval(['load ' Path2Binary num2str(indxaoi) '.mat -mat'])    % Loads the 'results' variable
%    frames=results.classes(:,1);
    %keyboard
%    indxaoi
%    for indxfrms=1:length(frames)                % Loop over all the frame numbers
                               % Pick out this frame number and aoi
      
 %       logik=(aoifits.data(:,2)==results.classes(indxfrms,1))&(aoifits.data(:,1)==indxaoi);
        
                            % And put the 'high' value output into the
                            % 'offset' column for this aoi and frame number
 %       pc.data(logik,7)=results.classes(indxfrms,2);
 %   end
%end
