clc

clear all
close all

global model

data = load('E:\Work\Helsingin_Geoenergiapotentiaali\quarter_hectare_super.txt');

t0 = data(:, 1) / (365.2425 * 86400);
T0 = data(:, 2);

monthly_profile = [0.175414, 0.107229, 0.111884, 0.082876, 0.044846, 0.037201, 0.032188, 0.034649, 0.044508, 0.086641, 0.119199, 0.123365];

borehole_spacing = 20;
borehole_length = 300;

model = init_quarter_hectare(borehole_length, borehole_spacing, monthly_profile);

opts = optimset('display', 'iter');

eval_hectare_abs = @(x) abs(eval_hectare(x));

t = tic;

x1 = fminsearch(eval_hectare_abs, 10, opts)

toc(t)

t = tic;

x2 = fzero(@eval_hectare, 10, opts)

toc(t)

% t = tic;
% 
% eval_hectare(11.4)
% 
% toc(t)
% 
% sol_info = mphsolinfo(model);
% 
% t1 = sol_info.solvals / (365.2425 * 86400);
% T1 = mphglobal(model, 'T_wall', 'unit', 'degC');
% 
% i = find(t0 > 49);
% j = find(t1 > 49);
% 
% plot(t0(i), T0(i), t1(j), T1(j))
% 
% [mean(T0(i)), mean(T1(j))]
