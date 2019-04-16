function pc=plot_cumul(cia,range,offset,N,fignum)
%
% function plot_cumul(cia,range,offset,N,fignum)
cumul=[];
for indx=range
logik=cia(:,2)>indx;
cumul=[cumul;indx sum(logik)];
end
Nm=max(cumul(:,2));
figure(fignum);plot(cumul(:,1)-offset,log( (cumul(:,2)+N-Nm)/N),'o');shg