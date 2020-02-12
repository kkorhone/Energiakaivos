model = init_cylinder_model('uv_config.txt');
mphsave(model, 'uv.mph');

model = init_cylinder_model('ico_config.txt');
mphsave(model, 'ico.mph');
