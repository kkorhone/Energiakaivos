clc

clear all
close all

rock_type = {'Amfiboliitti', 'Gabro', 'Graniitti', 'Grano- ja kvartsidioriitti', 'Kiillegneissi', 'Kvartsi-maasälpägneissi'};

rho_rock = [2906.0, 2804.0, 2640.0, 2675.0, 2707.0, 2794.0];
Cp_rock = [731.0, 712.0, 721.0, 731.0, 725.0, 723.0];
k_rock = [2.66, 3.25, 3.20, 3.17, 2.87, 3.10];

% -------------------------------------------------------------------------
% Infinite borehole field.
% -------------------------------------------------------------------------

model = init_model(300, 20);

options = optimset('display', 'iter', 'tolx', 0.1);

file_id = fopen('comsol_300m_borehole_field_20m.txt', 'w');

for i = 1:length(rock_type)
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    t = tic();
    
    E = fminbnd(obj_func, 5, 25, options);
    
    fprintf(1, 'Elapsed time is %.3f minutes.\n', toc(t)/60);
    
    fprintf(file_id, '%-30s %.3f\n', rock_type{i}, E);
    
end

fclose(file_id);

% -------------------------------------------------------------------------
% Single borehole.
% -------------------------------------------------------------------------

model = init_model(300, 500);

options = optimset('display', 'iter', 'tolx', 0.1);

file_id = fopen('comsol_300m_single_borehole.txt', 'w');

for i = 1:length(rock_type)
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    t = tic();
    
    E = fminbnd(obj_func, 30, 60, options);
    
    fprintf(1, 'Elapsed time is %.3f minutes.\n', toc(t)/60);
    
    fprintf(file_id, '%-30s %.3f\n', rock_type{i}, E);
    
end

fclose(file_id);
