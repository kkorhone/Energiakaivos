k_rock = 2.66;
Cp_rock = 731;
rho_rock = 2906;
T_surface = 6.939;
q_geothermal = 40.786;

model = init_150m_model();

model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));

mphsave(model, 'example_model.mph');

% E = 4.000
% E = 5.016
% E = 6.000

data = load('mesh.txt');

x = data(:, 1);
y = data(:, 2);
z = data(:, 3);

for i = 0:length(x)/3-1
    plot3([x(3*i+1), x(3*i+2), x(3*i+3)], [y(3*i+1), y(3*i+2), y(3*i+3)], [z(3*i+1), z(3*i+2), z(3*i+3)], 'r-')
    if i == 0
        hold on
    end
end
hold off
