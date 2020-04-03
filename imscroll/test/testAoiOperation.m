function tests = testAoiOperation
tests = functiontests(localfunctions);
end

function testRemoveCloseAOIs(testCase)
% Case 1: x spacing
aoiinfo = ones(7, 6);
aoiinfo(:, 3) = [1, 3, 4, 6, 8, 9, 11]' * 4;
new_aoiinfo = removeCloseAOIs(aoiinfo, 5);
% verifyEqual(testCase, new_aoiinfo, aoiinfo([1, 4, 7], :))
a = aoiinfo([1, 4, 7], :);
a(:, 6) = 1:3;
verifyEqual(testCase, new_aoiinfo, a);


% Case 2: y spacing
aoiinfo = ones(7, 6);
aoiinfo(:, 4) = [1, 3, 4, 6, 8, 9, 11]' * 4;
new_aoiinfo = removeCloseAOIs(aoiinfo, 5);
% verifyEqual(testCase, new_aoiinfo, aoiinfo([1, 4, 7], :))
a = aoiinfo([1, 4, 7], :);
a(:, 6) = 1:3;
verifyEqual(testCase, new_aoiinfo, a);

% Case 3: Boundary
aoiinfo = ones(4, 6);
aoiinfo(:, 3) = [1, 3, 4, 8]' * 5;
new_aoiinfo = removeCloseAOIs(aoiinfo, 5);
a = aoiinfo([1, 4], :);
a(:, 6) = 1:2;
verifyEqual(testCase, new_aoiinfo, a);

% Case 4: Not on axis
aoiinfo = ones(7, 6);
aoiinfo(:, 3) = [1, 3, 4, 6, 8, 9, 11]' * 4 * cos(pi/3);
aoiinfo(:, 4) = [1, 3, 4, 6, 8, 9, 11]' * 4 * sin(pi/3);
new_aoiinfo = removeCloseAOIs(aoiinfo, 5);
% verifyEqual(testCase, new_aoiinfo, aoiinfo([1, 4, 7], :))
a = aoiinfo([1, 4, 7], :);
a(:, 6) = 1:3;
verifyEqual(testCase, new_aoiinfo, a);


% Case 5: aggregates
aoiinfo = ones(7, 6);
aoiinfo(:, 3) = [1, 1, 2, 6, 11, 13, 15]' ;
aoiinfo(:, 4) = [1, 2, 1, 6, 11, 13, 14]' ;
new_aoiinfo = removeCloseAOIs(aoiinfo, 5);
% verifyEqual(testCase, new_aoiinfo, aoiinfo([1, 4, 7], :))
a = aoiinfo(4, :);
verifyEqual(testCase, new_aoiinfo, a);


end
