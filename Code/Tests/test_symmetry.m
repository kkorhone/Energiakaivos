clc

clear all
close all

data = load('uv_field.txt');

sx = data(:, 1);
sy = data(:, 2);
sz = data(:, 3);

ex = data(:, 4);
ey = data(:, 5);
ez = data(:, 6);

sx = sx + 123;
sy = sy + 321;

ex = ex + 123;
ey = ey + 321;

%[sx, sy, sz, ex, ey, ez, fac] = calc_half_symmetry(sx, sy, sz, ex, ey, ez);
calc_quarter_symmetry(sx, sy, sz, ex, ey, ez);
