function [isSmall] = filterSmallSteps (stepSize, rms)
    %Filter out the occasional small step detected by tDetector2
    %Step sizes smaller than the noise removed

    if (rms >= abs(stepSize)) %Step should be clearly distinguishable from noise in trace
        isSmall = 1;
    else
        isSmall = 0;
    end

end
