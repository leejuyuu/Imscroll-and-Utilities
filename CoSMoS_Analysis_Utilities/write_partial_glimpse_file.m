function pc=write_partial_glimpse_file(Gfolder, new_Gfolder, FrameVector, DeleteExistingGfolder)
%
%  function write_partial_glimpse_file(Gfolder, new_Gfolder, FrameVector, DeleteExistingGfolder)
% 
% This function will create a glimpse file, using the images from the 
% existing glimpse file in Gfolder but only the frames specified
% in FrameVector.
%
% Gfolder == full path to the glimpse folder e.g.
%              'P:\image_data\April_28_2015\b31p10b_026\'
% new_Gfolder == full path to the new glimpse file that will be written.
%           This folder must already exist.
% FrameVector == vector listing the frames from Gfolder sequence that
%             will be written into the new_Gfolder folder location
% DeleteExistingGfolder == set to 0 to append frames to existing glimpse
%                    sequence in new_Gfolder.   Set to 1 to delete any
%                    existing sequence already in new_Gfolder (=1 will be
%                    more common situation)
%

% LJF 8/1/2015: Originally written for Grace to enable equalizing analysis of sequences
% recorded with different duty cycles (for bleaching effects).
FrameVector=round(FrameVector);     % Insure all the FrameVector entries are integer
[rose col]=size(FrameVector);
if (rose~=1)&(col~=1)
    error('FrameVector must be a single row')
end
if rose>col
    FrameVector=FrameVector';       % Insure that FrameVector is one row vector
end
lnew=length(FrameVector);       % number of frames in the new file
eval(['load ' Gfolder 'header.mat -mat'])  % load vid file from existing Gfolder
vid_old=vid;
tb=vid_old.ttb;                 % time base for the input glimpse file
vid_new.nframes=lnew;               % number of frames in the new file
vid_new.ttb=tb(FrameVector);        % Time base for the new file
if (exist([ new_Gfolder 'header.mat' ],'file'))&(DeleteExistingGfolder~=0)
    eval(['delete ' new_Gfolder '*.*'])     % Here to delete any files that already
                                            % exist in the new_Gfolder directory
end
 if exist([ new_Gfolder 'header.mat' ],'file')
    eval(['load ' new_Gfolder 'header.mat -mat'])   % A header file already exists, so we
                                                    % are actually adding
                                                    % to an existing glimpse file
    existing_nframes=vid.nframes;           % number of frames in existing file
    existing_tb=vid.ttb;                    % time base of existing file
 else
     existing_nframes=0;                % No existing frames in the new glimpse directory
     existing_tb=[];                    % Time base empty in the new glimpse directory
 end
for indx=1:lnew
                % Cycle through reading images from Gfolder, then writing
                % them out to new_Gfolder
                                % glimpse_image(folder,gheader,image_number)
    iminput=double(glimpse_image(Gfolder,vid_old,FrameVector(indx)));  % Fetch an image from the existing Gfolder
    out_glimpse('LJF',iminput,new_Gfolder);     % Write the fetched image to the new file
end
eval(['load ' new_Gfolder 'header.mat -mat'])   % Loads vid file for sequence just written 
vid.ttb=[existing_tb vid_new.ttb];        % Append time base to the time base existing before present frames were added
vid.nframes=existing_nframes+lnew;           % Add the value of nframes for the new frames to the nframes 
                                             % for the images present before the present frames were added
eval(['save ' new_Gfolder 'header.mat vid'])        % save the header file
pc=1;


