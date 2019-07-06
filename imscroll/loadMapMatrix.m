function mapMatrix = loadMapMatrix(mapDir,mapFileName)
A = load([mapDir,mapFileName,'.dat'],'-mat');
mapMatrix = A.fitparmvector;
end
