dr = 0.1;

fprintf(1, 'Loading model... ');

% model = mphload('surface_heat_flux_model.mph');

fprintf(1, 'Done.\n');
fprintf(1, 'Creating plot group and result... ');

% model.result.create('heat_flux_plot_group', 'PlotGroup2D');
% model.result('heat_flux_plot_group').create('arrow_plot', 'ArrowSurface');
% model.result('heat_flux_plot_group').label('Surface Heat Flux Plot');
% model.result('heat_flux_plot_group').set('looplevel', {'interp'});
% model.result('heat_flux_plot_group').setIndex('interp', 500, 0);
% model.result('heat_flux_plot_group').feature('arrow_plot').label('Surface Heat Flux Arrows');
% model.result('heat_flux_plot_group').feature('arrow_plot').set('arrowxmethod', 'coord');
% model.result('heat_flux_plot_group').feature('arrow_plot').set('xcoord', sprintf('range(0,%.6e,r_model)', dr));
% model.result('heat_flux_plot_group').feature('arrow_plot').set('arrowymethod', 'coord');
% model.result('heat_flux_plot_group').feature('arrow_plot').set('ycoord', 0);

% model.result.export.create('plot_export', 'Plot');
% model.result.export('plot_export').set('plotgroup', 'heat_flux_plot_group');
% model.result.export('plot_export').set('plot', 'arrow_plot');

fprintf(1, 'Done.\n');

counter = 0;

for year = [123]
    
    fprintf(1, 'Generating frame_%05d (year = %f).\n', counter, year);
    
    file_name = sprintf('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Potential_3\\surface_heat_flux_%05d.txt', year);
    
    model.result('heat_flux_plot_group').setIndex('interp', year, 0);
    model.result('heat_flux_plot_group').run;
    
    model.result.export('plot_export').set('filename', file_name);
    model.result.export('plot_export').run;
    
    data = load(file_name);
    
    r = data(:, 1);
    z = data(:, 2);
    n = data(:, 4);
    
    a = find(n < 0);
    b = find(n > 0);
    
    na = n(a(end));
    nb = n(b(1));
    
    ra = r(a(end));
    rb = r(b(1));
    
    u = (0 - na) / (nb - na);
    ru = (1 - u) * ra + u * rb;
    
    fprintf(1, 'Done generating.\n');
    
    counter = counter + 1;
    
end
