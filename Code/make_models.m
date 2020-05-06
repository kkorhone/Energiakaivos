clc

clear all
close all

import com.comsol.model.util.*

ModelUtil.showProgress(true);

% Bedrock parameters.
params.T_surface = 3;
params.q_geothermal = 38e-3;
params.k_rock = 2.92;
params.Cp_rock = 682;
params.rho_rock = 2794;

% Borehole field exchanger parameters.
params.T_inlet = 2;
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
params.T_fluid = 10;

% Model parameters.
params.r_buffer = 1.0;
params.buffer_width = 2000;

% Simulation parameters.
params.t_simulation = 1e6;

% 8 25 89 136 337
files = {'ico_field_8_300m.txt', ...
    'ico_field_25_300m.txt', ...
    'ico_field_89_300m.txt', ...
    'ico_field_136_300m.txt', ...
    'ico_field_337_300m.txt'};

for i = 1:length(files)
    
    file_name = files{i};
    base_name = file_name(1:end-4);
    
    model = init_quarter_symmetry_hemispherical_model(files{i}, params);
    
    mph_name = sprintf('%s_1Ma.mph', base_name);
    fprintf(1, '*** Saving model ''%s''... ', mph_name);
    mphsave(model, mph_name);
    fprintf(1, 'Done.\n');
    
    fprintf(1, '*** Meshing model ''%s''... ', mph_name);
    model.mesh('mesh').run();
    fprintf(1, 'Done.\n');
    
    mph_name = sprintf('%s_meshed_1Ma.mph', base_name);
    fprintf(1, '*** Saving model ''%s''... ', mph_name);
    mphsave(model, mph_name);
    fprintf(1, 'Done.\n');
    
    fprintf(1, '*** Solving model ''%s''... ', mph_name);
    model.sol('sol1').runAll();
    fprintf(1, 'Done.\n');
    
    mph_name = sprintf('%s_solved_1Ma.mph', base_name);
    fprintf(1, '*** Saving model ''%s''... ', mph_name);
    mphsave(model, mph_name);
    fprintf(1, 'Done.\n');
    
    si = mphsolinfo(model);
    t = si.solvals/(365.2425*24*3600);
    Q_total = mphglobal(model, 'Q_total', 'unit', 'W');
    Q_above = mphglobal(model, 'Q_above', 'unit', 'W');
    Q_below = mphglobal(model, 'Q_below', 'unit', 'W');
    T_field = mphglobal(model, 'T_field', 'unit', 'degC');
    V_field = mphglobal(model, 'V_field', 'unit', 'degC', 'solnum', 'end');
    T_outlet = mphglobal(model, 'T_outlet', 'unit', 'degC');
    
end
