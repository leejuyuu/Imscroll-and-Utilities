function [isUnpaired] = findUnpairedSteps (steps, start)
    %Similar to finding pairs of parentheses like so:
        %   *    *
        %    ****
        % [[[[][]]

    counter = 1;
    pairIndex = -999;
    if (start+1 <= length(steps))
        for i = start+1:length(steps)
    
    	    if (steps(1,i) == -1)
                    counter = counter + 1;
            elseif (steps(1,i) == 1)
    	        counter = counter - 1;
    	    end
            
    	    if (counter == 0)
                    pairIndex = i;
    	        break;
    	    end
        end
    end

    if (counter ~= 0) %Step is unpaired, so it's not a blink
        isUnpaired = 1;
    else
        isUnpaired = 0;
    end
end