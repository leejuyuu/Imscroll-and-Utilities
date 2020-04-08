function tests = testDriftList
tests = functiontests(localfunctions);
end

function testConstructDriftlistLimited(testCase)
loaded = load('imscroll/test/test_data/L2_driftparam.dat', '-mat');
driftParam = loaded.param;
loaded = load('imscroll/test/test_data/L2_driftlist.dat', '-mat');
correct_driftlist = loaded.driftlist;
drifts_time = construct_driftlist_time_v1(...
    {driftParam.xy_cell},...
    driftParam(1).vid,...
    driftParam(1).CorrectionRange,...
    driftParam(1).SequenceLength,...
    [2 11 2 11]);
drifts = driftlist_time_interp(drifts_time.cumdriftlist,driftParam(1).vid);
driftlist = drifts.diffdriftlist;

verifyEqual(testCase, drifts.diffdriftlist, correct_driftlist);
verifyEqual(testCase, driftlist, correct_driftlist);

end

function testShiftAOIs(testCase)
driftlist = ones(10, 3);
driftlist(1, 2:3) = 0;
driftlist(:, 1) = 1:10;

% Test normal case: AOIs are defined in the first frame
aoiinfo = [1, 1, 0, 0, 5, 1];
for i = 1:10
xy = ShiftAOI(1, i, aoiinfo, driftlist);
verifyEqual(testCase, xy, [i-1, i-1]);
end

% Test if AOIs are defined in the middle of the sequence
aoiinfo = [5, 1, 0, 0, 5, 1];
for i = 1:10
xy = ShiftAOI(1, i, aoiinfo, driftlist);
verifyEqual(testCase, xy, [i-5, i-5]);
end

% Test if changing frame average affect the result
aoiinfo = [5, 5, 0, 0, 5, 1];
for i = 1:10
xy = ShiftAOI(1, i, aoiinfo, driftlist);
verifyEqual(testCase, xy, [i-5, i-5]);
end

% Test for defined AOI is outside the driftlist frame range
aoiinfo = [11, 5, 0, 0, 5, 1];
for i = 1:10
xy = ShiftAOI(1, i, aoiinfo, driftlist);
% The function output NaN, NaN for anything outside range
verifyEqual(testCase, xy, [NaN, NaN]);
end

% Test for the frame we want to shift to is outside the driftlist frame
% range
aoiinfo = [5, 5, 0, 0, 5, 1];
xy = ShiftAOI(1, 11, aoiinfo, driftlist);
% The function output NaN, NaN for anything outside range
verifyEqual(testCase, xy, [NaN, NaN]);

% Test for driftlist does not start from frame 1
driftlist(:, 1) = 2:11;
aoiinfo = [5, 5, 0, 0, 5, 1];
for i = 1:11
    xy = ShiftAOI(1, i, aoiinfo, driftlist);
    if i == 1
        % The function output NaN, NaN for anything outside range
        verifyEqual(testCase, xy, [NaN, NaN]);
    else
        verifyEqual(testCase, xy, [i-5, i-5]);
    end
end
end
