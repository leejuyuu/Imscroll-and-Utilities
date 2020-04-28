function tests = testPickSpots
    tests = functiontests(localfunctions);
end

function testPickSpots1(testCase)
    
    spotPickingParam = struct(...
        'noiseDiameter',1,...
        'spotDiameter',5,...
        'spotBightness',50 ...
        );
    coords = pickSpots(zeros(256), spotPickingParam, {1,256,1,256});
    verifyEqual(testCase, coords, [])
end

function testPickSpots2(testCase)
    
    spotPickingParam = struct(...
        'noiseDiameter',1,...
        'spotDiameter',5,...
        'spotBightness',50 ...
        );
    testImage = zeros(250);
    gaussKernel = fspecial('gaussian', 5, 1.2);
    for i = 1:50
        for j = 1:50
            testImage((i-1)*5+1:i*5, (j-1)*5+1:j*5) = 80 * (i + j) * gaussKernel;
        end
    end
    
    coords = pickSpots(testImage, spotPickingParam, {1,250,1,250});
    coordsTrue = load('imscroll/test/test_data/testPickSpots2.mat').coords;
    verifyEqual(testCase, coords, coordsTrue)
end