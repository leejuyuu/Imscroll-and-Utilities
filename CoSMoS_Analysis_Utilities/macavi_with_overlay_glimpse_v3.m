function pc=macavi_with_overlay_glimpse_v3(gfolder,frames,dispscale,flagg,frmrate,avifolder,frmave,info,varargin)
%
% function macavi_with_overlay_glimpse_v3(gfolder,frames,dispscale,flagg,frmrate,avifolder,frmave,info,<frmlim>)
%
% This function will return a movie after reading in images from one of 
% JC and LF files of  iccd data.  The user can take the output and play 
% it as a movie (e.g. movie(pc) ).  Uses image sequences saved in GLIMPSE
% format.
%
% gfolder == the alphanumeric for the path to the frames.  EX
%          imfold  ='D:\temp\larry\april_14_07\b16p106a_534\'
% frames == vector of images to be put into avi file
% loindx == the low number for the index of the file.  For example, if
%        the user wants a movie containing files 5 through 45 the user
%        will set loindx=5 and hiindx = 45
% hiindx == the high number for the index of the file
% dispscale == [min max] sets the scale for the image display
% flagg == logical variable.  If flagg ==1 then use images in the global
%           variable movframes(mrange,nrange,frmindx)
% frmrate== output frame rate for the avi (in frames per second)
% avifolder == folder in which avi will be placed
% After the movie (e.g. 'mov')is made, the user can make an avi file using:
%  movie2avi(mov,folder,'fps',30,'quality',100,'compression','none');
% frmave = the number of frames to average.  This will be a running ave
%        (careful not to exceed number of frames: hiindx only to maxfrm#-frmave)
% info == 'aoifits' structure made in the gui 'imscroll'. The 'info'
%        structure contains a list of aois selected within the 'imscroll'
%        gui, and boxes will be drawn around those aois in the avi that is
%        made
% frmlim == (optional) [y1 y2 x1 x2] in order to only access the portion of
%           the frame given by frm(y1:y2,x1:x2)
%global movframes dum
mkavi='yes';
if length(varargin)>0                       % grab frame size, if it exists
    frmlim=varargin{1};
    
end
                                            % load the vid structure in the
                                            % header.mat file
eval(['load ' [gfolder 'header.mat'] ' -mat'])
dum =glimpse_image(gfolder,vid,1);           % just to get the proper frame size
[a b]=size(dum);
dum=uint32(zeros(a,b,frmave));                      % space to read in groups of frames that will be averaged
movieindx=1;
colormap(gray(256));
 fig=figure(10);                              % open figure:   'DoubleBuffer'used in avi example in 'Help' 
   set(fig,'DoubleBuffer','on');
%for inum = loindx : hiindx					% read in images to be averaged
for inum=frames
%      figure(1);surf(double(imread([imfold filenum],'tiff'))-50,...
%         'Edgecolor','none');camlight left;lighting phong;view([-25 80]);axis([0 100 0 100 0 25])

%      figure(1);surf(double(imread([imfold filenum],'tiff'))-50,'Facecolor','red',...
%         'Edgecolor','none');camlight left;lighting phong;view([-25 80]);axis([0 100 0 100 0 25])
%      figure(1);pcolor(double(imread([imfold tiff_name(inum)],'tiff'))-50 );caxis([5 35]);colorbar;shading flat
%    figure(1);image(imread([imfold tiff_name(inum)],'tiff') );colormap(gray(256));figure(1)
        if flagg==1
%        dum=movframes(:,:,inum);
        dum_display=imdivide(sum(movframes(:,:,inum:inum+frmave-1),3) ,frmave);      
        else
  
%        dum=imread([imfold tiff_name(inum)],'tiff') ;
        %dum=readstacked(imfold,inum:inum+frmave-1);
                                                % Read in one group of
                                                % frames to be averaged
        for rdindx=inum:inum+frmave-1
%        dum(:,:,rdindx-inum+1)=imread(imfold,'tif',rdindx);
        dum(:,:,rdindx-inum+1)=glimpse_image(gfolder,vid,rdindx);
 
        end
                                                % Now average the frames
        
        dum_display=imdivide(sum(dum,3) ,frmave);
        end
   
%    figure(3);imagesc(dum(:,1:300),dispscale);colormap(gray(256));axis('equal');axis('off');set(gcf,'color','white')
dum_display=double(dum_display);
                                                % Now scale the image to be
                                                % between 0 and 255, using
                                                % just the image
                                                % intensities set by
                                                % 'dispscale'
                                                % Following johnson's
                                                % tiff2movie() mfile
    hilim=dispscale(2);lolim=dispscale(1);
                                                % Set all above hilim to
                                                % equal hilim value
   dum_display=dum_display.*(dum_display<=hilim) +hilim*(dum_display>hilim);
                                                % Set all below lolim to
                                                % equal lolim value
   dum_display=dum_display.*(dum_display>=lolim)+lolim*(dum_display<lolim);
                                                % Now map the image to be
                                                % between 1 and 255  DO NOT
                                                % NEED WHEN USING IMAGESC(,[LO HI])
   %dum=(dum-lolim)/(hilim-lolim)*254 +1;
   figure(10);imagesc(rot90(dum_display,0),[lolim hilim]);colormap(gray);axis equal;axis off
   %draw_aoifits_aois_no_numbers(info,[0 .9 0]);  % [0 .9 0] is green 
   %draw_aoifits_aois_no_numbers(info,'r');  % [0 .9 0] is green 
draw_aoifits_aois_no_numbers(info,[.9 0 0]);
   if length(varargin)>0                        % Limit the frame size, if the user included such a limit
    axis([frmlim(3) frmlim(4) frmlim(1) frmlim(2)]); 
       %dum_display=dum_display(frmlim(1):frmlim(2),frmlim(3):frmlim(4));
   end
%  figure(10);imagesc(dum_display,[lolim hilim]);colormap(gray);axis equal;axis off
  %figure(10);imagesc(rot90(dum_display,0),[lolim hilim]);colormap(gray);axis equal;axis off

%  draw_aoifits_aois_no_numbers(info,'r');
%  draw_aoifits_aois_no_numbers(info,'y');

  pc(movieindx)=getframe(gca);                  % add the current figure to the movie
  % pc(movieindx)=im2frame(dum,gray(256));
  
   	movieindx=movieindx+1;
    if movieindx/20==round(movieindx/20)
        movieindx
    end
end                                                % End of for loop

if mkavi =='yes'
    sprintf('making an avi file \n')
   
    movie2avi(pc,avifolder,'fps',frmrate,'quality',100,'compression','none');
end
%caxis('auto')

