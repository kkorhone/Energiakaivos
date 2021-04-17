function T_min = eval_min_temp(model, annual_energy_demand)

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', annual_energy_demand));

model.sol('sol1').runAll();

sol_info = mphsolinfo(model);

t = sol_info.solvals / 86400 / 365.2425;

T_wall = mphglobal(model, 'T_wall', 'unit', 'degC');

T_min = min(T_wall(t > 49));
