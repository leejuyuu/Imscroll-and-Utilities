function [numSteps, stepIndices, stepSizes] = identifySteps(Y)
    %From a piecewise constant function in a column vector, identify locations, magnitude, and
    %number of steps
    dY = diff(Y);    %Difference between adjacent values to find jumps
    
    numSteps = sum( dY ~= 0);  %Count number of jumps by adding up number of nonzero values in dY
    
    %Find in this context will specify row, col, and value of nonzero
    %elements in dY
    [stepIndices, ~, stepSizes] = find(dY); 
    
    
end
