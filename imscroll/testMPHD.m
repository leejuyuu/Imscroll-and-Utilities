function testMPHD
for i = 1:10
    Rawimage(:,:,i) = imread('D:\TYL\PriA_project\Expt_data\20190624\L1_mapping\01.tif',i);
end
image = mean(Rawimage,3);
figure(1);
imshow(image,[500,1500]);
% kneral size 11x11, sigma = 0.5
LoG_filter = fspecial('log', [10, 10],0.5);
filteredIm = imfilter(image,LoG_filter,'replicate');
% filteredIm  = imgaussfilt(image,1);
% filteredIm=bpass(double(image),0.5,5);
figure(2);
imshow(filteredIm,[0 200]);
regionalMax = imregionalmax(filteredIm);
cc = bwconncomp(regionalMax);
maskIm = filteredIm;
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
    subimage = nanIm(regionY-R+R:regionY+R+R,regionX-R+R:regionX+R+R);
    ringMax = zeros(1,R);
    for r = 1:R
        ringMax(r) = max(subimage(rings(:,:,r)));
    end
%     plot(1:R,ringMax)
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
figure(3)
imshow(Jout,[0,1000])
J2 = filteredIm - Jout;
figure(4)
imshow(J2,[0,100])
end




