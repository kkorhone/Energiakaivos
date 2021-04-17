num_tests = 5;

% -------------------------------------------------------------------------
% 150-meter boreholes
% -------------------------------------------------------------------------

data = load('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Potential_3\\Neural_Network\\train_150m_20m_min.txt');

num_data = size(data, 1);

while 1
    random_indexes = unique(randi([1,num_data],1,num_tests));
    if length(random_indexes) == num_tests
        break
    end
end

model = init_150m_model(20);

for i = random_indexes

    k_rock = data(i, 4);
    Cp_rock = data(i, 5);
    rho_rock = data(i, 6);
    T_surface = data(i, 7);
    q_geothermal = data(i, 8);
    E_borehole = data(i, 9);
    
    fprintf(1, 'L_borehole=150 k_rock=%.3f Cp_rock=%.3f rho_rock=%.3f T_surface=%.3f q_geothermal=%.3f E_borehole=%.3f', k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole);
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
    
    T_min = eval_min_temp(model, E_borehole);
    
    fprintf(1, ' => T_min=%.3f\n', T_min);

end

% -------------------------------------------------------------------------
% 300-meter boreholes
% -------------------------------------------------------------------------

data = load('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Potential_3\\Neural_Network\\train_300m_20m_min.txt');

num_data = size(data, 1);

while 1
    random_indexes = unique(randi([1,num_data],1,num_tests));
    if length(random_indexes) == num_tests
        break
    end
end

model = init_300m_model(20);

for i = random_indexes

    k_rock = data(i, 4);
    Cp_rock = data(i, 5);
    rho_rock = data(i, 6);
    T_surface = data(i, 7);
    q_geothermal = data(i, 8);
    E_borehole = data(i, 9);
    
    fprintf(1, 'L_borehole=300 k_rock=%.3f Cp_rock=%.3f rho_rock=%.3f T_surface=%.3f q_geothermal=%.3f E_borehole=%.3f', k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole);
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
    
    T_min = eval_min_temp(model, E_borehole);
    
    fprintf(1, ' => T_min=%.3f\n', T_min);

end

% -------------------------------------------------------------------------
% 1000-meter boreholes
% -------------------------------------------------------------------------

data = load('E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Potential_3\\Neural_Network\\train_1000m_20m_min.txt');

num_data = size(data, 1);

while 1
    random_indexes = unique(randi([1,num_data],1,num_tests));
    if length(random_indexes) == num_tests
        break
    end
end

model = init_1000m_model(20);

for i = random_indexes

    k_rock = data(i, 4);
    Cp_rock = data(i, 5);
    rho_rock = data(i, 6);
    T_surface = data(i, 7);
    q_geothermal = data(i, 8);
    E_borehole = data(i, 9);
    
    fprintf(1, 'L_borehole=1000 k_rock=%.3f Cp_rock=%.3f rho_rock=%.3f T_surface=%.3f q_geothermal=%.3f E_borehole=%.3f', k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole);
    
    model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
    model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
    model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
    model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
    model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
    
    T_min = eval_min_temp(model, E_borehole);
    
    fprintf(1, ' => T_min=%.3f\n', T_min);

end
