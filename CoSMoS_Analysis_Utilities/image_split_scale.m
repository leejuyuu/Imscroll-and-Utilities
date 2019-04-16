function pc=image_split_scale(inputimage,boundaries,xory,minmax12)
%
% function image_split_scale(inputimage,boundaries,xory,minmax12)
%
% This will take an input image, divide it into two sections and seperately
% scale each section to a grayscale 0-255 range.  The output image will
% be 0-255 across the entire FOV, but the two sections will have been
% mapped onto that 0-255 scale using different minimum and maximum
% intensities.  This will allow the user to display (or make an avi) in
% which the two halves of the FOV are displayed using different scales.
%
% inputimage == 2D image of e.g. the dual field microscope FOV
% boundaries == [x1 x2 y1 y2 xorysplit]  where x1 x2 y1 y2 define the
%         boundary of the entire image, and xorysplit defines the dividing
%         x or y boundary between the two image sections (choice of x or y
%         is specified by 'xory' variable.
% xory == 'x' or 'y' will specify whether the image is split by specifying
%         an x coordinate (vertical line) or a y coordinate (horizontal
%         line)
% minmax12 == [mn1 mx1 mn2 mx2]   defines the minimum and maximum display
%         intensities in fields one and two [ minimum1 maximum1 minimum2 maximum2]
x1=boundaries(1);x2=boundaries(2);y1=boundaries(3);y2=boundaries(4);xorysplit=boundaries(5);
mn1=minmax12(1);mx1=minmax12(2);mn2=minmax12(3);mx2=minmax12(4);
                         % Define entire region for display
%fullframe=inputimage(y1:y2,x1:x2);
fullframe=inputimage(:,:); % Use full image: limit the field instead when displaying it
[rose col]=size(fullframe);
intmap=inline('255/(mx-mn)*x-255*mn/(mx-mn)','x','mn','mx');
if xory=='x'
                            % Here for vertical dividing line in FOV
%    frame1=fullframe(:,1:xorysplit-x1);   % include dividing line in frame2
%    frame2=fullframe(:,(xorysplit-x1+1):x2);
    frame1=fullframe(:,1:xorysplit);   % include dividing line in frame2
    frame2=fullframe(:,(xorysplit+1):col);
else
                            % Here for horizontal dividing line in FOV
%    frame1=fullframe(1:xorysplit-y1,:);
%    frame2=fullframe(xorysplit-y1+1:y2,:);  % include dividing line in frame2
    frame1=fullframe(1:xorysplit,:);
    frame2=fullframe(xorysplit+1:rose,:);  % include dividing line in frame2
end
                    % scale frame1 to min and max
frame1=intmap(frame1,mn1,mx1);
frame2=intmap(frame2,mn2,mx2);
                    % take care of pixels above 255 and below 0
logic=frame1>255;
frame1(logic)=255;
logic=frame1<0;
frame1(logic)=0;
                    % scale frame2 to min and max
logic=frame2>255;
frame2(logic)=255;
logic=frame2<0;
frame2(logic)=0;
                    % Now reassemble the frame
if xory=='x'
    pc=[frame1 frame2];
else
    pc=[frame1
        frame2];
end

