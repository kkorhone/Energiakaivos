function export_total_heat_rates(mph_name)

tokens = strsplit(mph_name, '_');
base_name = join(tokens(1:4), '_');
txt_name = sprintf('%s_total_heat_rates.txt', base_name{1});

fprintf(1, 'mph_name = %s\n', mph_name);
fprintf(1, 'txt_name = %s\n', txt_name);

model = mphload(mph_name);

model.result.create('total_heat_rate_group', 'PlotGroup1D');
model.result('total_heat_rate_group').create('glob1', 'Global');
model.result('total_heat_rate_group').feature('glob1').setIndex('expr', 'Q_total', 0);
model.result('total_heat_rate_group').feature('glob1').setIndex('unit', 'MW', 0);
model.result('total_heat_rate_group').feature('glob1').set('xdataparamunit', 'h');
model.result('total_heat_rate_group').run();

model.result.export.create('total_heat_rate_plot', 'total_heat_rate_group', 'glob1', 'Plot');
model.result.export('total_heat_rate_plot').set('filename', sprintf('E:\\Work\\Energiakaivos\\Code\\Full_Models\\%s', txt_name));
model.result.export('total_heat_rate_plot').run();
