function shiftedXY = batchShitfAOI(XY,startFrame,frameRange,driftList)
% shiftedXY = batchShitfAOI(XY,startFrame,frameRange,driftList)
% 
% Shifts XY coordinates at startFrame to every frame in frameRange vector,
% generates a 3D matrix that is (nAOIs,2,nFrames) size.

% **This currently only works for aoifits is equal or before frame range.


nFrames = length(frameRange);
shiftedXY = zeros([size(XY),nFrames]);
cumsumDrift = cumsum(driftList(startFrame+1:frameRange(end),[2 3]));
difference = frameRange - startFrame;
for iFrame = 1:nFrames
    if difference(iFrame) == 0
        shiftedXY(:,:,iFrame) = XY;
    else
        for i = 1:2
            shiftedXY(:,i,iFrame) = XY(:,i) +...
                cumsumDrift(difference(iFrame),i);
        end
    end
end
end
