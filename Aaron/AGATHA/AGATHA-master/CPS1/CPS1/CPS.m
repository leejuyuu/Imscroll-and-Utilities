function varargout = CPS(varargin)
%2017  Fatemehsadat Jamalidinan  created
% CPS MATLAB code for CPS.fig
%      CPS, by itself, creates a new CPS or raises the existing
%      singleton*.
%
%      H = CPS returns the handle to a new CPS or the handle to
%      the existing singleton*.
%
%      CPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CPS.M with the given input arguments.
%
%      CPS('Property','Value',...) creates a new CPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CPS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CPS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CPS

% Last Modified by GUIDE v2.5 30-Nov-2017 10:01:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CPS_OpeningFcn, ...
                   'gui_OutputFcn',  @CPS_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CPS is made visible.
function CPS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CPS (see VARARGIN)
imshow('bg_header.png')
set(handles.Inputdir,'String','Input Directory');
set(handles.outputdir,'String','Output Directory');
% Choose default command line output for CPS
handles.output = hObject;
global filenames fp fp_baseout filenameArray  plotSteps meth value maxnum_trace outpu;
maxnum_trace=-10;
outpu=0;
% Update handles structure
guidata(hObject, handles);
plotSteps = true;

% UIWAIT makes CPS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CPS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Inputdir_Callback(hObject, eventdata, handles)
% hObject    handle to Inputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Inputdir as text
%        str2double(get(hObject,'String')) returns contents of Inputdir as a double


% --- Executes during object creation, after setting all properties.
function Inputdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outputdir_Callback(hObject, eventdata, handles)
% hObject    handle to outputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputdir as text
%        str2double(get(hObject,'String')) returns contents of outputdir as a double


% --- Executes during object creation, after setting all properties.
function outputdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in In_dir.
function In_dir_Callback(hObject, eventdata, handles)
installPottslab

global filenames fp fp_baseout filenameArray ;
global filenames fp fp_baseout filenameArray  plotSteps meth value maxnum_trace;
% hObject    handle to In_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenames, fp]=uigetfile('*.dat', 'Select the imscroll .dat files to analyze', 'Multiselect', 'on');
% fp_baseout = uigetdir(fp, 'Select a folder to write images and step counts to:');
set(handles.outputdir,'String',''); 

%If only one file selected, MATLAB returns character vector.
%If more than one, MATLAB returns cell array of character vectors...
%Need to put it into a cell array for the downstream analysis.
set(handles.Inputdir,'String',fp);
if iscell(filenames)
    filenameArray = filenames;
    set(handles.Single_trace, 'enable', 'off')
    set(handles.Multiple_Traces, 'enable', 'off')
    set(handles.Numberoftraces, 'enable', 'off')
    set(handles.Enter_trace, 'enable', 'off')
     set(handles.indexbet, 'enable', 'off')
    set(handles.text6, 'enable', 'off')
    maxnum_trace=-5;
elseif ~iscell(filenames)
    filenameArray = cell(1);
    filenameArray{1} = filenames;
    set(handles.Single_trace, 'enable', 'on')
    set(handles.Multiple_Traces, 'enable', 'on')
    if get(handles.All_traces,'value')
        set(handles.Numberoftraces, 'enable', 'off')
        set(handles.Enter_trace, 'enable', 'off')
        set(handles.indexbet, 'enable', 'off')
        set(handles.text6, 'enable', 'off')
    else
        set(handles.Numberoftraces, 'enable', 'on')
        set(handles.Enter_trace, 'enable', 'on')
        set(handles.indexbet, 'enable', 'on')
        set(handles.text6, 'enable', 'on')
    end
    
       fn = filenameArray{1};
        folder=[fp fn];
        eval(['load ' [fp fn] ' -mat']);
        [filepath, filename, ext] = fileparts(fn); 
        data = sortrows(aoifits.data, 1);
        [numRows, numCol] = size(data);
        maxVals = max(data);
        minVals = min(data);
        numFrames = maxVals(2)-minVals(2)+1;
        numTraces = maxVals(1);
        haha=0;
        set(handles.text6,'String',num2str(numTraces));
        maxnum_trace=numTraces;
end

% --- Executes on button press in out_dir.
function out_dir_Callback(hObject, eventdata, handles)
% hObject    handle to out_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filenames fp fp_baseout filenameArray outpu;
 fp_baseout = uigetdir(fp, 'Select a folder to write images and step counts to:');
   set(handles.outputdir,'String',fp_baseout); 
  outpu=1;


function Numberoftraces_Callback(hObject, eventdata, handles)
% hObject    handle to Numberoftraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Numberoftraces as text
%        str2double(get(hObject,'String')) returns contents of Numberoftraces as a double


% --- Executes during object creation, after setting all properties.
function Numberoftraces_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Numberoftraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in analize.
function analize_Callback(hObject, eventdata, handles)
% hObject    handle to analize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filenames fp fp_baseout filenameArray  plotSteps meth value maxnum_trace outpu;

if(maxnum_trace==-10)
     msgbox('Select the .dat file(s) you wish to analyze');
     return
end

if (outpu==0)
    msgbox('Select the output directory');
    return
end

if get(handles.Single_trace,'value')
    meth=1;
    value=str2num(get(handles.Numberoftraces,'String'));
    if(length(value)<1)
        msgbox('Enter index');
        return
    end
    if(length(value)>1)
         msgbox('Enter only one index');
    return
    end
    max_value=max(value);
     if( max_value>maxnum_trace)
        msgbox(['The index(s) should be between 1 and '  num2str(maxnum_trace)]);
    return
    end
    min_value=min(value);
    if( min_value<1)
       msgbox(['The index(s) should be between 1 and '  num2str(maxnum_trace)]);
    return
    end
end

if get(handles.Multiple_Traces,'value')
    meth=2;
    value=str2num(get(handles.Numberoftraces,'string'));
    if(length(value)<1)
        msgbox('Enter index');
        return
    end
     max_value=max(value);
     if( max_value>maxnum_trace)
        msgbox(['The index(s) should be between 1 and '  num2str(maxnum_trace)]);
    return
    end
    min_value=min(value);
    if( min_value<1)
       msgbox(['The index(s) should be between 1 and '  num2str(maxnum_trace)]);
    return
    end
end

if get(handles.All_traces,'value')
    meth=3;
end
sens=str2num(get(handles.sensitivity,'string'));
thr=str2num(get(handles.threshold,'string'));
 plotSteps = true;
 for k=1:length(filenameArray)
        fn = filenameArray{k};
        folder=[fp fn];
        eval(['load ' [fp fn] ' -mat']);
        [filepath, filename, ext] = fileparts(fn); 
        data = sortrows(aoifits.data, 1);
        [numRows, numCol] = size(data);
        maxVals = max(data);
        minVals = min(data);
        numFrames = maxVals(2)-minVals(2)+1;
        numTraces = maxVals(1);

        traces = [];

        for i = 0:numFrames:numRows-numFrames
            traces = [traces, data(i+1:i+numFrames, 8)];
        end



        rawTrace = [];      %Matrix that contains the raw data for each trace
        residual = [];      %Matrix that contains the residual for each step fit
        traceIds = [];
        x = [];
        y = [];
        numAllSteps = [];
        numBigSteps = [];
        numPhotobleaches = [];
        stepSizes = []; %The size of each detected step


        %Make a subdirectory based on the name of the input file
        fpout = strcat(fp_baseout, '/', filename);
        if ~exist(fpout,'dir');
            status = mkdir(fpout);
            if (status == 0)
                disp('ERROR: DID NOT MAKE OUTPUT DIRECTORY!');
                return;
            end
        end
       
        

if meth==3
   tt=1:numTraces;
end
if meth==2
   tt=value;
end
if meth==1
   tt=value;
end


        %Begin analyzing the data
        for jj=1:length(tt) 
            i=tt(jj);
            
            X = traces(:,i);
            X_norm = (X - min(X) ) / ( max(X) - min(X) );
            %[Y] = tdetector(X,2);

            %Use the normalized version of X for step detection--seems to work
            %better
            
            if isempty(sens)
                sensitivity =0.6;
                % set(handles.threshold,'string',num2str(threshold));
            else
                
                sensitivity =sens;
            end
             Y_norm =  minL1Potts(X_norm, sensitivity);

            %De-normalize Y for the downstream analysis
            Y = Y_norm * (max(X) - min(X)) +min(X);


            [numSteps, stepIndices, stepSizes] = identifySteps(Y);
            %Filter declared step indices for artifacts:
                %Dead frames at beginning of trace
                    %First step has to go down
                    %Ignore up steps at beginning
                %Blinking events
                    %Cancel out "down-up" pairs of steps
                %Small Steps
                    %Remove steps smaller than 2sd of avg noise in trace

            traceResidual = Y-X;    %Compute difference between step function and data
            traceRMS = sqrt( sum(traceResidual.^2)/numFrames);
            %disp(traceRMS);


            bigStepIndices = [];    %Indices of steps larger than noise
            stepDirs = [];    %1 for up, -1 for down
            bleachIndices = [];    %Indices corresponding to "true" step decreases
            
            if isempty(thr)
                threshold = traceRMS;
                % set(handles.threshold,'string',num2str(threshold));
            else
                
                threshold = thr;
                
            end
           
            %Let's filter out the small steps first
            for j = 1:length(stepIndices)
                isSmall = filterSmallSteps(stepSizes(j,1), threshold);
                if isSmall == 0
                    %disp('STEP IS LARGER THAN NOISE!');
                    bigStepIndices = [bigStepIndices; stepIndices(j,1)];
                end
            end
            
            
	    %disp('# Big steps: '); disp(length(bigStepIndices));
            %Next, determine the direction of each step (up or down)
            for j = 1:length(bigStepIndices)

                if (stepSizes(j,1) <= 0)    % Step down
                    stepDir = -1;
                elseif (stepSizes(j,1) > 0) % Step up
                    stepDir = 1;
                end
                stepDirs = [stepDirs, stepDir];
            end

            %Check if downward steps are blinks (paired with an up step)
            for j = 1:length(stepDirs)
                if (stepDirs(1, j) == -1)
                    if (findUnpairedSteps(stepDirs, j))
                        bleachIndices = [bleachIndices, bigStepIndices(j,1)];
                    end
                end
            end

            %Add step counts to the table
            traceId = cellstr(strcat(fn, '_', int2str(i)));
            traceIds = [traceIds; traceId];  
            x = [x; aoifits.centers(i,1)];
            y = [y; aoifits.centers(i,2)];
            numAllSteps = [numAllSteps; numSteps];    
            numBigSteps = [numBigSteps; length(bigStepIndices)];
            numPhotobleaches = [numPhotobleaches; length(bleachIndices)];

            %Trace plotting
            
            tracePlot = figure('visible','off');
            set(gcf, 'PaperPositionMode', 'auto')
            set(tracePlot, 'Position', [0 0 800 400]);      %Make smallish images
            plot(X, 'b', 'DisplayName', 'Raw Trace'); hold on
         
            xlabel('Frame');
            ylabel('Fluorescense Intensity');
             
         F_X{k,i}=X;
          F_Y{k,i}=Y;

            if (plotSteps == true) 
                %Plot the estimated step function
                stairs(Y,'g', 'DisplayName', 'Estimated Step Function');

                % Hilight the true photobleaching steps with asterisks
                topval = max(X)*1.1;
                top = zeros(length(bleachIndices),1);
                top(:,1) = topval;	%This is where we'll put the asterisks

                %disp('top:');
                %disp(top);
                %disp('bleachIndices');
                %disp(bleachIndices);
                plot(bleachIndices, top, 'p', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'Photobleach');
            end
              F_bleachIndices{k,i}=bleachIndices;
              F_top{k,i}=top;
            legend('show');
            %legend('Location','southwest');

            % Print out labeled graph to file and print out step indices
            filename_raw = strcat(fpout, '/', filename, '_', sprintf('%03d', i), '.ps');
            print(tracePlot,filename_raw, '-dpsc')
            hold off
            close(tracePlot);
        %   disp('declared step indexes:'); disp(bigStepIndices);
        %   disp('declared photobleaching indices:'); disp(bleachIndices);    


set(handles.text7,'String',num2str(i));

        end

    %Print out the data:
        %TraceID    x    y   TotSteps    BigSteps    numPhotobleaches
        
        outTable = table(traceIds, x, y, numAllSteps, numBigSteps, numPhotobleaches);
        F_outTable{k}=outTable;
        outputFile = strcat(fpout, '/', fn, '_steps.tsv');
        writetable(outTable, outputFile, 'Delimiter', '\t', 'WriteRowNames', true, 'FileType', 'text');

        sizeTable = table(stepSizes);
        F_sizeTable{k}=sizeTable;
        outputSizeTable = strcat(fpout, '/', fn, '_stepSizes.tsv');
        writetable(sizeTable, outputSizeTable, 'Delimiter', '\t', 'WriteRowNames', true, 'FileType', 'text');


 end
%     save('bleachIndices.mat','F_bleachIndices');
%     save('top.mat','F_top');
%     save('Y.mat','F_Y');
%     save('X.mat','F_X');
%     save('sizeTable.mat','F_sizeTable');
%     save('outTable.mat','F_outTable');


% Hint: get(hObject,'Value') returns toggle state of analize


% --- Executes on button press in Single_trace.
function Single_trace_Callback(hObject, eventdata, handles)
% hObject    handle to Single_trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filenames fp fp_baseout filenameArray  plotSteps meth;
meth=1;
set(handles.Numberoftraces, 'enable', 'on')
set(handles.Enter_trace, 'enable', 'on')
set(handles.indexbet, 'enable', 'on')
    set(handles.text6, 'enable', 'on')

% Hint: get(hObject,'Value') returns toggle state of Single_trace


% --- Executes on button press in Multiple_Traces.
function Multiple_Traces_Callback(hObject, eventdata, handles)
% hObject    handle to Multiple_Traces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filenames fp fp_baseout filenameArray  plotSteps meth;
meth=2;
set(handles.Numberoftraces, 'enable', 'on')
set(handles.Enter_trace, 'enable', 'on')
set(handles.indexbet, 'enable', 'on')
    set(handles.text6, 'enable', 'on')
% Hint: get(hObject,'Value') returns toggle state of Multiple_Traces


% --- Executes on button press in All_traces.
function All_traces_Callback(hObject, eventdata, handles)
% hObject    handle to All_traces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filenames fp fp_baseout filenameArray  plotSteps meth;
meth=3;
set(handles.Numberoftraces, 'enable', 'off')
set(handles.Enter_trace, 'enable', 'off')
set(handles.indexbet, 'enable', 'off')
    set(handles.text6, 'enable', 'off')
% Hint: get(hObject,'Value') returns toggle state of All_traces


% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function sensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensitivity as text
%        str2double(get(hObject,'String')) returns contents of sensitivity as a double


% --- Executes during object creation, after setting all properties.
function sensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in usermanual.
function usermanual_Callback(hObject, eventdata, handles)
% hObject    handle to usermanual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    winopen('CPS.pdf')
catch
system('open CPS.pdf')
end
