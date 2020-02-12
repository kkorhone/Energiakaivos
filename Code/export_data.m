clc

clear all
close all

% =========================================================================

type = 'ico';
tag = 'component_variables';

% =========================================================================

fprintf(1, 'export_data: Loading model... ');

mph_name = sprintf('%s_solved.mph', type);

model = mphload(mph_name);

fprintf(1, 'Done.\n');

% =========================================================================

fprintf(1, 'export_data: Plotting outlet temperature... ');

model.result.create('pg1', 'PlotGroup1D');
model.result('pg1').run();

model.result('pg1').create('glob1', 'Global');
model.result('pg1').feature('glob1').setIndex('expr', 'T_outlet', 0);
model.result('pg1').feature('glob1').setIndex('unit', 'degC', 0);
model.result('pg1').run();

fprintf(1, 'Done.\n');

% =========================================================================

fprintf(1, 'export_data: Plotting total heat rate... ');

model.result.create('pg2', 'PlotGroup1D');
model.result('pg2').run();

model.result('pg2').create('glob1', 'Global');
model.result('pg2').feature('glob1').setIndex('expr', 'Q_total', 0);
model.result('pg2').feature('glob1').setIndex('unit', 'MW', 0);
model.result('pg2').run();

fprintf(1, 'Done.\n');

% =========================================================================

fprintf(1, 'export_data: Plotting individual heat rates... ');

model.result.create('pg3', 'PlotGroup1D');
model.result('pg3').run();

model.result('pg3').create('glob1', 'Global');

for i = 1:1000
    name = sprintf('Q_wall%d', i);
    try
        model.variable.get(tag).get(name);
        model.result('pg3').feature('glob1').setIndex('expr', name, i-1);
        model.result('pg3').feature('glob1').setIndex('unit', 'MW', i-1);
    catch
        break
    end
end

model.result('pg3').run();

fprintf(1, 'Done.\n');

% =========================================================================

fprintf(1, 'export_data: Plotting individual outlet temperatures... ');

model.result.create('pg4', 'PlotGroup1D');
model.result('pg4').run();

model.result('pg4').create('glob1', 'Global');

for i = 1:1000
    name = sprintf('T_outlet%d', i);
    try
        model.variable.get(tag).get(name);
        model.result('pg4').feature('glob1').setIndex('expr', name, i-1);
        model.result('pg4').feature('glob1').setIndex('unit', 'degC', i-1);
    catch
        break
    end
end

model.result('pg4').run();

fprintf(1, 'Done.\n');

% =========================================================================

fprintf(1, 'export_data: Exporting outlet temperature... ');

txt_name = sprintf('E:\\Work\\Energiakaivos\\Code\\%s_outlet_temperature.txt', type);

model.result.export.create('plot1', 'Plot');
model.result.export('plot1').set('plotgroup', 'pg1');
model.result.export('plot1').set('filename', txt_name);
model.result.export('plot1').run();

fprintf(1, 'Done.\n');
fprintf(1, 'export_data: Exporting total heat rate... ');

txt_name = sprintf('E:\\Work\\Energiakaivos\\Code\\%s_total_heat_rate.txt', type);

model.result.export.create('plot2', 'Plot');
model.result.export('plot2').set('plotgroup', 'pg2');
model.result.export('plot2').set('filename', txt_name);
model.result.export('plot2').run();

fprintf(1, 'Done.\n');
fprintf(1, 'export_data: Exporting individual heat rates... ');

txt_name = sprintf('E:\\Work\\Energiakaivos\\Code\\%s_individual_heat_rates.txt', type);

model.result.export.create('plot3', 'Plot');
model.result.export('plot3').set('plotgroup', 'pg3');
model.result.export('plot3').set('filename', txt_name);
model.result.export('plot3').run();

fprintf(1, 'Done.\n');
fprintf(1, 'export_data: Exporting individual outlet temperatures... ');

txt_name = sprintf('E:\\Work\\Energiakaivos\\Code\\%s_individual_outlet_temperatures.txt', type);

model.result.export.create('plot4', 'Plot');
model.result.export('plot4').set('plotgroup', 'pg4');
model.result.export('plot4').set('filename', txt_name);
model.result.export('plot4').run();

fprintf(1, 'Done.\n');
