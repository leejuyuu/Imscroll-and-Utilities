function pc=build_alex_aoi_images(Path2Images,aoinums,Path2Mu)
%
% function build_alex_aoi_images(Path2Images,aoinums,Path2Mu)
%
% This will build and save a stacked tiff file containing all the aoi
% gallery images.  The output will be suitable for viewing within imscroll
% to help visualize what the gui_spot_model program is actually fitting.
%
% Path2Images == path to the directory containing all the image galleries.
%             The directory is called 'AoiImages'.  
%          Just use [fn1 fp]= uigetfile to navigate to one file in the
%          directory and use Path2Images = fp1
% aoinums == vector of integer values that specify the aoi numbers
%             e.g. =[1:122]  when aoifits = b26p110b.dat
% Path2Mu == path to the directory containing the Mu image.
%             The directory is called 'MuImages'.  
%          Just use [fn2 fp]= uigetfile to navigate to one file in the
%          directory and use Path2Mu = fp2

 eval(['imdum=imread([ Path2Images num2str(aoinums(1)) ''.png''], ''png'');']);    % Loads the first aoi image file
 imwrite(imdum,[ Path2Images 'aoiimages.tif'],'tiff','Compression','none')      % Write the first image
for indx=2:length(aoinums)
    if indx/10==round(indx/10)
        indx
    end
                            % Successively read the rest of the images
    eval(['imdum=imread([ Path2Images num2str(aoinums(indx)) ''.png''], ''png'');']);
                            % And add them to the tiff file
    imwrite(imdum,[ Path2Images 'aoiimages.tif'],'tiff','Compression','none','WriteMode','append');
end
    % Also make a mu image with a few repeats of the mu image in a stacked tiff 
mu=imread([Path2Mu 'mus.png'],'png');
imwrite(mu,[ Path2Mu 'mutiff.tif'],'tiff','Compression','none')
imwrite(mu,[ Path2Mu 'mutiff.tif'],'tiff','Compression','none','WriteMode','append');
imwrite(mu,[ Path2Mu 'mutiff.tif'],'tiff','Compression','none','WriteMode','append');
imwrite(mu,[ Path2Mu 'mutiff.tif'],'tiff','Compression','none','WriteMode','append');
imwrite(mu,[ Path2Mu 'mutiff.tif'],'tiff','Compression','none','WriteMode','append');
imwrite(mu,[ Path2Mu 'mutiff.tif'],'tiff','Compression','none','WriteMode','append');
    pc=1;
