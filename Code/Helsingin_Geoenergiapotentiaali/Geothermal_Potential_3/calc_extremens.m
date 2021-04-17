clc

clear all
close all

k_rock = data(:, 1);
Cp_rock = data(:, 2);
rho_rock = data(:, 3);
T_surface = data(:, 4);
q_geothermal = data(:, 5);

E = zeros(length(k_rock), 1);

model = init_300m_model();

options = optimset('display', 'iter', 'tolx', 0.1);

file_id = fopen('comsol_polies_300m.txt', 'w');

tic_start = tic;

for i = 1:length(k_rock)
    
    t = tic;

    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface(i)));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal(i)));

    obj_func = @(x) abs(eval_min_temp(model, x));
    
    E(i) = fminbnd(obj_func, 0, 30, options);
    
    fprintf(file_id, '%2d %.2f %.0f %.0f %.3f %.3f %.3f\n', poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E(i));

    fprintf(1, 'poly_id=%d k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E=%.3f\n', poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E(i));
    fprintf(1, 'single_poly=%.3f since_start=%.3f\n', toc(t)/60, toc(tic_start)/60);

end

fclose(file_id);
