function setGlimpseInfoCurrentFrame(CurrentFrameNumber,handles)
% setGlimpseInfoCurrentFrame(CurrentFrameNumber,handles)
% setting the current frame laser indicators and the current frame filter wheel status to show in imscroll gui 

% Set the laser indicators
if isfield(handles.gheader,'lasers');
    LaserIndicator=handles.gheader.lasers(CurrentFrameNumber,:);     % 0/1 binary indicator
    % 1 x 5 [blue green orange red IR]
    % Check if from new scope, in which case the vid.laser_names
    % order is different (only 4 lasers)
    if length(LaserIndicator)==4
        % Here is from new scope
        LaserIndicator=[LaserIndicator(1:2) 0 LaserIndicator(3:4)];
    end
else
    LaserIndicator = [0 0 0 0 0];          % For old glimpse files lacking the 'lasers' field
end
% Need to check
if LaserIndicator(1,1)==1
    set(handles.BlueLaser,'BackgroundColor',[0 0 1]);
else
    set(handles.BlueLaser,'BackgroundColor',[1 1 1]);
end
if LaserIndicator(1,2)==1
    set(handles.GreenLaser,'BackgroundColor',[0 1 0]);
else
    set(handles.GreenLaser,'BackgroundColor',[1 1 1]);
end
if LaserIndicator(1,3)==1
    set(handles.OrangeLaser,'BackgroundColor',[1 .6 .2]);
else
    set(handles.OrangeLaser,'BackgroundColor',[1 1 1]);
end
if LaserIndicator(1,4)==1
    set(handles.RedLaser,'BackgroundColor',[1 0 0]);
else
    set(handles.RedLaser,'BackgroundColor',[1 1 1]);
end
if LaserIndicator(1,5)==1
    set(handles.IRLaser,'BackgroundColor',[.8 .2 0]);
else
    set(handles.IRLaser,'BackgroundColor',[1 1 1]);
end
% Set the filter indicator
if isfield(handles.gheader,'filters');
    FilterIndicator=handles.gheader.filters(CurrentFrameNumber);     % Values 0-9
    %
    
else
    FilterIndicator = 1;          % For old glimpse files lacking the 'filters' field, just say 'Closed'
end

% Now write the filter text into the handles.Filter text region
% Note the +1 b/c values run 0-9 but indices run 1-10
set(handles.Filter,'String',handles.FilterListCell{FilterIndicator+1})
end