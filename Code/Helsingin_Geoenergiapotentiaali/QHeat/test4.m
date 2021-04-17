borehole_spacing = [10, 21, 31, 41, 50, 64, 71, 81, 90, 100, 122, 140, 160, 182, 200, 249, 298, 345, 400, 450, 500];
borehole_spacing = [200, 249, 298, 345, 400, 450, 500];

for i = 1:length(borehole_spacing)
    model = init_two_well_model(borehole_spacing(i));
    model = init_borehole_field_model(borehole_spacing(i));
end

return

com.comsol.model.util.ModelUtil.showProgress(true);

model = init_single_well_model();

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

save('results3.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2', 'borehole_spacing');

for i = 1:length(borehole_spacing)
    
    model = init_two_well_model(borehole_spacing(i));
    
    model.sol('sol1').runAll();
    
    [x1(:,i), y1(:,i), X1(:,i), Y1(:,i)] = calculate_extracted_energy(model);
    
    model = init_borehole_field_model(borehole_spacing(i));
    
    model.sol('sol1').runAll();
    
    [x2(:,i), y2(:,i), X2(:,i), Y2(:,i)] = calculate_extracted_energy(model);
    
    save('results3.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2', 'borehole_spacing');
    
end

save('results3.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2', 'borehole_spacing');
