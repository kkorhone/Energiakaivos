clc

cooling_fraction = 0.5;

options = optimset('display', 'iter', 'tolx', 0.1);

% -------------------------------------------------------------------------
% 150-m boreholes
% -------------------------------------------------------------------------

model = init_150m_model(20, cooling_fraction, 'range(0,1/36,50)');

obj_func = @(x) abs(eval_min_temp(model, x));

E_150 = fminbnd(obj_func, 7, 9, options);
T_min = eval_min_temp(model, E_150);

fprintf(1, '150m: E_borehole=%.3f T_min=%.3f\n', E_150, T_min);

mphsave(model, 'model_150m.mph');

% -------------------------------------------------------------------------
% 300-m boreholes
% -------------------------------------------------------------------------

model = init_300m_model(20, cooling_fraction, 'range(0,1/36,50)');

obj_func = @(x) abs(eval_min_temp(model, x));

E_300 = fminbnd(obj_func, 14, 16, options);
T_min = eval_min_temp(model, E_300);

fprintf(1, '300m: E_borehole=%.3f T_min=%.3f\n', E_300, T_min);

mphsave(model, 'model_300m.mph');

% -------------------------------------------------------------------------
% 1000-m boreholes
% -------------------------------------------------------------------------

model = init_1000m_model(20, cooling_fraction, 'range(0,1/36,50)');

obj_func = @(x) abs(eval_min_temp(model, x));

E_1000 = fminbnd(obj_func, 47.5, 52.5, options);
T_min = eval_min_temp(model, E_1000);

fprintf(1, '1000m: E_borehole=%.3f T_min=%.3f\n', E_1000, T_min);

mphsave(model, 'model_1000m.mph');
