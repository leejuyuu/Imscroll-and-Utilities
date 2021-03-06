function pc=bkgndsub(aoifits,bkgndaois)
%
%    function pc=bkgndsub(aoifits,bkgndaois)
%
% This is stripped out of the PlotBottom.m routine for plotting in
% the PlotArgOut gui.  It will subtract off the average backgound aoi from
% the aoi of interest.  The user inputs the aoifits structure (output
% stored by our plotargout gui) and the aoinum specifying which aoi is used
% as the data.  The bkgndaois vector lists those aoi numbers that will be
% used as backgound aois for the aoi of interest.
%
% aoifits == structure that is output from the imscroll>>plotargout gui
%         For purposes here, we need only know that
%         aoifits.data=[aoi# frame# amplitude x0  y0 sigma offset (int.intensity)]
% bkgnd == e.g. [2 4 5 7 ] a vector list of aois in the aoifits structure that will be used 
%       to compute an average background aoi that we can subtract off from
%       the  data aoi specified by 'aoinum'
% 
% Output will be [frm# (ave. bkgnd integrated aoi]

        aoilist=bkgndaois;            % Vector listing the backgound AOIs
        argouts=aoifits.data;         % Just the data member of the structure, containing all the aois
                                      %[aoi# frame# amplitude x0  y0 sigma offset (int.intensity)]
        [datrows datcols]=size(argouts);
        logaoi=logical([]);
                                    %We need a matrix with an ave bkgnd int. aoi for
                                    % each frm number
                                                % Pick out all rows of the
                                                % argouts matrix containing
                                                % background aoi info.
                                                % This will contain info.
                                                % from all the frames
        for indxx=1:datrows
                            % compare aoi for each row of argouts with the list of aois used for background subtraction  
            logaoi=[logaoi;any(aoilist==argouts(indxx,1))];
        end
                                                % Next average all the
                                                % integrated aoi data for a
                                                % given framenumber
                                                
        subargouts=argouts(logaoi,:);           % Contains argouts rows with info. on background aois
                                                % Frame # limits
        frmmin=min(subargouts(:,2));frmmax=max(subargouts(:,2));
        bkgndintaoi=[];
                                                % Average the background
                                                % int. aoi for each
                                                % framenumber
        for frmindx=frmmin:frmmax   
                                                % Logical array picking all
                                                % rows with present frame
                                                % number
            logfrm=(frmindx==subargouts(:,2));
                                                % Now average the (int. aoi)
                                                % for the background aois
                                                % with the present frm #
            bkgndintaoi=[bkgndintaoi;frmindx sum(subargouts(logfrm,8))/length(aoilist)];
        end
                            % Now subtract ave background from (int aoi)
        pc=bkgndintaoi;
