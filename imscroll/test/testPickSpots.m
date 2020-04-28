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