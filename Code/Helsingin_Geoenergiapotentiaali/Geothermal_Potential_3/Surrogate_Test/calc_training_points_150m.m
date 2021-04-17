clc

clear all
close all

num_train_points = 500;

data = load('map_point_samples.txt');

point_id = data(:, 1);
poly_id = data(:, 2);
x = data(:, 3);
y = data(:, 4);
k_rock = data(:, 5);
Cp_rock = data(:, 6);
rho_rock = data(:, 7);
T_surface = data(:, 8);
q_geothermal = data(:, 9);
E_borehole = 10 * rand(size(point_id));

train_point_indexes = [];

while length(train_point_indexes) < num_train_points
    num_indexes_left = num_train_points - length(train_point_indexes);
    random_indexes = randi(length(point_id), 1, num_indexes_left);
    train_point_indexes = [train_point_indexes, random_indexes];
    train_point_indexes = unique(train_point_indexes);
end

model = init_150m_model(20);

file_id = fopen('training_points_150m.txt', 'w');

counter = 0;

tic_start = tic;

for i = train_point_indexes
    
    t = tic;
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface(i)));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal(i)));
    
    T_wall_min = eval_min_temp(model, E_borehole(i));
    
    fprintf(file_id, '%3d %5d %3d %.2f %.0f %.0f %.3f %.3f %.3f %.3f\n', counter, point_id(i), poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E_borehole(i), T_wall_min);
    
    fprintf(1, 'counter=%d point_id=%d poly_id=%d k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E_borehole=%.3f T_wall_min=%.3f\n', counter, point_id(i), poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E_borehole(i), T_wall_min);
    fprintf(1, 'single_point=%.3fmin since_start=%.3fhrs\n', toc(t)/60, toc(tic_start)/3600);

    counter = counter + 1;

end

fclose(file_id);
