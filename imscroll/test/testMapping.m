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
close all
end

function testMapAOIs(testCase)
loaded = load('imscroll/test/test_data/map_handles.mat', '-mat');
handles = loaded.handles;
loaded = load('imscroll/test/test_data/L2_map.dat', '-mat');
correct_aoiinfo = loaded.aoiinfo2;
mapAOIsOut(handles);

loaded = load('imscroll/test/test_data/postmapAOIs.dat', '-mat');
new_aoiinfo = loaded.aoiinfo2;
verifyEqual(testCase, new_aoiinfo, correct_aoiinfo);
close all
end

function testInvMapAOIs(testCase)
loaded = load('imscroll/test/test_data/map_handles.mat', '-mat');
handles = loaded.handles;
loaded = load('imscroll/test/test_data/L2_inv_map.dat', '-mat');
correct_aoiinfo = loaded.aoiinfo2;
invMapAOIsOut(handles);

loaded = load('imscroll/test/test_data/postmapAOIs.dat', '-mat');
new_aoiinfo = loaded.aoiinfo2;
verifyEqual(testCase, new_aoiinfo, correct_aoiinfo);
close all
end

function testProxMapAOIs(testCase)
loaded = load('imscroll/test/test_data/prox_map_handles.mat', '-mat');
handles = loaded.handles;
loaded = load('imscroll/test/test_data/L2_prox_map.dat', '-mat');
correct_aoiinfo = loaded.aoiinfo2;
mapAOIsOut(handles);

loaded = load('imscroll/test/test_data/postmapAOIs.dat', '-mat');
new_aoiinfo = loaded.aoiinfo2;
verifyEqual(testCase, new_aoiinfo, correct_aoiinfo);
close all
end

function testInvProxMapAOIs(testCase)
loaded = load('imscroll/test/test_data/prox_map_handles.mat', '-mat');
handles = loaded.handles;
loaded = load('imscroll/test/test_data/L2_prox_inv_map.dat', '-mat');
correct_aoiinfo = loaded.aoiinfo2;
invMapAOIsOut(handles);

loaded = load('imscroll/test/test_data/postmapAOIs.dat', '-mat');
new_aoiinfo = loaded.aoiinfo2;
verifyEqual(testCase, new_aoiinfo, correct_aoiinfo);
close all
end