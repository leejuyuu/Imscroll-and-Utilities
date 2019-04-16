function pc=expfall_twoexp_lsq_error(xdata,ydata,startparam)
%
% function expfalltwo_amp_k_lsq_error(xdata,ydata,startparam)
%
% Uses the lsqcurvefit() routine to fit our cy3-holoenzyme open complex departure from
% dsDNA templates to a falling exponential.  It returns the fit parameter tau
% along with the 95% confidence interval for the fit parameter
%
% fit a falling exponential function of the from:
%
%  fitparm(1)* exp(-xdata*fitparm(2))+fitparm(3)* exp(-xdata*fitparm(4)) 
%
%
% xdata == will be the values for time at which the observation are made.
%         The ydata will be the fraction of cy3-holoenzyme still bound to a
%         DNA template at the time of observation 
% ydata == will be the fraction of cy3-holoenzyme still bound to a DNA
%         template at the time of the observation.  eg. B17p81 plot or 
%          B17p79 data list 
% startparam== vector of starting values for the fit parameters in our
%          function.  startparam(1) will be the starting value for
%          fitparam(1) and so on.
%           fitparm(1) = tau
%           fitparm(2) = offset
%
% Output will be [fitparm(1) (confidence interval for fitparam(1))
%                  fitparm(2) (confidence interval for fitparm(2) ]
%                                     .
%                                     .
%                 fitparam(N) (confidence interval for fitparam(N)]
%  Usage:  
% args = expfall_twoexp_lsq_error(xdata,ydata,[1  1/5  2  1/100])

options=optimset('lsqcurvefit');
options=optimset(options,'display','off');
%%%%%%%%%%%%%%%%%
%[rosex colx]=size(xdata);         % Turn xdata and ydata into row vectors
%[rosey coly]=size(ydata);
%if coly==1
%    ydata=ydata';
%end
%if colx==1
%    xdatamat=[xdata';ydata];
%else
%    xdatamat=[xdata;ydata];
%end
%ydatamat=[ydata;ydata];
                        % Should have xdatamat being a 2xn matrix with the
                        % ydata as the second row
                        % ydatamat is also a 2xn matrix with both rows
                        % containing the original ydata vector

%oligobind_func=inline(['(' num2str(Nm) '/( 1-exp(-' num2str(tm) '/tau) ) )*(1-exp(-bindtime/tau)  )'],'tau','bindtime');
 
[fitparamout resnorm residual exitflag output lambda jacobian]=...
        lsqcurvefit('expfall_twoexp_lsq_function',startparam,xdata,ydata,[],[],options);
fiterror=nlparci(fitparamout,residual,jacobian);
%fiterror=reshape(fiterror',2,3)';
%fiterror=reshape(fiterror',2,2)';

pc=[fitparamout' fiterror];


