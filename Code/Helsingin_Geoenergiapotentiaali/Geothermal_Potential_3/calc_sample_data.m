clc

clear all
close all

k_rock = [2.6600, 2.8700, 3.1000, 3.1700, 3.2000, 3.2500];
Cp_rock = [712, 721, 723, 725, 731];
rho_rock = [2640, 2675, 2707, 2794, 2804, 2906];

T_surface = 6.6:0.1:7.1;
q_geothermal = 40.5:0.5:42.5;

E_annual = 10:0.2:13;

T_avg = zeros(size(E_annual));

model = init_300m_model();

i = 1;

model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface(i)));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal(i)));

j = 1;
k = 1;

for n = 1:length(E_annual)
    
    T_avg(i) = eval_avg_temp(model, E_annual(n));
    
    fprintf(file_id, '%.2f %.0f %.0f %.3f %.3f %.3f\n', k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    
    fprintf(1, 'i=%d poly_id=%d k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E=%.3f\n', i, poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    fprintf(1, 'single_poly=%.3f since_start=%.3f\n', toc(t)/60, toc(tic_start)/60);
    
end

fclose(file_id);
