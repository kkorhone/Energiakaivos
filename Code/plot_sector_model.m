clc

close all
clear all

sector_angle = 30;

borehole_tilts = -90:10:0;
borehole_azimuths = 0:sector_angle:(360-sector_angle);

borehole_offset = 30;
borehole_length = 300;

num_boreholes = 0;

figure
hold on

for i = 1:length(borehole_azimuths)
    phi = borehole_azimuths(i) * pi / 180;
    for j = 1:length(borehole_tilts)
        theta = (180 - borehole_tilts(j)) * pi / 180;
        x1 = borehole_offset * sin(theta) * cos(phi);
        y1 = borehole_offset * sin(theta) * sin(phi);
        z1 = borehole_offset * cos(theta);
        x2 = (borehole_offset + borehole_length) * sin(theta) * cos(phi);
        y2 = (borehole_offset + borehole_length) * sin(theta) * sin(phi);
        z2 = (borehole_offset + borehole_length) * cos(theta);
        plot3(x1, y1, z1, 'r.')
        plot3(x2, y2, z2, 'ro')
        plot3([x1, x2], [y1, y2], [z1, z2], 'r-')
        num_boreholes = num_boreholes + 1;
    end
end

hold off

title(sprintf('num_boreholes=%d', num_boreholes))

grid on
