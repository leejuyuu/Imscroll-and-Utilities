function pc=expfall_twoexp_lsq_function(fitparm,xdata)
%
%function expfall_twoexp_lsq_function(fitparm,xdata)
%
% This is the function paired with the above fitting routine 
% 'expfall_twoexp_lsq_error.  Invoking the
% expfall_twoexp_lsq_error() function will return the fitted parameters together
% wtih the intervals for 95% confidence
%
% fitparm == vector of fit parameters for this function.  The routine varies
%         these values for best agreement between the xdata and ydata.
%
% xdata   == xdatamat, a 2 x n matrix with the first row being the actual xdata
%         and the second row being the actual ydata
%         xdata will be the values for time at which the observation are made.
%         The ydata will be the number of cy3-holoenzyme still bound to a
%         DNA template at the time of observation e.g. B17p81 plot or
%         B17p79 data list.
%

% Fit is to the function
%     pc=fitparm(1)*exp(-xdata*fitparm(2))+fitparm(3)*exp(-xdata*fitparm(4));;
%    2/20/08  Will be fitting data from B17p104c.fig

fitparm=abs(fitparm);       % Only use positive values of the fit parameters
pc=fitparm(1)*exp(-xdata*fitparm(2))+fitparm(3)*exp(-xdata*fitparm(4));
                       
