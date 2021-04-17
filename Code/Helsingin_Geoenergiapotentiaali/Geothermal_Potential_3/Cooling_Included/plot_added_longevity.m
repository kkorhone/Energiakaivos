clc

clear all
close all

load('longevity_150m.mat');

figure

plot(t, T_wall_min)

hold on

xlim = get(gca(), 'xlim');
ylim = get(gca(), 'ylim');

for year = 0:99
    i = find((t >= year) & (t <= year+1));
    plot([year, year], ylim, ':', 'color', [0.5, 0.5, 0.5])
    plot([year+1, year+1], ylim, ':', 'color', [0.5, 0.5, 0.5])
    if min(T_wall_min(i)) < 0
        fill([year, year+1, year+1, year], [ylim(1), ylim(1), ylim(2), ylim(2)], [0.85, 0.85, 0.85], 'edgecolor', 'none')
        plot(t(i), T_wall_min(i), 'r')
        plot([year, year+1], [min(T_wall_min(i)), min(T_wall_min(i))], 'r-')
        break
    end
    if year >= 50
        text(year+0.5, mean(T_wall_min(i)), num2str(year-49), 'fontsize', 24, 'fontweight', 'bold', 'color', 'r')
    end
end

hold off
