clc

clear all
close all

field = load('uv_field.txt');

[sx, sy, sz, ex, ey, ez, fac] = calc_half_symmetry(field);
%calc_quarter_symmetry(sx, sy, sz, ex, ey, ez);
