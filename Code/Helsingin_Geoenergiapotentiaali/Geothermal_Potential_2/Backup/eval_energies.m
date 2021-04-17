function E = eval_energies(borehole_length, borehole_spacing, E_max)

fprintf(1, 'eval_energies ==================================================\n');
fprintf(1, 'borehole_length = %.3f m\n', borehole_length);
fprintf(1, 'E_max = %.3f (MW*h)/a\n', E_max);

E = zeros(size(borehole_spacing));

for i = 1:length(borehole_spacing)

    tic
    
    model = init_model(borehole_length, borehole_spacing(i));
    
    options = optimset('display', 'iter', 'tolx', 0.1);
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    E(i) = fminbnd(obj_func, 0, E_max, options);
    
    toc
    
    fprintf(1, 'borehole_spacing(%d) = %.3f m, E(%d) = %.3f MWh/a\n', i, borehole_spacing(i), i, E(i));
    
end

fprintf(1, 'eval_energies ==================================================\n');
