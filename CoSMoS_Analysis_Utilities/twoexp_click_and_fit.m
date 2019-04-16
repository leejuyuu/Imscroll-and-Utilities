function pc=twoexp_click_and_fit(xdata,ydata,fignum)
%
% function twoexp_click_and_fit(xdata,ydata,fignum)
%
% User will mouse-click 4 times on a two exponential plot in figure number
% 'fignum', thus providing starting parameters for a two exponential fit.
% The first two mouse-clicks should be on the curve region contained in the
% faster part of the biexp, and the last two clicks should be on the long
% lived single expnential tail.
% The program will output the fit parameters according to:
%
%    arg(1)*exp(-t*arg(2)) + arg(3)*exp(-t*arg(4))
% xdata == time vector of curve to be fit
% ydata == y data vector of curve to be fit
%
% Output:   
% arg(1)  CI_0.95_low  CI_0.95_high
% arg(2)  CI_0.95_low  CI_0.95_high
% arg(3)  CI_0.95_low  CI_0.95_high
% arg(4)  CI_0.95_low  CI_0.95_high
figure(fignum);plot(xdata,ydata,'bo');
[t y]=ginput(4);        % User clicks on the curve
r2=-(1/(t(3)-t(4)))*log(y(3)/y(4));       % Slow rate
A2=(y(3)/exp(-t(3)*r2) + y(4)/exp(-t(4)*r2) )*.5;   % Slow amplitude

r1=-(1/(t(1)-t(2)))*log(y(1)/y(2));       % Fast rate
A1=(y(1)/exp(-t(1)*r1) + y(2)/exp(-t(2)*r1) )*.5;   % Fast amplitude
[ r1 r2]
pc=expfall_twoexp_lsq_error(xdata,ydata,[A1 r1 A2 r2]);
%pc=abs(pc);         % Only use positive values (fit function does the same)




