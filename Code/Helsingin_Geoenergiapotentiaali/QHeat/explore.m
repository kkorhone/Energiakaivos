% load results3
% 
% k = 1:21;
% 
% leg = {};
% for i = k
%     leg{end+1} = sprintf('%.0f m', borehole_spacing(i));
% end
% 
% j = find(x0<=100);
% 
% %plot(x0(j),y0(j),'linewidth',2)
% %hold on
% plot(x1(j,k),y1(j,k),'-')
% %hold off
% legend(leg)
% 
% return





clc

close all

d = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
d = borehole_spacing;

figure
semilogx([1,1000],[0,0])
hold on
for i = 1:length(d)
    semilogx(x1(:,i),(y1(:,i)-y0(:))*100./y0(:))
end
hold off
set(gca,'xlim',[1,1000])
grid

figure
semilogx([1,1000],[0,0])
hold on
for i = 1:length(d)
    semilogx(X1(:,i),(Y1(:,i)-Y0(:))*100./Y0(:))
end
hold off
set(gca,'xlim',[1,1000])
grid

%xx=[xi-100, xi, xi+100; xi-100, xi, xi+100; xi-100, xi, xi+100];
%yy=[yi-100, yi-100, yi-100; yi, yi, yi; yi+100, yi+100, yi+100];
%pp=[pi, pi, pi; pi, pi, pi; pi, pi, pi];
