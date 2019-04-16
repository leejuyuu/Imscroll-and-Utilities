% mfile pvalue_for_overlapping_Gaussians.m
        % See B33p129a.doc p 25	
        % calculate p-test like overlap between the above bootstrapped Gaussians
gs=inline('exp(-(x-xz).^2/2/sigma^2)/sigma/sqrt(2*pi)','x','xz','sigma');	%Normalized Gaussian
load P:\matlab12\larry\data\b33p136c.dat –mat	%Loads bootstrapped distributions for
						% binding rates outsvwo and outsvw
mean(outsvwo.rates(:,2))	%=6.1131E-3  s-1
std(outsvwo.rates(:,2))		%=0.9152E-3  s-1
std(outsvwo.rates(:,2))/mean(outsvwo.rates(:,2)) 	%=0.150
		% rate = (5.9759 ? 0.92) ? 10-3  s-1   (5.9759E-3 from fit to exp data)
mean(outsvw.rates(:,2))		%=3.7151E-3  s-1
std(outsvwo.rates(:,2))		%=0.5880E-3  s-1
std(outsvwo.rates(:,2))/mean(outsvwo.rates(:,2)) 	%=0.158
	% rate = (3.6507 ? 0.59) ? 10-3  s-1 		( 3.6507E-3 from fit to exp data)


gausstable=gs(2E-3:.01E-3:11E-3,5.976E-3,0.9152E-3);	% Gaussian with center, sigma that of the 
% bootstrapped distribution for landing rate at active 
% scaffold sites with asRNA=0 ?M
sum(gausstable)*.01E-3			% =1.00, normalized with 901 values

gausstableLow=gs(2E-3:.001E-3:5.976E-3,5.976E-3,0.9152E-3);	% Gaussian from low end to center value
sum(gausstableLow)*.001e-3
gausstableHigh=gs(11E-3:-0.001E-3:5.976E-3,5.976E-3,0.9152E-3); % Gaussian from high end to center
sum(gausstableHigh)*.001E-3

gaussIntTable=cumsum(gausstableLow)*0.001E-3;	
gaussIntTable=[[2E-3:.001E-3:5.976E-3]' gaussIntTable'];		% [x   (integral from x to infinity)]
							% table runs from low values to Gaussian center
gaussIntTableLow=gaussIntTable;		% 3977 x 2
gaussIntTable=cumsum(gausstableHigh)*0.001E-3;		% [x   (integral from x to infinity)]
% table runs from low values to Gaussian center
gaussIntTable=[[11E-3:-0.001E-3:5.976E-3]' gaussIntTable'];	% 5025 x 2
gaussIntTableHigh=gaussIntTable;

gaussIntTable=[gaussIntTableLow; flipud(gaussIntTableHigh(1:5024,:))];	% The 1:5024 rather than 
% 1:5025 avoids repeating the center 
% point of 5.976E-3 
	% [x   (integral from x to infinity)] where the integral runs to EITHER + or – infinity, whichever you can reach by running from the center to x and then to either + or – infinity.
figure(6);plot(gaussIntTable(:,1),gaussIntTable(:,2),'-');shg
tst=interp1(gaussIntTable(:,1),gaussIntTable(:,2), 5.976E-3);	% = 0.5002,  check
totalPvalue=0;
for indx=1:5000
		% cycle through all the bootstrapped values of the asRNA=2 ?M 
		% We calculate a p-test value for each rate obtained through bootstrapping.  Each
		% p-test value is multiplied by (1/5000) to normalize it by the 5000 rate values in the 
        % bootstrapped list of binding rates with asRNA=2 ?M.  We can think of this as just 
        % normalizing the asRNA=2 ?M distribution in B33p136d.fig to 1, and adding up all p-
        % test values for each bin area of the asRNA=2 ?M rate distribution  
totalPvalue=totalPvalue+(1/5000)* interp1(gaussIntTable(:,1),gaussIntTable(:,2), outsvw.rates(indx,2) );
end
% After running the above integration, we obtain totalPvalue = 0.0206