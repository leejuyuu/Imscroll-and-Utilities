function timeBaseArray = importTimeBase(imagePath)
[dir,name,~] = fileparts(imagePath);
timedata = importdata([dir,'\', name, '.txt']);
timeBaseArray = cumsum(timedata(2,:))*1000;
end