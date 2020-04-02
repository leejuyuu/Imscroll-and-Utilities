function pc=mappingfit_fminsearch(field1_xy, field2_x_or_y, startCoeff)
%
% function mappingfit(indata,<inputarg0>)
%
% Used to map the xy points in image1 to xy points in image2.  The mapping
% will be done first for x1y1 -> x2 and then x1y1 -> y2.  That is, rather
% than a simple linear mapping of e.g. x2 =m*x1+b,we put in some y
% dependence as well so that e.g. x2 = mxx21*x1 + mxy21*y1 +bx (similar for y
% mapping)
% Will fit the 'indata' (nx2 matrix of xy pairs + mapped x or y coordinate) .
%
% indata     == cell array indata{1} = n x 2 list of xy points in the image1
%                          indata{2} = n x 1 list of x2 (or y2) points in
%                                      the image2 field
% inputarg0  == optional starting parameters for the fit
%                 [ mxx21 mxy21 bx](mapping x1y1 to x2) or 
%                  [myx21 myy21 by] (mapping x1y1 to y2)
%
% The form of the fit will be:
%                 x2 = mxx21*x1 + mxy21*y1 + bx
%                 y2 = myx21*x1 + myy21*y1 + by
%
%     

% Copyright 2015 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

fun = @(coeff) mappingfunc_fminsearch(field1_xy, field2_x_or_y, coeff);
pc = fminsearch(fun, startCoeff(:));

function pc=mappingfunc_fminsearch(field1_xy, field2_x_or_y, coeff)
%
% function mappingfunc_fminsearch(inarg,xdata,ydata
%
% This function will be called from mappingfit_fminsearch() while using the
% lscurvefit() function to map the x1y1 image1 point pairs onto x2 or y2
% points.  
% The form of the mapping is
% x2 = mxx21 * x1 + mxy21* y1 + bx
% or
% y2 = myx21 * x1 + myy21 * y1 + by
%
% where the input arguements are given in inarg according to
% inarg  == [ mxx21 mxy21 bx21] (mapping to x2) or [ myx21 myy21 by] (when
%                                                          mapping to y2)
% xdata == n x 2 list of [x1(:) y1(:)] points that will be mapped onto
%          either an x2(:) or y2(:) list of output points
% ydata== 1 x n list of either x2(:) or y2(:) output points
% see also mappingfunc_rot_mag_trans.m for fit to a transformation that is
% strictly a translation, magnification and rotation (4 free parameters)
x1 = field1_xy(:, 1);
y1 = field1_xy(:, 2);
pc= sum( (field2_x_or_y -(coeff(1)*x1 + coeff(2)*y1 + coeff(3)) ).^2);