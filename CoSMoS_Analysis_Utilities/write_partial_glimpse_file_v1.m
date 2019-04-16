function pc=write_partial_glimpse_file_v1(Gfolder, new_Gfolder, FrameVector, DeleteExistingGfolder)
%
%  function write_partial_glimpse_file_v1(Gfolder, new_Gfolder, FrameVector, DeleteExistingGfolder)
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
% V1 added additional fields to the output vid variable so it will work
% properly with the updated version 32 of Glimpse when joining sequences

% LJF 8/1/2015: Originally written for Grace to enable equalizing analysis of sequences
% recorded with different duty cycles (for bleaching effects).

% Copyright 2018 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

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

vid_new.description=vid.description;    % All these members will be used in the file we will write
vid_new.camera=vid.camera;
vid_new.microscope=vid.microscope;
vid_new.mversion=vid.mversion;
vid_new.laser_names=vid.laser_names;
vid_new.filter_names=vid.filter_names;

vid_new.lasers=vid.lasers(FrameVector,:);
vid_new.filters=vid.filters(1,FrameVector);
vid_new.flowrate=vid.flowrate(1,FrameVector);
vid_new.temp=vid.temp;
vid_new.field=vid.field(1,FrameVector);     
vid_new.header2=vid.header2;
vid_new.stagexyz=vid.stagexyz(FrameVector,:);
       
   


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
    existing_lasers=vid.lasers;
    existing_filters=vid.filters;
    existing_flowrate=vid.flowrate;
    existing_field=vid.field;
    existing_stagexyz=vid.stagexyz;
    
 else
    existing_nframes=0;                % No existing frames in the new glimpse directory
    existing_tb=[];                    % Time base empty in the new glimpse directory
    existing_lasers=[];
    existing_filters=[];
    existing_flowrate=[];
    existing_field=[];
    existing_stagexyz=[];
 end
for indx=1:lnew
    if indx/20==round(indx/20)
        indx
    end
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
                                             
                                             
vid.description=vid_new.description;        % All the vid_new members were defined above from the input Gfolder files
vid.camera=vid_new.camera;
vid.microscope=vid_new.microscope;
vid.mversion=vid_new.mversion;
vid.laser_names=vid_new.laser_names;
vid.filter_names=vid_new.filter_names;

vid.lasers=[existing_lasers; vid_new.lasers];
vid.filters=[existing_filters vid_new.filters];
vid.flowrate=[existing_flowrate vid_new.flowrate];
vid.temp=vid_new.temp;
vid.field=[existing_field vid_new.field];     
vid.header2=vid_new.header2;
vid.stagexyz=[existing_stagexyz; vid_new.stagexyz];

eval(['save ' new_Gfolder 'header.mat vid'])        % save the header file
pc=1;



 
