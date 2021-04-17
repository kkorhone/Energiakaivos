clc

clear all
close all

% model = init_axisymmetric_model(6.9, 41.5, 3.10, 723, 2794, 300);
% 
% options = optimset('display', 'iter', 'tolx', 0.1);
% 
% obj_func = @(x) abs(eval_mean_temp(model, x));
% 
% E_single = fminbnd(obj_func, 1.0e-2, 1.0e+2, options);
% 
% fprintf(1, 'E_single = %.3f MWh/a\n', E_single);
% 
%  Func-count     x          f(x)         Procedure
%     1        38.2028      3.95776        initial
%     2        61.8072     0.863447        golden
%     3        76.3956       1.0181        golden
%     4        67.6726     0.114194        parabolic
%     5        68.7672      0.05169        parabolic
%     6        71.0333     0.311188        parabolic
%     7        68.8005    0.0561027        parabolic
%     8        68.3899   0.00172994        parabolic
%     9        68.1159    0.0345537        golden
%    10        68.4232   0.00614414        parabolic
%    11        68.3259    0.0067445        parabolic
%  
% Optimization terminated:
%  the current x satisfies the termination criteria using OPTIONS.TolX of 1.000000e-01 
% 
% E_single = 68.390 MWh/a

borehole_spacing = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100, 200, 300, 400, 500];

E_field = zeros(size(borehole_spacing));

for i = 1:length(borehole_spacing)

    model = init_quarter_model(6.9, 41.5, 3.10, 723, 2794, 300, borehole_spacing(i));
    
    options = optimset('display', 'iter', 'tolx', 0.1);
    
    obj_func = @(x) abs(eval_mean_temp(model, x));
    
    E_field(i) = fminbnd(obj_func, 1.0e-3, 1.0e+2, options);
    
    fprintf(1, 'E_field(%.3f m) = %.3f MWh/a\n', borehole_spacing(i), E_field(i));
end

plot(borehole_spacing, E_field, 'bo-')
hold on
plot([min(borehole_spacing), max(borehole_spacing)], [E_single, E_single], 'r-')
hold off
xlabel('Borehole spacing [m]')
ylabel('Heating energy [MWh/a]')
