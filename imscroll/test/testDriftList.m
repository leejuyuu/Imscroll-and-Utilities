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
    [8 8],...
    [2 11 2 11]);
drifts = driftlist_time_interp(drifts_time.cumdriftlist,driftParam(1).vid);
driftlist = drifts.diffdriftlist;

verifyEqual(testCase, driftlist, correct_driftlist);

end