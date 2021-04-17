function annual_energy_demand = find_annual_energy_demand(model)

% -------------------------------------------------------------------------
% Find annual energy demand.
% -------------------------------------------------------------------------

obj_func = @(x) abs(eval_min_temp(model, x));

options = optimset('display', 'iter', 'tolx', 0.1);

[annual_energy_demand, func_value, exit_flag] = fminbnd(obj_func, 0.001, 1000, options);

if exit_flag <= 0
    annual_energy_demand = nan;
end
