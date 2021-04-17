borehole_spacing = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200 250 300 350 400 450 500];

com.comsol.model.util.ModelUtil.showProgress(true);

model = init_single_well_model();

model.param.set('h_borehole', '5[mm]');
model.param.set('g_borehole', '1.2');
model.param.set('g_rock', '1.1');
model.param.set('n_swept', '200');
model.param.set('g_bottom', '1.1');

model.component('model_component').mesh('model_mesh').run();

model.param.set('dt', '0.01');

model.sol('sol1').runAll();

[x0, y0, X0, Y0] = calculate_extracted_energy(model);

x1 = zeros(length(x0), length(borehole_spacing));
y1 = zeros(length(y0), length(borehole_spacing));
X1 = zeros(length(X0), length(borehole_spacing));
Y1 = zeros(length(Y0), length(borehole_spacing));

x2 = zeros(length(x0), length(borehole_spacing));
y2 = zeros(length(y0), length(borehole_spacing));
X2 = zeros(length(X0), length(borehole_spacing));
Y2 = zeros(length(Y0), length(borehole_spacing));

save('results2.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2');

for i = 1:length(borehole_spacing)
    
    model = init_two_well_model(borehole_spacing(i));
    
    model.param.set('h_borehole', '5[mm]');
    model.param.set('g_borehole', '1.2');
    model.param.set('g_rock', '1.1');
    model.param.set('n_swept', '200');
    model.param.set('g_bottom', '1.1');
    
    model.component('model_component').mesh('model_mesh').run();
    
    model.param.set('dt', '0.01');
    
    model.sol('sol1').runAll();
    
    [x1(:,i), y1(:,i), X1(:,i), Y1(:,i)] = calculate_extracted_energy(model);
    
    model = init_borehole_field_model(borehole_spacing(i));
    
    model.param.set('h_borehole', '5[mm]');
    model.param.set('g_borehole', '1.2');
    model.param.set('g_rock', '1.1');
    model.param.set('n_swept', '200');
    model.param.set('g_bottom', '1.1');
    
    model.component('model_component').mesh('model_mesh').run();
    
    model.param.set('dt', '0.01');
    
    model.sol('sol1').runAll();
    
    [x2(:,i), y2(:,i), X2(:,i), Y2(:,i)] = calculate_extracted_energy(model);
    
    save('results2.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2');
    
end

save('results2.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2');
