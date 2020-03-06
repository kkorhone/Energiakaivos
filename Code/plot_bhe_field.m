function plot_bhe_field(bhe_array)

figure

hold on

xlim = [0, 0];
ylim = [0, 0];
zlim = [0, 0];

for i = 1:numel(bhe_array)
    
%     plot3(bhe_array{i}.boreholeCollar(1), bhe_array{i}.boreholeCollar(2), bhe_array{i}.boreholeCollar(3), 'r.')
%     plot3(bhe_array{i}.boreholeFooter(1), bhe_array{i}.boreholeFooter(2), bhe_array{i}.boreholeFooter(3), 'r.')
%     
%     plot3([bhe_array{i}.boreholeCollar(1),bhe_array{i}.boreholeFooter(1)], ...
%         [bhe_array{i}.boreholeCollar(2),bhe_array{i}.boreholeFooter(2)], ...
%         [bhe_array{i}.boreholeCollar(3),bhe_array{i}.boreholeFooter(3)], 'r-')

    bhe_array{i}.plot();

    xlim(1) = min([xlim(1), bhe_array{i}.boreholeFooter(1), bhe_array{i}.boreholeCollar(1)]);
    xlim(2) = max([xlim(2), bhe_array{i}.boreholeFooter(1), bhe_array{i}.boreholeCollar(1)]);
    
    ylim(1) = min([ylim(1), bhe_array{i}.boreholeFooter(2), bhe_array{i}.boreholeCollar(2)]);
    ylim(2) = max([ylim(2), bhe_array{i}.boreholeFooter(2), bhe_array{i}.boreholeCollar(2)]);
    
    zlim(1) = min([zlim(1), bhe_array{i}.boreholeFooter(3), bhe_array{i}.boreholeCollar(3)]);
    zlim(2) = max([zlim(2), bhe_array{i}.boreholeFooter(3), bhe_array{i}.boreholeCollar(3)]);
    
end

xmax = max(abs(xlim));
ymax = max(abs(ylim));
zmax = max(abs(zlim));
dmax = max([xmax, ymax, zmax]);

xlim = [-dmax, +dmax];
ylim = [-dmax, +dmax];
zlim = [-dmax, +0];

plot3(0, 0, 0, 'k.', 'markersize', 20)

plot3([xlim(1),xlim(1),xlim(1),xlim(1),xlim(2),xlim(2),xlim(2),xlim(2)], ...
    [ylim(1),ylim(1),ylim(2),ylim(2),ylim(1),ylim(1),ylim(2),ylim(2)], ...
    [zlim(1),zlim(2),zlim(1),zlim(2),zlim(1),zlim(2),zlim(1),zlim(2)], 'ko')

plot3([xlim(1),xlim(1)], [ylim(1),ylim(2)], [zlim(1),zlim(1)], 'k:')
plot3([xlim(1),xlim(1)], [ylim(1),ylim(2)], [zlim(2),zlim(2)], 'k:')

plot3([xlim(2),xlim(2)], [ylim(1),ylim(2)], [zlim(1),zlim(1)], 'k:')
plot3([xlim(2),xlim(2)], [ylim(1),ylim(2)], [zlim(2),zlim(2)], 'k:')

plot3([xlim(1),xlim(2)], [ylim(1),ylim(1)], [zlim(1),zlim(1)], 'k:')
plot3([xlim(1),xlim(2)], [ylim(1),ylim(1)], [zlim(2),zlim(2)], 'k:')

plot3([xlim(1),xlim(2)], [ylim(2),ylim(2)], [zlim(1),zlim(1)], 'k:')
plot3([xlim(1),xlim(2)], [ylim(2),ylim(2)], [zlim(2),zlim(2)], 'k:')

plot3([xlim(1),xlim(1)], [ylim(1),ylim(1)], [zlim(1),zlim(2)], 'k:')
plot3([xlim(1),xlim(1)], [ylim(2),ylim(2)], [zlim(1),zlim(2)], 'k:')

plot3([xlim(2),xlim(2)], [ylim(1),ylim(1)], [zlim(1),zlim(2)], 'k:')
plot3([xlim(2),xlim(2)], [ylim(2),ylim(2)], [zlim(1),zlim(2)], 'k:')

hold off

xlabel('x')
ylabel('y')
zlabel('z')

axis equal

view(33, 45)
