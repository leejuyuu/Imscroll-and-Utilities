function ABC = fitLinearLeastSquare3DPlane(data)
% function ABC = fitLinearLeastSquare3DPlane(data)
% Fit (xi,yi,zi) data points to a 3D plane which is z = Ax + By + C
% Input: data = nx3 matrix, each row is a vector (xi, yi, zi)
% Output: ABC = (A, B, C)
% source of derivation of equations:
% https://www.ilikebigbits.com/2015_03_04_plane_from_points.html
%.............................................................................
nPts = length(data(:,1));
% Make each coordinate data sets zero centered (mean == 0), to simplify
% calculations to a set of linear equations containing only A and B
meanData = sum(data,1)/nPts;
x = data(:,1) - meanData(1);
y = data(:,2) - meanData(2);
z = data(:,3) - meanData(3);

% Calculate the summation of each data products
Sxx = sum(x.*x);
Syy = sum(y.*y);
Sxy = sum(x.*y);
Sxz = sum(x.*z);
Syz = sum(y.*z);

% Solving the linear equations by Cramer's law
del = Sxx*Syy-Sxy^2;
A = (Sxz*Syy-Syz*Sxy)/del;
B = (Sxx*Syz-Sxy*Sxz)/del;

% Obtaining C by shifting (x, y, z) back to the original value
C = meanData(3) - A*meanData(1) - B*meanData(2);
ABC = [A,B,C];

end