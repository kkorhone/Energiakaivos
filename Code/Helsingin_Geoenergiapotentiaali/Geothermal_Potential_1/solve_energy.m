function energy = solve_energy

% * T_surface
% * q_geothermal
% k_rock
% rho_rock
% Cp_rock
% H_soil
% k_soil

monthly_profile = [0.175414, 0.107229, 0.111884, 0.082876, 0.044846, 0.037201, 0.032188, 0.034649, 0.044508, 0.086641, 0.119199, 0.123365];

model = init_bedrock_model(300, 20, monthly_profile);

fprintf(1, '=== %s ===\n', char(model.label));

fprintf(1, 'T_surface=%s\n', char(model.param.get('T_surface')));
fprintf(1, 'q_geothermal=%s\n', char(model.param.get('q_geothermal')));

fprintf(1, 'k_rock=%s\n', char(model.param.get('k_rock')));
fprintf(1, 'rho_rock=%s\n', char(model.param.get('rho_rock')));

try
    fprintf(1, 'H_soil=%s\n', char(model.param.get('H_soil')));
    fprintf(1, 'k_soil=%s\n', char(model.param.get('k_soil')));
    fprintf(1, 'Cp_soil=%s\n', char(model.param.get('Cp_soil')));
    fprintf(1, 'rho_soil=%s\n', char(model.param.get('rho_soil')));
end

fprintf(1, '=== %s ===\n', char(model.label));

options = optimset('display', 'iter', 'tolx', 0.01);

obj_func = @(x) abs(eval_mean_temp(model, x));

x = fminbnd(obj_func, 5, 25, options);
