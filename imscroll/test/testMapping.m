function tests = testMapping
tests = functiontests(localfunctions);
end

function testMakeMappingFile(testCase)
loaded = load('imscroll/test/test_data/20200206_br_02_field1.dat', '-mat');
field1 = loaded.aoiinfo2;
loaded = load('imscroll/test/test_data/20200206_br_02_field2.dat', '-mat');
field2 = loaded.aoiinfo2;
loaded = load('imscroll/test/test_data/20200206_br_02_bug_fixed.dat', '-mat');
map = MakeMappingFile(field1, field2, 'fitparm_test.dat');
verifyEqual(testCase, map.fitparmvector, loaded.fitparmvector);
verifyEqual(testCase, map.mappingpoints, loaded.mappingpoints);
end