clc

clear all
close all

radius = 0.5;

alpha = (180 + 15) * pi / 180;

R = [[cos(alpha) -sin(alpha)]; [sin(alpha) cos(alpha)]];

u = [1 0];
v = [0 -1];

u = transpose(R * transpose(u))
v = transpose(R * transpose(v))

num_segments = 36;

plot(0, 0, 'ko')

hold on

for i = 1:num_segments
    alpha1 = 2 * pi * (i - 1) / num_segments;
    alpha2 = 2 * pi * (i - 0) / num_segments;
    plot([radius*cos(alpha1) radius*cos(alpha2)], [radius*sin(alpha1) radius*sin(alpha2)], 'g-')
end

plot([0 u(1)], [0 u(2)], 'r-')
plot([0 v(1)], [0 v(2)], 'b-')

p1 = radius * u;
p2 = radius * (u + v);
p3 = radius * (-u + v);
p4 = radius * -u;

plot([p1(1) p2(1) p3(1) p4(1) p1(1)], [p1(2) p2(2) p3(2) p4(2) p1(2)], 'k-')

hold off

axis equal
