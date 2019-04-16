function pc=gel_excel2tif(gelCell, rotationNum, flipUD, OutputDataFile, OutputTiffFile)
%
% function gel_excel2tif(gelCell, rotationNum, flipUD, OutputDataFile, OutputTiffFile)
%
% After saving a *.gel file on the Typhoon into an excel file (*.xls) we
% use the import wizard to bring the data into Matlab.  This function combines 
% the different sheets from the excel file into a single matrax, the saves
% that matrix image as a tiff file suitable for inmport into the imscroll
% gui.
%
% gelCell == 1D Cell array containing the different sheets from the excel file.
%       Each sheet comes into Matlab as a separate matrix, and the user
%       places each sheet into one of the cells of this cell array.  For
%       example, we import B32p90c.xls via the wizard resulting in the two
%       data sheets named scan90c1 and scan90c2.  We then set
%       e.g.  gelCell{1}=scan90c1;
%             gelCell{2}=scan90c2;
%
% rotationNum == number of times to rotate the image by 90;
%
% flipUD == 1 to flip image up/down, otherwise no flip 
%
% OutputDataFile == full path/.../name for the file stored that will
%       contain the variable e.g. scan90cu_rot  where (using above example)
% scan90c_all=[scan90c1 scan90c2];      % Combine sheets from excel file
% scan90cu=uint16(scan90c_all);         % Change to unsigned integer
% scan64eu_rot= (rot90(65536-scan64eu));    % reverse black/white and rotate
%
% OutputTiffFile == full path/.../ name for the output tiff file containing
%           the image of the scanned gel

Cellnum=length(gelCell);       % Obtain number of cells in array (# of data sheets in excel file)
scanall=[];

for indx=1:Cellnum
    scanall=[scanall gelCell{indx}];  % Combine all the data sheets into one image
end
scanallu=uint16(scanall);               % Change to unsigned integer
%scanallu_rot= ((65536-scanallu));  % reverse black/white 
scanallu_rot=scanallu;
                    % Now rotate multiple times
for indx=1:rotationNum
    scanallu_rot=rot90(scanallu_rot);
end
if flipUD==1
   scanallu_rot=flipud(scanallu_rot);  % flip up/down  
end

eval(['save ' OutputDataFile ' scanallu']);     % save the data into a file

		% Now write the images into stacked matrices, and output as tiffs
		
[rose col]=size(scanallu_rot);
inmat=uint16(zeros(rose,col,5));
for indx=1:5
inmat(:,:,indx)=scanallu_rot;
end

		% Write the tiff file
tiff_write(OutputTiffFile,inmat)
pc=scanallu_rot;



% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.