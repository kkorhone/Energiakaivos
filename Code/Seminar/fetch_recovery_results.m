fprintf(1, '### Loading model... ');

% model = mphload('recovery_solved.mph');

fprintf(1, 'Done.\n');
fprintf(1, '### Creating data sets... ');

% model.result.dataset.create('mir1', 'Mirror3D');
% model.result.dataset.create('cpl1', 'CutPlane');
% model.result.dataset('cpl1').set('quickplane', 'xz');
% model.result.dataset('cpl1').set('data', 'mir1');

fprintf(1, 'Done.\n');
fprintf(1, '### Creating plot group... ');

% model.result.create('pg1', 'PlotGroup2D');
% model.result('pg1').create('surf1', 'Surface');
% model.result('pg1').feature('surf1').set('expr', 'T-T_initial(z)');
% model.result('pg1').set('looplevel', {'interp'});
% model.result('pg1').set('interp', [0]);

fprintf(1, 'Done.\n');
fprintf(1, '### Creating plot export... ');

% model.result.export.create('plot1', 'Plot');

fprintf(1, 'Done.\n');

frame_counter = 0;

for t = 0:100
    
    tic
    
    fprintf(1, '### Plotting frame %f a... ', t);
    
    model.result('pg1').set('interp', [t]);
    model.result('pg1').run();
    
    fprintf(1, 'Done.\n');
    fprintf(1, '### Creating plot group... ');
    
    file_name = sprintf('E:\\Work\\Energiakaivos\\Code\\Seminar\\frame_%03d.txt', frame_counter);
    
    model.result.export('plot1').set('filename', file_name);
    model.result.export('plot1').run();
    
    fprintf(1, 'Done in %.0f seconds.\n', toc);
    
    frame_counter = frame_counter + 1;
    
end
