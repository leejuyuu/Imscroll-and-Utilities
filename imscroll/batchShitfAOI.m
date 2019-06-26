function shiftedXY = batchShitfAOI(aoiinfo,frameRange,driftList)
% shiftedXY = batchShitfAOI(aoiinfo,frameRange,driftList)
% This currently only works for aoifits is equal or before frame range.
XY = aoiinfo(:,[3,4]);
aoiinfoFrame = aoiinfo(1,1);
nAOIs = length(aoiinfo(:,1));
nFrames = length(frameRange);
shiftedXY = zeros(nAOIs,2,nFrames);
cumsumDrift = cumsum(driftList(aoiinfoFrame+1:frameRange(end),[2 3]));

for iFrame = frameRange-aoiinfoFrame
    if iFrame == 0
        shiftedXY(:,:,iFrame+1) = XY;
    else
        for i = 1:2
            shiftedXY(:,i,iFrame+1) = XY(:,i) + cumsumDrift(iFrame,i);
        end
    end
end
end
