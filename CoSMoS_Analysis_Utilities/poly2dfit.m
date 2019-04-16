function pc=poly2dfit(indata,varargin)
%
% function poly2dfit(indata,inputarg0)
%
% Will fit the 'indata' (2D matrix) to a 2D quadratic function.
%
% indata     == input 2D matrix (e.g. image intensity) that will be fit to a 2D quadratic 
% inputarg0  == optional starting parameters for the fit
%                 [amp centerx centery omega offset] 
%
% The form of the exponential will be:
%  a*X + b*X^2 + c*Y + d*Y^2 + e*X*Y + f
%
% 
%                                               
inlength=length(varargin);
                                                % Grab the starting
                                                % parameters if they are
                                                % present
if inlength>0
    inputarg0=varargin{1}(:);                   %amp=varargin{1}(1);
                                                %centerx=varargin{1}(2);
                                                %centery=varargin{1}(3);
                                                %omega=varargin{1}(4);
                                                %offset=varargin{1}(5);
end
[mrow ncol]=size(indata);                       % Form the xdata input array
xdata=zeros(mrow,ncol,2);
                                                % xdata(:,:,2) will run in
                                                % the Y dimension,
                                                % xdata(:,:,1) in the X
                                                % dimension
xdata(:,:,2)=diag( [0:mrow-1])*ones(mrow,ncol);
xdata(:,:,1)=ones(mrow,ncol)*diag( [0:ncol-1]);
options=optimset('Display','off');              % suppress the screen printing 
                                                %during the lsqcurvefit()
                                                %call
                                             
%pc =lsqcurvefit('gauss2dfunc',inputarg0,xdata,indata,-10000*ones(1,5),100000*ones(1,5),options);
                            % Constrain fit parameters  
                            %                      [lower bounds],           [upper bounds]  
%pc =lsqcurvefit('poly2dfunc',inputarg0,xdata,indata,[0 0 0 0 0],[100000 inputarg0(2)*2 inputarg0(3)*2 10000 100000],options);
pc =lsqcurvefit('poly2dfunc',inputarg0,xdata,indata,[-1000 -1000 -1000 -1000 -1000 0],[1000 1000 1000 1000 1000 100000],options);
