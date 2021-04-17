clc

clear all
close all

opts = optimset('display', 'iter', 'tolx', 0.1);

global model

H_soil = linspace(0, 299, 50);

T_surface = 6.5 * ones(size(H_soil));
q_geothermal = 42.0 * ones(size(H_soil));

k_rock = 3.2 * ones(size(H_soil));
Cp_rock = 725 * ones(size(H_soil));
rho_rock = 2700 * ones(size(H_soil));

k_soil = 1.5 * ones(size(H_soil));
Cp_soil = 1600 * ones(size(H_soil));
rho_soil = 1500 * ones(size(H_soil));

E_block = zeros(size(H_soil));

for i = 1:length(H_soil)
    
    tic
    
    fprintf(1, 'i=%d H_soil=%.3f[m]\n', i, H_soil(i));
    
    if H_soil(i) < 0.1
        model = init_quarter_model_no_soil(T_surface(i), q_geothermal(i), k_rock(i), Cp_rock(i), rho_rock(i));
    else
        model = init_quarter_model_with_soil(T_surface(i), q_geothermal(i), k_rock(i), Cp_rock(i), rho_rock(i), H_soil(i), k_soil(i), Cp_soil(i), rho_soil(i));
    end
    
    % E = fminbnd(@eval_model, 0.01, 100.0, opts);
    E = fminbnd(@eval_model, 0.01, 100, opts);
    
    E_block(i) = E;
    
    fprintf(1, ' => E_block=%.3f[MWh/a] elapsed=%.3f[min]\n', E_block(i), toc/60);
    
end
