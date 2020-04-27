function pk = pickSpots(image, spotPickingParam, region)

    noiseDiameter = spotPickingParam.noiseDiameter;
    spotDiameter  = spotPickingParam.spotDiameter;
    spotBrightness = spotPickingParam.spotBightness;
    [xlow,xhigh,ylow,yhigh] = region{:};
    dat=bpass(double(image(ylow:yhigh,xlow:xhigh)),noiseDiameter,spotDiameter);
    pk=pkfnd(dat,spotBrightness,spotDiameter);
    pk=cntrd(dat,pk,spotDiameter+2);        % This is our list of spots in this frame FrameRange(frmindx)
    
    [nAOIs,~]=size(pk);
    
    if nAOIs~=0       % If there are spots
        pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
        pk(:,2)=pk(:,2)+ylow-1;
        
    end
end

