function T_wall_ave = eval_ave_temp(model, annual_energy_demand)

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', annual_energy_demand));

model.sol('sol1').runAll();

T_wall_ave = min(mphglobal(model, 'T_wall_ave', 'unit', 'degC'));
