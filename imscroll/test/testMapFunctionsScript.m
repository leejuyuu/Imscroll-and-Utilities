function testMapFunctions()
% the mappings should satisfy that the transformed coordinates will be
% transformed back by the inverse map matrix

% the tests show that set threshold to 10^-12 pass the test, but 10^-13
% makethe test fail.
for imap = 1:20
    map = rand(2,3);
    invmap = getInverseMap(map);
    for ixy = 1:20
        xy1 = rand(1,2)*500;
        xy2 = mapXY(xy1,map);
        xy11 = mapXY(xy2,invmap);
        err = abs(xy11-xy1);
        if err > 10^-12
            fprintf('failed for xy = %12f, map = %23f, err = %f\n',xy1,map,err)
            fprintf('err = %f\n',err*10^13)
        end
    end
end
end