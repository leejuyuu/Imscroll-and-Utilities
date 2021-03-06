function pc=construct_driftpoints(xy_cell,CorrectionRange,SequenceLength,Polyorderxy)
%
% function    construct_driftpoints(xy_cell,CorrectionRange,SequenceLength,Polyorderxy)
%
% xy_cell==cell array of structures containing the information gleaned from
%         gaussian tracking multiple spots for the purpose of drift correction.
%        e.g.  xy_cell{1}.dat
%              xy_cell{1}.range
%              xy_cell{1}.userange    where
% xy_cell{1}.dat ==one dat matrix containing the x 
%         y coordinates of one spot tracked with a gaussian fit in imscroll.
%         Each cell array is of the form
%         obtained by processing an aoifits structure with the
%         dat=draw_aoifits_aois(aoifits,'y') function.  Therefore,
%         dat(:,4,1) contains the x coordinate and dat(:,5,1) the y
%         coordinate
% xy_cell{1}.range==[ low high] frame range that the dat matrix covers.  
%         For example we might have xy_cell{1}.range=[100 500] though the
%         image sequence might be [1 2305] i.e. the dat matrx will
%         generally cover a continuous subset of all the imagee, and the data
%         will generally not be useable throughout this range.  the
%         '.range' member lists only the range over which the spot was
%         tracked for this entry, not the range over which the tracked spot
%         contains usefull data (specified in the next entry)
% xy_cell{1}.userange==[low high] useable frame range over which
%         each dat_cell entry x-y coordinates may be used for drift
%         correction.  e.g. xy_cell{1}=[150 450] where the
%         xy_cell{1}.range=[100 500] is a possibility.
% CorrectionRange==[lowc hic] low and high frame number between which we 
%         performing a drift correction in the file.  Generally, the drift
%         correction occurs over just a subset of the frames in the file
% SequenceLength == e.g. 3606 the total number of images in the glimpse
%         image file for which we will construct a driftlist
% PolyOrderxy == [n m] where n and m are integers specifying the polynomial
%         order of fit respectively applied to the x (n) and y (m) drift curves 
% OUTPUT will be a 
% driftlist(SequenceLength,3)=[(frame#) (x difference) (y difference)]
% See B21p53:  This version 'construct_driftpoints' will output the actual
% xy tracked points rather than a polynomial fit to the points (the
% function 'construct_driftlist' will instead output a polynomial fit to smooth the
% noise)

%  alternatively:
% dat_cell == cell array of dat matrices.  Each dat matrix contains the x 
%         y coordinates of one spot tracked with a gaussian fit in imscroll.
%         Each cell array is of the form
%         obtained by processing an aoifits structure with the
%         dat=draw_aoifits_aois(aoifits,'y') function.  For example
%         we might have dat_cell{1}=dat(:,:,2), dat_cell{2}=dat(:,:,5) etc
%         where the different dat() matrices could originate from different
%         aoifits structures.
% datrange_cell== cell array listing the frame range overwhich each
%         dat_cell entry covers.  For example we might have 
%         datrange_cell{1}=[50 300] for the dat_cell{1} input,
%         datrange_cell{2}=[100 600] for the dat_cell{2} input, etc
% userange_cell== cell array listing the useable frame range over which
%         each dat_cell entry x-y coordinates may be used for drift correction.
%         e.g. datrange_cell{1}=[100 250], datrange_cell{2}=[150 575], etc
% dat_cell, datrange_cell and userange_cell should all have the same number
% of matching entries.
%
%
%  form the various variables as xcell, ycell, dxcell, dycell, dx, dy,
%  cumx,cumy, fitx, valx fity, valy, ddx, ddy, driftlist
%
[rosecell aoinum]=size(xy_cell);
                        % Replace SequenceLength by SequenceLength+20, then
                        % shorten it again at end of program so that we do
                        % not have to treat special cases such as when the
                        % use range of an aoi runs to the end of the file.
                        % This way, we never have xy_cell{}.userange running
                        % to the very end of a file, and all expressions
                        % can be treated the same.
ActualSequenceLength=SequenceLength;
SequenceLength=SequenceLength+20;

           % aoinum is the number of aois tracked for correcting drift
           % rosecell should be equal to 1
           
                       % First form the x1 and y1 coordinate lists for the
                       % various aois
                       % These will run from frame 1 out to
                       % frame=SequenceLength, filling in zeros where there
                       % is no coordinate tracked for that aoi
x1=cell(1,aoinum);
y1=cell(1,aoinum);
dx1=cell(1,aoinum);
dy1=cell(1,aoinum);
for x1y1indx=1:aoinum
    lolimit=xy_cell{x1y1indx}.range(1);
    hilimit=xy_cell{x1y1indx}.range(2);
   % if hilimit==SequenceLength
                        % just in case tracking went to very end of file,
                        % shorten it by one so some of the upcoming
                        % expressions don't fail
                 % NO:  fixed by replacing SequenceLength by
                 % SequenceLength+20, then shortening it at the end
     %   hilimit=hilimit-1;
    %end
                        % dat=[(frm#)  ()  () (xcoor) (ycoord) ...]
    dat=xy_cell{x1y1indx}.dat;
    if lolimit==1
                        % Here if low frame limit of xy coordinates =1
                        %
                        % x1{}=[(frame#) (x coord of spot}], y1{}= ""
                        % fill in zeros as coord if spot not tracked for
                        % some frames
        x1{x1y1indx}=[dat(:,2) dat(:,4); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),1)];
        y1{x1y1indx}=[dat(:,2) dat(:,5); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),1)];
    else
        x1{x1y1indx}=[[1:lolimit-1]' zeros(lolimit-1,1); dat(:,2) dat(:,4); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),1)];
        y1{x1y1indx}=[[1:lolimit-1]' zeros(lolimit-1,1); dat(:,2) dat(:,5); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),1)];
    end
                        % And form the deltax and deltay lists
    dx1{x1y1indx}=[0; diff(x1{x1y1indx}(:,2))];
    dy1{x1y1indx}=[0; diff(y1{x1y1indx}(:,2))];
end
                        % Now we must zero out the dx1 and dy1 entries that
                        % are at unuseable frame numbers
for dxyzindx=1:aoinum
    lowuserange=xy_cell{dxyzindx}.userange(1);
    hiuserange=xy_cell{dxyzindx}.userange(2);
    if ( lowuserange~=1 )
        dx1{dxyzindx}(1:lowuserange)=0;
        dx1{dxyzindx}(hiuserange+1:SequenceLength)=0;
        dy1{dxyzindx}(1:lowuserange)=0;
        dy1{dxyzindx}(hiuserange+1:SequenceLength)=0;
    else
            % Here if lowuserange==1 (we then DO NOT need to zero out dx1 and dy1
            % for frames 1 up to lowuserane)
        dx1{dxyzindx}(hiuserange+1:SequenceLength)=0;
        dy1{dxyzindx}(hiuserange+1:SequenceLength)=0;
    end
end
            % initialize numerator and denominator of dx, dy
dxnum=zeros(SequenceLength,1);
dynum=zeros(SequenceLength,1);
dxdenom=zeros(SequenceLength,1);
dydenom=zeros(SequenceLength,1);
            % dx and dy entries from frame M represent the difference in 
            % spot coordinates between the frame M-1 and M

for dxyindx=1:aoinum
    dxnum=dxnum+dx1{dxyindx};
    dynum=dynum+dy1{dxyindx};
                        % Each entry in denominator will equal the number
                        % of nonzero elements in the dx or dy cell arrays
                        % so that we average only over those regions with
                        % multiple tracked aois (if only one element exists
                        % the denominator will be 1, and if no elements
                        % exit we should be at a frame number in a range we
                        % are not correcting drift)
    dxdenom=dxdenom+(dx1{dxyindx}~=0);
    dydenom=dydenom+(dy1{dxyindx}~=0);
end
dx=dxnum.*dxdenom.^(-1);
dy=dynum.*dydenom.^(-1);
                        % At various places we divided by zero, resulting
                        % in NaN.  We now zero out those entries
logikx=isnan(dx);
dx(logikx)=0;
logiky=isnan(dy);
dy(logiky)=0;
                        % Sum the frame differences to a cumulative track
                        % of the exemplary x and y coordinate drifting in
                        % the file
cumx=cumsum(dx);
cumy=cumsum(dy);

                        % Fit the cumulative traces to polynomials
crange=[CorrectionRange(1):CorrectionRange(2)];

%**fitx=polyfit(crange',cumx(crange),Polyorderxy(1));
%**valx=polyval(fitx,crange);
%**fity=polyfit(crange',cumy(crange),Polyorderxy(2));
%**valy=polyval(fity,crange);
                        % Plot the concatenated xy coord and fits
%**figure(27);plot(crange,cumx(crange),'b',crange,valx,'r');
        figure(27);plot(crange,cumx(crange),'b');

gtext(['xdrift, polyfit order:' num2str(Polyorderxy(1))])
xlabel('Frame Number');ylabel('x pixel')
%**figure(28);plot(crange,cumy(crange),'b',crange,valy,'r');
        figure(28);plot(crange,cumy(crange),'b');

gtext(['ydrift, polyfit order:' num2str(Polyorderxy(2))])
xlabel('Frame Number');ylabel('y pixel')
                        % Construct the driftlist from the polynomial fits
%**ddx=diff(valx);
%**ddy=diff(valy);
%**drange=[CorrectionRange(1)+1:CorrectionRange(2)];
driftlist=zeros(SequenceLength,3);
driftlist(:,1)=[[1:SequenceLength]'];
%driftlist(drange,2)=ddx;
        driftlist(:,2)=dx;
%driftlist(drange,3)=ddy;
        driftlist(:,3)=dy;
                        % Output the driftlist
                        %
                        % Now truncate the driftlist to match the actual
                        % length of the image sequence file (see note at
                        % top of program)
driftlist=driftlist(1:ActualSequenceLength,:);
pc=driftlist;


