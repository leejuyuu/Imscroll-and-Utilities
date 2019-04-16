% Portion of a larger function for Johnson
if aoinumber+1>=3               % Map the two fields if we have 2 or more points
                                %  x2= mx21*x1 + bx21
                                %  y2= my21*y1 + by21
                                % first polyfit(x1,x2)=[slope intercept] as
                                % first guess
    fitparmx21=polyfit(handles.MappingPoints(:,3),handles.MappingPoints(:,9),1);
                                % Form a cell array, first member is a matrix of the
                                % x1y1 pairs
    inarray{1}=[ handles.MappingPoints(:,3) handles.MappingPoints(:,4)];
                                % second member is a vector of the output
                                % x2 points
    inarray{2} = handles.MappingPoints(:,9);
                                % Input guess is [mxx21 mxy21 bx] with
                                % mxy21 = 0 at first
    fitparmx21more=mappingfit(inarray,[fitparmx21(1) 0 fitparmx21(2) ]);
    rangex=[min(handles.MappingPoints(:,3) ): max(handles.MappingPoints(:,3) )];
                                % Get the linear fit result
    valx=polyval(fitparmx21,rangex);
                                % Get the more complex fit result
    valxmore=mappingfunc(fitparmx21more,inarray{1});
                                % Plot the x data and fit
    figure(20);subplot(121);plot(handles.MappingPoints(:,3),handles.MappingPoints(:,9),'o',...
                          rangex,valx,'r-', handles.MappingPoints(:,3),valxmore,'x')
    xlabel('X1 Coordinate');ylabel('X2 Coordinate');title(['X Mapping:' num2str(fitparmx21more')])
                                % then polyfit(y1,y2)
    fitparmy21=polyfit(handles.MappingPoints(:,4),handles.MappingPoints(:,10),1);
                                % Form a cell array, first member is a
                                % matrix of the x1y1 pairs
      inarray{1}=[ handles.MappingPoints(:,3) handles.MappingPoints(:,4)];
                                % second member is a vector of the output
                                % y2 points
    inarray{2} = handles.MappingPoints(:,10);
                                % Input guess is [myx21 myy21 bx] with
                                % myx21 = 0 at first
       fitparmy21more=mappingfit(inarray,[0 fitparmx21(1) fitparmx21(2) ]);
     rangey=[min(handles.MappingPoints(:,4) ): max(handles.MappingPoints(:,4) )];
                                % Get the linear fit result
    valy=polyval(fitparmy21,rangey);
                                % Get the more complex fit result
    valymore=mappingfunc(fitparmy21more,inarray{1});
                                % Plot the y data and fit
    figure(20);subplot(122);plot(handles.MappingPoints(:,4),handles.MappingPoints(:,10),'o',...
                          rangey,valy,'-',handles.MappingPoints(:,4),valymore,'x')
        xlabel('Y1 Coordinate');ylabel('Y2 Coordinate');title(['Y Mapping:' num2str(fitparmy21more')])
  
        handles.FitParameters=[fitparmx21more;fitparmy21more];          % Store the fit parameters in the handles structure
        guidata(hObject,handles);                               % [mx21 bx21; my21 by21]
        parenthandles=guidata(handles.parenthandles_fig);       % Get handle structure from top imscroll gui
                                                                 % Place fitparm into 'Value' of FitDisplay 
                                                                 % as a two row matrix
                                                               
        fitparmvector=[fitparmx21more';fitparmy21more'];
        set(parenthandles.FitDisplay,'UserData',fitparmvector)
        set(parenthandles.FitDisplay,'String',[ num2str(fitparmx21more') '  ' num2str(fitparmy21more')]);
                                                                 % display as row [mxx21 mxy21 bx21 myx21 myy21 by21]' 
        mappingpoints=handles.MappingPoints;
        save p:\matlab12\larry\fig-files\imscroll\mapping\fitparms.dat fitparmvector mappingpoints 
end

