% show license
% disp('----------')
% lic = importdata('License.txt');
% for i = 1:numel(lic)
%     disp(lic{i});
% end
% disp('----------')

%%sets all necessary paths
% set path
disp('Setting Matlab path...');
folder = fileparts(which(mfilename));
addpath(...
    fullfile(folder, ''),...
    fullfile(folder, 'Auxiliary'),...
    fullfile(folder, 'Auxiliary/Operators'),...
    fullfile(folder, 'Data'),...
    fullfile(folder, 'Demos'),...
    fullfile(folder, 'Demos', '1D'),...
    fullfile(folder, 'Demos', '2D'),...
    fullfile(folder, 'Java', 'bin', 'pottslab'),...
    fullfile(folder, 'Potts'),...
    fullfile(folder, 'Potts', 'PottsCore'),...
    fullfile(folder, 'Potts2D'),...
    fullfile(folder, 'Potts2D', 'Core'),...
    fullfile(folder, 'Sparsity'),...
    fullfile(folder, 'Sparsity', 'SparsityCore'),...
    fullfile(folder, 'Tikhonov')...
);

% set java path
disp('Setting Java path...');
setPLJavaPath(true);

% save pathdef
savepath;
