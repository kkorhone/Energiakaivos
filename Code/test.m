clc

close all
clear all

working_fluid = HeatCarrierFluid(0, 20);
coaxial_pipe = CoaxialPipe(50e-3, 32e-3, 0.1, 1900, 900);
borehole_diameter = 76e-3;
flow_rate = 0.6e-3;

% bhe_array = {};
% num_segments = 16;
% for i = 1:num_segments
%     azimuth = i * 360 / (num_segments - 1);
%     theta = azimuth * pi / 180;
%     p1 = [50*cos(theta), 50*sin(theta), -50];
%     p2 = [300*cos(theta), 300*sin(theta), -900];
%     bhe_array{end+1} = CoaxialBoreholeHeatExchanger(p1, p2, borehole_diameter, buffer_radius, working_fluid, coaxial_pipe);
% end
% plot_bhe_field(bhe_array)

bhe = CoaxialBoreholeHeatExchanger([0,0,0], [-100,300,-200], borehole_diameter, coaxial_pipe, flow_rate, working_fluid, 'bufferradius', 2);
plot_bhe_field({bhe});
% make_tensor_model(bhe);
