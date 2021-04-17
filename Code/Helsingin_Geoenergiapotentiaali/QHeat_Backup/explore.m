clc

close all

figure
semilogx([1,1000],[0,0])
hold on
for i = 1:length(d)
    semilogx(x(:,i),(y(:,i)-y0(:))*100./y0(:))
end
hold off
set(gca,'xlim',[1,1000])
grid

figure
semilogx([1,1000],[0,0])
hold on
for i = 1:length(d)
    semilogx(X(:,i),(Y(:,i)-Y0(:))*100./Y0(:))
end
hold off
set(gca,'xlim',[1,1000])
grid

xx=[xi-100, xi, xi+100; xi-100, xi, xi+100; xi-100, xi, xi+100];
yy=[yi-100, yi-100, yi-100; yi, yi, yi; yi+100, yi+100, yi+100];
pp=[pi, pi, pi; pi, pi, pi; pi, pi, pi];
