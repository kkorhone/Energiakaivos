function annual_energy_demand = write_results(model, file_name)

% -------------------------------------------------------------------------
% Fetch fluxes.
% -------------------------------------------------------------------------

si = mphsolinfo(model);

t = si.solvals / (365.2425 * 86400);

Q_wall = mphglobal(model, 'Q_wall', 'unit', 'degC');
Q_surface = mphglobal(model, 'Q_surface', 'unit', 'W');

% -------------------------------------------------------------------------
% Write output.
% -------------------------------------------------------------------------

file_id = fopen(sprintf('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Potential_3\\Surface_Flux\\%s', file_name), 'w');

for i = 1:length(t)
    fprintf(file_id, '%.6f %.6f %.6f\n', t(i), Q_wall(i), Q_surface(i));
end

fclose(file_id);
