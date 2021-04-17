model = mphload('axisymmetric_model_150m.mph');
export_wall_temperatures(model, 'T_axis_wall_150m.txt', 50:1:200);

model = mphload('axisymmetric_model_300m.mph');
export_wall_temperatures(model, 'T_axis_wall_300m.txt', 50:1:200);

model = mphload('axisymmetric_model_1000m.mph');
export_wall_temperatures(model, 'T_axis_wall_100m.txt', 50:1:200);

model = mphload('borefield_model_150m.mph');
export_wall_temperatures(model, 'T_bore_wall_150m.txt', 50:1:10000);

model = mphload('borefield_model_300m.mph');
export_wall_temperatures(model, 'T_bore_wall_300m.txt', 50:1:10000);

model = mphload('borefield_model_1000m.mph');
export_wall_temperatures(model, 'T_bore_wall_1000m.txt', 50:1:10000);
