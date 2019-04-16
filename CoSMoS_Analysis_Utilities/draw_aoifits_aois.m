function pc= draw_aoifits_aois(aoifits,colour)
%
% function draw_aoifits_aois(aoifits,colour)
% This mfile will use the current 'aoifits' structure to draw the boxes
% around the aois in the current figure.  The function returns the
% aoifits.data data array in a stacked matrix, one layer for each aoi
%
% aoifits == the structure of fit data saved by the 'imscroll' program
%             after fitting the aois specified by the user
% colour == the color of the aoi boxes and aoi box labels drawn, e.g. = 'w' 
dat=aoifits.data;
aoinum=max(dat(:,1));        % Gives the number of aois in the data set

[mdat ndat]=size(dat);
aoiinf=[];
datrow=1;
                            % Break data into stacked matrices, one for
                            % each aoi
aoirows=(mdat/aoinum);
pc=zeros(aoirows,ndat,aoinum);
for indx=1:aoinum
                            % Look for first row of data table for this aoi
    flag=0;
    while(flag ==0)
        if dat(datrow,1) == indx
                            % First row for this aoinum, save it in aoiinf
            aoiinf=[aoiinf;dat(datrow,:)];
            flag=1;
          
        else
            datrow=datrow+1;
        end
    end 
                            % Fill in stacked matrix, aoi by aoi
    pc(:,:,indx)=dat( aoirows*(indx-1)+1:aoirows*indx,:);
  
end
        

pixnum=aoifits.parameter(1,2);

for indx=1:aoinum
                    % draw boxes around all the aois
            aoiinf=aoifits.centers;                 %Added after the aoifits.centers member
                                                    % was added. Will replace the aoiinf defined above.
                                                    %aoifits.centers us the actual aoi centers
                                                    %rather than the fit centers.
                             % 4/28/09 change (pixnum-1) to (pixnum-0) in
                             % next line for correct aoi size
             draw_box(aoiinf(indx,1:2),(pixnum-0)/2,...
                             (pixnum-0)/2,colour);
             text(aoiinf(indx,1)+pixnum,aoiinf(indx,2)-pixnum,num2str(indx),'Color',colour)
             
%             draw_box(aoiinf(indx,4:5),(pixnum-1)/2,...
%                             (pixnum-1)/2,colour);
%             text(aoiinf(indx,4)+pixnum,aoiinf(indx,5)-pixnum,num2str(indx),'Color',colour)
             
end
shg;
