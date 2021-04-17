fprintf(1, 'Loading model.\n');

%model = mphload('axisymmetric_model_150m.mph');

fprintf(1, 'Done loading.\n');

model.component('model_comp').view('view1').axis.set('xmin', -30);
model.component('model_comp').view('view1').axis.set('xmax', 300);
model.component('model_comp').view('view1').axis.set('ymin', -160);

model.result('pg1').set('view', 'view1');

counter = 0;

for year = [0:1/36:5 5+1/12:1/12:25 26:500]
    
    fprintf(1, 'Generating frame_%05d (year = %f).\n', counter, year);
    
    model.result('pg1').setIndex('interp', year, 0);
    model.result('pg1').run;
    
    png_name = sprintf('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Potential_3\\frame_%05d.png', counter);
    
    model.result.export('img1').set('pngfilename', png_name);
    model.result.export('img1').run;
    
    fprintf(1, 'Done generating.\n');
    
    counter = counter + 1;
    
end
