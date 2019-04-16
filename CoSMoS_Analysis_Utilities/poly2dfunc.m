function pc=poly2dfunc(inarg,xdata)
%
% function poly2dfunc(inarg,xdata)
%
% This function will be called from poly2dfit() while using the
% lscurvefit() function to fit a two dimensional quadratic polynomial.  The form of the
% function is:
%  a*X + b*X^2 + c*Y + d*Y^2 + e*X*Y + f
%
% where the input arguements are given in inarg according to
% inarg  == [ a b c d e f]
% xdata(:,:,1) == x matrix defining the x range of data
% xdata(:,:,2) == y matrix defining the y range of data
%                  e.g.  11 x 10 matrices running 0 to 1 in each dimension
%                    will be given by:
%                   xdata(:,:,1)=ones(11,10)*diag( [0:9])
%                   xdata(:,:,2)=diag([0:10])*ones(11,10)

%pc= inarg(1)*exp( -( (xdata(:,:,1)-inarg(2)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(3)).^2/(2*inarg(4)^2) )  )+inarg(5);
pc= inarg(1)*xdata(:,:,1) +inarg(2)*xdata(:,:,1).*xdata(:,:,1) + inarg(3)*xdata(:,:,2) +...
                   inarg(4)*xdata(:,:,2).*xdata(:,:,2) + inarg(5)*xdata(:,:,1).*xdata(:,:,2) + inarg(6);