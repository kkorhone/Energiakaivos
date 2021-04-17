clc

clear all
close all

num_train_points = 100;
num_test_points = 50;

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

k_unique = unique(k_rock);
Cp_unique = unique(Cp_rock);
rho_unique = unique(rho_rock);

num_train_category = 6;
num_test_category = 3;

train_indexes = [];
chosen_indexes = [];
for i = 1:length(k_unique)
    j = find(k_rock==k_unique(i));
    k = choose_from_indexes(j, num_train_category, chosen_indexes);
    train_indexes = [train_indexes, k];
    chosen_indexes = [chosen_indexes, k];
end
for i = 1:length(Cp_unique)
    j = find(Cp_rock==Cp_unique(i));
    k = choose_from_indexes(j, num_train_category, chosen_indexes);
    train_indexes = [train_indexes, k];
    chosen_indexes = [chosen_indexes, k];
end
for i = 1:length(rho_unique)
    j = find(rho_rock==rho_unique(i));
    k = choose_from_indexes(j, num_train_category, chosen_indexes);
    train_indexes = [train_indexes, k];
    chosen_indexes = [chosen_indexes, k];
end
test_indexes = [];
for i = 1:length(k_unique)
    j = find(k_rock==k_unique(i));
    k = choose_from_indexes(j, num_test_category, chosen_indexes);
    test_indexes = [test_indexes, k];
    chosen_indexes = [chosen_indexes, k];
end
for i = 1:length(Cp_unique)
    j = find(Cp_rock==Cp_unique(i));
    k = choose_from_indexes(j, num_test_category, chosen_indexes);
    test_indexes = [test_indexes, k];
    chosen_indexes = [chosen_indexes, k];
end
for i = 1:length(rho_unique)
    j = find(rho_rock==rho_unique(i));
    k = choose_from_indexes(j, num_test_category, chosen_indexes);
    test_indexes = [test_indexes, k];
    chosen_indexes = [chosen_indexes, k];
end

fprintf(1, '%s\n', num2str([length(train_indexes), length(unique(train_indexes))]));
fprintf(1, '%s\n', num2str([length(test_indexes), length(unique(test_indexes))]));

figure()
subplot(231); histogram(k_rock, 2.6:0.025:3.5, 'normalization', 'probability'); hold on; histogram(k_rock(train_indexes), 2.6:0.025:3.5, 'normalization', 'probability'); hold off
subplot(232); histogram(Cp_rock, 710:734, 'normalization', 'probability'); hold on; histogram(Cp_rock(train_indexes), 710:734, 'normalization', 'probability'); hold off
subplot(233); histogram(rho_rock, 2600:50:2950, 'normalization', 'probability'); hold on; histogram(rho_rock(train_indexes), 2600:50:2950, 'normalization', 'probability'); hold off
subplot(234); histogram(T_surface, 6.6:0.05:7.2, 'normalization', 'probability'); hold on; histogram(T_surface(train_indexes), 6.6:0.05:7.2, 'normalization', 'probability'); hold off
subplot(235); histogram(q_geothermal, 40.5:0.25:42.5, 'normalization', 'probability'); hold on; histogram(q_geothermal(train_indexes), 40.5:0.25:42.5, 'normalization', 'probability'); hold off
subplot(236); plot(x, y, 'b.'); hold on; plot(x(train_indexes), y(train_indexes), 'r.'); hold off; axis equal

figure()
subplot(231); histogram(k_rock, 2.6:0.025:3.5, 'normalization', 'probability'); hold on; histogram(k_rock(test_indexes), 2.6:0.025:3.5, 'normalization', 'probability'); hold off
subplot(232); histogram(Cp_rock, 710:734, 'normalization', 'probability'); hold on; histogram(Cp_rock(test_indexes), 710:734, 'normalization', 'probability'); hold off
subplot(233); histogram(rho_rock, 2600:50:2950, 'normalization', 'probability'); hold on; histogram(rho_rock(test_indexes), 2600:50:2950, 'normalization', 'probability'); hold off
subplot(234); histogram(T_surface, 6.6:0.05:7.2, 'normalization', 'probability'); hold on; histogram(T_surface(test_indexes), 6.6:0.05:7.2, 'normalization', 'probability'); hold off
subplot(235); histogram(q_geothermal, 40.5:0.25:42.5, 'normalization', 'probability'); hold on; histogram(q_geothermal(test_indexes), 40.5:0.25:42.5, 'normalization', 'probability'); hold off
subplot(236); plot(x, y, 'b.'); hold on; plot(x(test_indexes), y(test_indexes), 'r.'); hold off; axis equal

figure()
plot(x, y, 'b.'); hold on; plot(x(train_indexes), y(train_indexes), 'r.'); plot(x(test_indexes), y(test_indexes), 'g.'); hold off; title(sprintf('%d training points and %d test points',length(train_indexes),length(test_indexes)));

for i = 1:length(test_indexes)
    dx = x(test_indexes(i)) - x(train_indexes);
    dy = y(test_indexes(i)) - y(train_indexes);
    dist = sqrt(dx.^2 + dy.^2);
    assert(min(dist)>=100, 'Minimum distance too small between points.')
end

assert(length(train_indexes)==length(unique(train_indexes)), 'Failed to create training point indexes.')
assert(length(test_indexes)==length(unique(test_indexes)), 'Failed to create test point indexes.')

reply = input('Continue? ', 's');
if isempty(reply)
    reply = 'y';
end

if (reply=='n') || (reply=='N')
    return
elseif (reply~='y') && (reply~='Y')
    error('Unexpected reply ''%s''.', reply);
end

model = init_300m_model();

options = optimset('display', 'iter', 'tolx', 0.1);

counter = 0;

file_id = fopen('train_300m_20m_min.txt', 'w');

tic_start = tic;

for i = train_indexes
    
    t = tic;
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface(i)));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal(i)));
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    [E, func_value, exit_flag] = fminbnd(obj_func, 7, 11, options);
    
    if exit_flag <= 0
        E = nan;
    end

    counter = counter + 1;
    
    fprintf(file_id, '%3d %5d %3d %.2f %.0f %.0f %.3f %.3f %.3f\n', counter, point_id(i), poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    
    fprintf(1, 'counter=%d point_id=%d poly_id=%d k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E=%.3f\n', counter, point_id(i), poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    fprintf(1, 'single_poly=%.3fmin since_start=%.3fhrs\n', toc(t)/60, toc(tic_start)/3600);
    
end

fclose(file_id);

counter = 0;

file_id = fopen('test_300m_20m_min.txt', 'w');

for i = test_indexes
    
    t = tic;
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock(i)));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock(i)));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock(i)));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface(i)));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal(i)));
    
    obj_func = @(x) abs(eval_min_temp(model, x));
    
    [E, func_value, exit_flag] = fminbnd(obj_func, 7, 11, options);
    
    if exit_flag <= 0
        E = nan;
    end

    counter = counter + 1;
    
    fprintf(file_id, '%3d %5d %3d %.2f %.0f %.0f %.3f %.3f %.3f\n', counter, point_id(i), poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    
    fprintf(1, 'counter=%d point_id=%d poly_id=%d k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E=%.3f\n', counter, point_id(i), poly_id(i), k_rock(i), Cp_rock(i), rho_rock(i), T_surface(i), q_geothermal(i), E);
    fprintf(1, 'single_poly=%.3fmin since_start=%.3fhrs\n', toc(t)/60, toc(tic_start)/3600);
    
end

fclose(file_id);
