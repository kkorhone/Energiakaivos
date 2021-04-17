clc

close all
clear all

model = init_150m_model(20);

label = {};

hold on

for E = [0.1, 0.2, 0.3, 0.4, 0.5]
    
    fprintf(1, 'E = %.3f MWh/a/ha\n', E);
    
    model.param.set('annual_energy_demand', sprintf('%.3f[MW*h]', E));
    
    model.sol('sol1').runAll();
    
    %[t, u, v] = calc_ratios(model);
    
    %plot(t, v)
    
    T_wall_ave = mphglobal(model, 'T_wall_ave', 'unit', 'degC');
    
    plot(T_wall_ave)
    
    label = cat(1, label, sprintf('%.3f MWh/a/ha', E));
    
end

hold off

legend(label)
