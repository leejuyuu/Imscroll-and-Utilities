%% file for playing around

fileID = fopen('D:\TYL\Google Drive\Research\2019Boston Visit\march_28_2019\larryfj00885\0.glimpse',...
    'r','b')

file = fread(fileID,[1024,540],'int16=>int16');
fclose(fileID)