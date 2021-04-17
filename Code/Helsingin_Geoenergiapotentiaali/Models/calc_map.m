clc

clear all
close all

global model

data = load('random_sample.txt');

x = data(:, 1);
y = data(:, 2);

k_rock = data(:, 3);
Cp_rock = data(:, 6);
rho_rock = data(:, 9);

T_surface = data(:, 12);
q_geothermal = data(:, 15);

E_block = zeros(size(k_rock));

file_id = fopen('output.txt', 'wt');

for i = 1:length(k_rock)
    
    tic
    
    fprintf(1, 'i=%d\n', i);
    
    model = init_quarter_model_no_soil(T_surface(i), q_geothermal(i), k_rock(i), Cp_rock(i), rho_rock(i));
    
    opts = optimset('display', 'iter', 'tolx', 0.1);
    
    E = fminbnd(@eval_model, 0.01, 100.0, opts);
    
    E_block(i) = E;
    
    fprintf(1, ' => E_block=%.3f[MWh/a] elapsed=%.3f[min]\n', E_block(i), toc/60);
    
    fprintf(file_id, '%.3f %.3f %.3f\n', x(i), y(i), E);
    
end

fclose(file_id);
