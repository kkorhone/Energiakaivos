model = init_300m_model(500);

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', 15));

model.sol('sol1').runAll();

si = mphsolinfo(model);

t = si.solvals / (365.2425 * 86400);

Q_wall = mphglobal(model, 'Q_wall', 'unit', 'degC');
Q_surface = mphglobal(model, 'Q_surface', 'unit', 'W');

mphsave(model, 'test.mph');

file_id = fopen('fluxes_300m.txt', 'w');

for i = 1:length(t)
    fprintf(file_id, '%.6f %.6f %.6f\n', t(i), Q_wall(i), Q_surface(i));
end

fclose(file_id);
