clc

%clear all
close all

zlevel = -1000;
xlimit = 225;
xticks = -200:50:200;

times = [25, 50, 100];

levels = [-3 -2 -1 -0.5 -0.25 -0.1];

figure();

set(gcf, 'position', [50, 50, 1050, 900]);

x_ax = [0.045, 0.3675, 0.69];
y_ax = 0.99;
w_ax = 0.3;
h_ax = 0.295;
g_ax = 0.03;

axlim1 = [x_ax(1), x_ax(1)+w_ax];
axlim2 = [x_ax(2), x_ax(2)+w_ax];
axlim3 = [x_ax(3), x_ax(3)+w_ax];

fprintf(1, 'ax1 = [%.4f, %.4f] = %.4f\n', axlim1, diff(axlim1))
fprintf(1, 'gap = %.4f\n', axlim2(1)-axlim1(2));
fprintf(1, 'ax2 = [%.4f, %.4f] = %.4f\n', axlim2, diff(axlim2))
fprintf(1, 'gap = %.4f\n', axlim3(1)-axlim2(2));
fprintf(1, 'ax3 = [%.4f, %.4f] = %.4f\n', axlim3, diff(axlim3))

model = mphload('F:\TEMP\single_well_model.mph');

for i = 1:length(times)
    n = 2 * (i - 1) + 1;
    axes('position', [x_ax(1), y_ax-i*h_ax-(i-1)*g_ax, w_ax, h_ax]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     plot(-xlimit+(2*xlimit)*rand(1,100), -xlimit+(2*xlimit)*rand(1,100));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [xi, yi, zi] = evaluate_cut_plane(model, sprintf('T-T_initial(%d[m])',zlevel), 'K', -xlimit:0, 0:xlimit, zlevel, times(i));
    contourf(xi, yi, zi, 256, 'color', 'none');
    hold on
    colormap(bluewhitered(256));
    [c, h] = contour(xi, yi, zi, levels, 'color', 'r');
    clabel(c, h, 'labelspacing', 700, 'color', 'r');
    caxis([-8, 0]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    text(-(xlimit-5), xlimit, sprintf('Yhden kaivon malli: aika = %d v', times(i)), 'verticalalign', 'top');
    axis('equal');
    set(gca, 'xtick', xticks, 'ytick', xticks);
    set(gca, 'xlim', [-xlimit, xlimit], 'ylim', [-xlimit, xlimit]);
    if i < 3
        set(gca, 'xticklabel', []);
    end
    ylabel('y-koordinaatti [m]');
    if n == 5
        xlabel('x-koordinaatti [m]');
    end
    hold off
    grid on
end

model = mphload('F:\TEMP\two_well_model_30m.mph');

for i = 1:length(times)
    n = 2 * (i - 1) + 1;
    axes('position', [x_ax(2), y_ax-i*h_ax-(i-1)*g_ax, w_ax, h_ax]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     plot(-xlimit+(2*xlimit)*rand(1,100), -xlimit+(2*xlimit)*rand(1,100));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [xi, yi, zi] = evaluate_cut_plane(model, sprintf('T-T_initial(%d[m])',zlevel), 'K', -xlimit:0, 0:xlimit, zlevel, times(i));
    contourf(xi, yi, zi, 256, 'color', 'none');
    hold on
    colormap(bluewhitered(256));
    [c, h] = contour(xi, yi, zi, levels, 'color', 'r');
    clabel(c, h, 'labelspacing', 700, 'color', 'r');
    caxis([-8, 0]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    text(-(xlimit-5), xlimit, sprintf('Kahden kaivon malli: aika = %d v, välimatka = 30 m', times(i)), 'verticalalign', 'top');
    axis('equal');
    set(gca, 'xtick', xticks, 'ytick', xticks);
    set(gca, 'xlim', [-xlimit, xlimit], 'ylim', [-xlimit, xlimit]);
    set(gca, 'yticklabel', []);
    if i < 3
        set(gca, 'xticklabel', []);
    end
    if n == 5
        xlabel('x-koordinaatti [m]');
    end
    hold off
    grid on
end

model = mphload('F:\TEMP\two_well_model_70m.mph');

for i = 1:length(times)
    n = 2 * (i - 1) + 1;
    axes('position', [x_ax(3), y_ax-i*h_ax-(i-1)*g_ax, w_ax, h_ax]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     plot(-xlimit+(2*xlimit)*rand(1,100), -xlimit+(2*xlimit)*rand(1,100));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [xi, yi, zi] = evaluate_cut_plane(model, sprintf('T-T_initial(%d[m])',zlevel), 'K', -xlimit:0, 0:xlimit, zlevel, times(i));
    contourf(xi, yi, zi, 256, 'color', 'none');
    hold on
    colormap(bluewhitered(256));
    [c, h] = contour(xi, yi, zi, levels, 'color', 'r');
    clabel(c, h, 'labelspacing', 700, 'color', 'r');
    caxis([-8, 0]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    text(-(xlimit-5), xlimit, sprintf('Kahden kaivon malli: aika = %d v, välimatka = 70 m', times(i)), 'verticalalign', 'top');
    axis('equal');
    set(gca, 'xtick', xticks, 'ytick', xticks);
    set(gca, 'xlim', [-xlimit, xlimit], 'ylim', [-xlimit, xlimit]);
    set(gca, 'yticklabel', []);
    if i < 3
        set(gca, 'xticklabel', []);
    end
    if n == 5
        xlabel('x-koordinaatti [m]');
    end
    hold off
    grid on
end

set(gcf, 'paperposition', [0, 0, 31, 30], 'paperunit', 'centimeters');

print('test.png', '-dpng', '-r300');
