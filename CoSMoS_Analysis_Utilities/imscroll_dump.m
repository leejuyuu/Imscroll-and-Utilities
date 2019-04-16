% mfile imscroll_dump.m
%
% The following was removed from the imscroll.m callback for GoButton.
% This was the code under the argnum==9 section for the drift correction
% using a correlation method for the drift.
%
elseif argnum==9
                            % Here for cross correlation drift correction
    gfolder=handles.gfolder;
     dum=varargin{1};                             % Need dum, images, folder  to
    images=varargin{2};                          % pass to the slider1 routine
    folder=varargin{3};
    if get(handles.ImageSource,'Value') ==1         % popup menu 'Tiff_Folder'
        filesource=2;
    else                                % Needed to pass to drifting_v8
        filesource=1;                   % Glimpse folder source
    end
    frms=eval(get(handles.FrameRange,'String'));
    frmrange=[min(frms) max(frms)];
    frmlim=get(handles.MagChoice,'UserData');
    frmlim=[frmlim(2,3:4) frmlim(2,1:2)];       % use #1 magchoice, reverse order b/c y x here rather than x y   
   % averange=round(str2double(get(handles.FrameAve,'String')));
    averange=1;
    fitwidth=15;
    filesource=1;                           % Now perform cross correlation
    %dparam=drifting_v7(gfolder,frmrange,frmlim,averange,fitwidth,filesource);
    dparam=drifting_v8(gfolder,frmrange,frmlim,averange,fitwidth,filesource,folder);
                                        % Initialize the driftlist
    driftlist=[[1:handles.MaxFrames]' zeros(handles.MaxFrames,2)];
                        % Fill in those entries determined here
    driftlist(frmrange(1)+1:frmrange(2),:)=[dparam(:,1) dparam(:,10:11)];
    %keyboard
    handles.DriftList=driftlist;    % Store driftlist in handles structure
    guidata(gcbo,handles);          % Save driftlist for future use 
    %eval(['save ' handles.FileLocations.imscroll '\DriftList.dat driftlist']);
    eval(['save ' handles.FileLocations.imscroll 'DriftList.dat driftlist']);