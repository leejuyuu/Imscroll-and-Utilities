function imageOut = testMPHD(image)
for i = 1:10
%     Rawimage(:,:,i) = imread('D:\TYL\PriA_project\Expt_data\20190624\L1_mapping\01.tif',i);
end
% image = mean(Rawimage,3);
% figure(1);
% imshow(image,[500,1500]);
% kneral size 11x11, sigma = 0.5
LoG_filter = fspecial('log', [10, 10],0.5);
filteredIm = imfilter(image,LoG_filter,'replicate');
filteredIm  = imgaussfilt(filteredIm,0.5);
% filteredIm=bpass(double(image),0.5,5);
% figure(2);
% imshow(filteredIm,[0 200]);
regionalMax = imregionalmax(filteredIm);
cc = bwconncomp(regionalMax);

nRmax = cc.NumObjects;
R = 10;
% Create ringed mask
rings = false(2*R+1,2*R+1,R);
[centerY,centerX] = ind2sub(size(rings(:,:,1)),(1+(2*R+1)^2)/2);
center = [centerY,centerX];
for r = 1:R
    for x = 1:(2*R+1)
        for y = 1:(2*R+1)
            if rings(y,x)
                continue
            end
            pixelDistance = sqrt(sum(([y,x]-center).^2));
            rings(y,x,r) = pixelDistance > r-1 && pixelDistance <= r;
        end
        
    end
end
nanIm = NaN(size(filteredIm)+2*R);
nanIm(R+1:end-R,R+1:end-R) = filteredIm;
maskIm = zeros(size(filteredIm));
% figure
for iRmax = 1:nRmax
    [regionY,regionX] = ind2sub(size(filteredIm),cc.PixelIdxList{iRmax});
    %{
    subimage = nanIm(regionY-R+R:regionY+R+R,regionX-R+R:regionX+R+R);
    ringMax = zeros(1,R);
    for r = 1:R
        ringMax(r) = max(subimage(rings(:,:,r)));
    end
    %}
%     plot(1:R,ringMax)

ringMax = nan(1,R^2);
candidateXY =zeros(8,2);
q = 0;

for r = 1:R
    for k = 0:floor(r/2)
        q = q + 1;
        candidateXY(1,:) = [k,r-k];
        candidateXY(2,:) = [r-k,k];
        candidateXY([3,4],:) = candidateXY([1,2],:);
        candidateXY([3,4],2) = -candidateXY([3,4],2);
        candidateXY([5:8],:) = candidateXY([1:4],:);
        candidateXY([5:8],1) = -candidateXY([5:8],1);
        values = nanIm(regionY + candidateXY(:,2)+R,regionX+candidateXY(:,1)+R);
        ringMax(q) = max(values(:));
    end
end
        
    Ip = min(ringMax);
    maskIm(cc.PixelIdxList{iRmax}) =  Ip;
    %{
    thresholdedIm = filteredIm > Ip;
    cc2 = bwconncomp(thresholdedIm);
    for i = 1:cc2.NumObjects
        logik = cc2.PixelIdxList{i}  == cc.PixelIdxList{iRmax};
        if any(logik)
            maskIm(cc2.PixelIdxList{i}) = Ip;
            break
        end
        
    end
    iRmax
    % [gradientIm,~] = imgradient(filteredIm);
    % imwrite(uint16(filteredIm),'test0710.tif');
    %}
end
Jout = imreconstruct(maskIm,filteredIm);
% figure(3)
% imshow(Jout,[0,1000])
J2 = filteredIm - Jout;
figure(5)
imshow(J2,[0,100])
bb = J2>10;
bb2 = bwareaopen(bb,2);
J3 = bb2.*J2;
% figure(6)
% imshow(J3,[60,200])
kk = J3 >= 80;
bb2 = bwareaopen(kk,2);
J4 = J3.*kk;
J5 = J4 - imreconstruct(J4-1,J4);
% figure(7)
% imshow(J5,[0,1]);
logik = J5<1 & J5>0;
sum(logik(:))
imageOut = J4;
end




