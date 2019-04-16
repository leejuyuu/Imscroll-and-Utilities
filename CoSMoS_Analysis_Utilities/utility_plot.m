function pc=utility_plot(dat,aoinum,fignum)
%
% utility_plot(dat,aoinum,fignum)
%
% Plotting results from ROG class spot identification B31p140a.doc
hold off
figure(fignum);plot(dat(:,2,aoinum),dat(:,4,aoinum),'r','LineWidth',4);shg		% Plot R amplitude, AOI 4
b=gca;
set(b,'LineWidth',2);shg
set(b,'Fontsize',12);shg
axis([37 52 0 3]);xlabel('Frame number'); ylabel('R, O, or G amplitude');
hold on

figure(fignum);plot(dat(:,2,aoinum),dat(:,5,aoinum),'color',[1 .492 0],'LineWidth',4);shg		% Plot O amplitude
b=gca;
set(b,'LineWidth',2);shg
set(b,'Fontsize',12);shg
axis([37 52 0 3]);xlabel('Frame number'); ylabel('R, O, or G amplitude');
figure(fignum);plot(dat(:,2,aoinum),dat(:,6,aoinum),'g','LineWidth',4);shg       % Plot G amplitude
b=gca;
set(b,'LineWidth',2);shg
set(b,'Fontsize',12);shg
axis([37 52 0 3]);xlabel('Frame number'); ylabel('R, O, or G amplitude');
pc=1;

