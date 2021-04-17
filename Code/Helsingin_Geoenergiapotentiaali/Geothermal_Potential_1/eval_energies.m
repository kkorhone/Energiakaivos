function [E_single, E_field] = eval_energies(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, borehole_length, borehole_spacing, max_E)

fprintf(1, 'eval_energies ==================================================\n');
fprintf(1, 'T_surface = %.3f degC\n', T_surface);
fprintf(1, 'q_geothermal = %.3f mW/m^2\n', q_geothermal);
fprintf(1, 'k_rock = %.3f W/(m*K)\n', k_rock);
fprintf(1, 'Cp_rock = %.3f J/(kg*K)\n', Cp_rock);
fprintf(1, 'rho_rock = %.3f kg/m^3\n', rho_rock);
fprintf(1, 'borehole_length = %.3f m\n', borehole_length);

tic

model = init_quarter_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, borehole_length, 500.0);

options = optimset('display', 'iter', 'tolx', 0.1);

obj_func = @(x) abs(eval_min_temp(model, x));

E_single = fminbnd(obj_func, 0, max_E, options);

toc

fprintf(1, 'E_single = %.3f MWh/a\n', E_single);

E_field = zeros(size(borehole_spacing));

for i = 1:length(borehole_spacing)

    tic
    
    model = init_quarter_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, borehole_length, borehole_spacing(i));
    
    options = optimset('display', 'iter', 'tolx', 0.1);
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    E_field(i) = fminbnd(obj_func, 0, max_E, options);
    
    toc
    
    fprintf(1, 'borehole_spacing(%d) = %.3f m, E_field(%d) = %.3f MWh/a\n', i, borehole_spacing(i), i, E_field(i));
    
end

fprintf(1, 'eval_energies ==================================================\n');
