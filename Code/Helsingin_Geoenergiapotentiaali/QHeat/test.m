borehole_spacing = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200 250 300 350 400 450 500];

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

for i = 1:length(borehole_spacing)
    
    model = init_two_well_model(borehole_spacing(i));

    model.sol('sol1').runAll();

    [x1(:,i), y1(:,i), X1(:,i), Y1(:,i)] = calculate_extracted_energy(model);

    model = init_borehole_field_model(borehole_spacing(i));

    model.sol('sol1').runAll();

    [x2(:,i), y2(:,i), X2(:,i), Y2(:,i)] = calculate_extracted_energy(model);

end

save('results.mat', 'x0', 'y0', 'X0', 'Y0', 'x1', 'y1', 'X1', 'Y1', 'x2', 'y2', 'X2', 'Y2');

fid = fopen('results_annual.txt', 'w');

if fid == -1
    error('Failed to open file for writing results.');
end

for i = 1:length(x0)
    fprintf(fid, '%.6f %.6f ', x0(i), y0(i));
    for j = 1:size(y1, 2)
        fprintf(fid, '%.6f ', y1(i, j));
    end
    for j = 1:size(y2, 2)
        fprintf(fid, '%.6f ', y2(i, j));
    end
    fprintf(fid, '\n');
end

fclose(fid);

fid = fopen('results_cumulative.txt', 'w');

if fid == -1
    error('Failed to open file for writing results.');
end

for i = 1:length(X0)
    fprintf(fid, '%.6f %.6f ', X0(i), Y0(i));
    for j = 1:size(Y1, 2)
        fprintf(fid, '%.6f ', Y1(i, j));
    end
    for j = 1:size(Y2, 2)
        fprintf(fid, '%.6f ', Y2(i, j));
    end
    fprintf(fid, '\n');
end

fclose(fid);
