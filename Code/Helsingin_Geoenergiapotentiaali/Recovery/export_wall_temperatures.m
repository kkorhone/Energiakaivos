function export_wall_temperatures(model, file_name, time_instances)

model.result.create('pg1', 'PlotGroup1D');

model.result('pg1').setIndex('looplevelinput', 'interp', 0);
model.result('pg1').setIndex('interp', time_instances, 0);
model.result('pg1').create('lngr1', 'LineGraph');
model.result('pg1').feature('lngr1').selection.set([6]);
model.result('pg1').feature('lngr1').set('expr', 'z');
model.result('pg1').feature('lngr1').set('xdata', 'expr');
model.result('pg1').feature('lngr1').set('xdataexpr', 'T-T_initial(z)');
model.result('pg1').run;

model.result.export.create('plot1', 'Plot');
model.result.export('plot1').set('filename', sprintf('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Recovery\\%s', file_name));
model.result.export('plot1').run;

fprintf(1, 'E:\\Work\\Helsingin_Geoenergiapotentiaali\\Recovery\\%s\n', file_name);
