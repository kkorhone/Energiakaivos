function T_wall_min = eval_min_temp(model, annual_energy_demand)

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', annual_energy_demand));

model.sol('sol1').runAll();

T_wall_min = min(mphglobal(model, 'T_wall_min', 'unit', 'degC'));
