function tests = testGaussFitting
tests = functiontests(localfunctions);
end

function testFirst(testCase)
load('imscroll/test/test_data/gui_state.mat')
FitAOIs_Callback_outer(hObject, eventdata, handles)
new_ans = load('imscroll/test/test_data/default.dat', '-mat');
right_ans = load('imscroll/test/test_data/L2_driftfit_20f_track_avg1.dat', '-mat');
verifyEqual(testCase, new_ans.aoifits.data, right_ans.aoifits.data)
close all
end

function testFitAoisTo2dGaussian(testCase)
% This only tests for tracking is on
loaded = load('imscroll/test/test_data/L2_gauss_test_param.mat');
aoiProcessParameters = struct(...
    'frameAverage', 1,...
    'frameRange', 1:20 ...
);
isTrackAOI = true;

data = fitAoisTo2dGaussian(...
        loaded.aoiinfo,...
        aoiProcessParameters,...
        loaded.imageFileProperty,...
        isTrackAOI...
        );
right_ans = load('imscroll/test/test_data/L2_driftfit_20f_track_avg1.dat', '-mat');
verifyEqual(testCase, data, right_ans.aoifits.data)

end