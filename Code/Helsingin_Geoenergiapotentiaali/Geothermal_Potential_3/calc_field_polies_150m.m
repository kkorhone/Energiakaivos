clc

clear all
close all

data = load('bedrock_map.txt');

poly_id = data(:, 1);
k_rock = data(:, 2);
Cp_rock = data(:, 3);
rho_rock = data(:, 4);
T_surface = data(:, 5);
q_geothermal = data(:, 6);

model = init_150m_model();

options = optimset('display', 'iter', 'tolx', 0.1);

file_id = fopen('polies_150m_20m_min.txt', 'w');

tic_start = tic;

for i = 1:length(poly_id)
    
    t = tic;
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface(i)));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal(i)));
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    [E, func_value, exit_flag] = fminbnd(obj_func, 4, 6, options);
    
    if exit_flag <= 0
        E = nan;
    end
    
    fprintf(file_id, '%3d %.2f %.0f %.0f %.3f %.3f %.3f\n', poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    
    fprintf(1, 'i=%d poly_id=%d k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E=%.3f\n', i, poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    fprintf(1, 'single_poly=%.3fmin since_start=%.3fhrs\n', toc(t)/60, toc(tic_start)/3600);
    
end

fclose(file_id);
