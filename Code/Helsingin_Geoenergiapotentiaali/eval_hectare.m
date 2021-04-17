function T_mean = eval_hectare(x)

global model;

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', x));
model.sol('sol1').runAll();

sol_info = mphsolinfo(model);

t = sol_info.solvals / 86400 / 365.2425;
i = find(t > 49);

T_wall = mphglobal(model, 'T_wall', 'unit', 'degC');
T_mean = mean(T_wall(i));

%T_objective = abs(T_mean);
