function tests = testGaussFitting
tests = functiontests(localfunctions);
end

function testFirst(testCase)
load('imscroll/test/test_data/gui_state.mat')
FitAOIs_Callback_outer(hObject, eventdata, handles)
new_ans = load('imscroll/test/test_data/default.dat', '-mat')
right_ans = load('imscroll/test/test_data/L2_driftfit_20f_track_avg1.dat', '-mat')
verifyEqual(testCase, new_ans.aoifits.data, right_ans.aoifits.data)
close all
end
