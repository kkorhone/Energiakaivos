clc

clear all
close all

addpath E:\Work\Energiakaivos\Code

import com.comsol.model.util.*

ModelUtil.showProgress(true);

% Bedrock parameters.
params.T_surface = 3;
params.q_geothermal = 38e-3;
params.k_rock = 2.92;
params.Cp_rock = 682;
params.rho_rock = 2794;

% Borehole field exchanger parameters.
params.Q_discharging = 2e6;
params.d_borehole = 76e-3;
params.flow_rate = 0.6e-3;

% Pipe parameters.
params.d_outer = 50e-3;
params.d_inner = 38e-3;
params.k_pipe = 0.1;
params.Cp_pipe = 1900;
params.rho_pipe = 410;

% Fluid parameters.
params.c_fluid = 0;
params.T_fluid = 20;

% Model parameters.
params.r_buffer = 1.0;
params.buffer_width = 400;

model = init_quarter_symmetry_hemispherical_stress('ico_field_136_600m.txt', params);

mphsave(model, 'stress_600m.mph');

model.mesh('mesh').run();

mphsave(model, 'stress_600m_meshed.mph');

% model.sol('sol1').runAll();
% 
% mphsave(model, 'stress_600m_solved.mph');
