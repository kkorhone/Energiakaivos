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
params.T_discharging = 2;
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

% Simulation parameters.
params.t_simulation = 1e6;

% 8 25 89 136 337
%files = {'ico_field_136_300m.txt', ...
%         'ico_field_136_400m.txt', ...
%         'ico_field_136_500m.txt', ...
%         'ico_field_136_600m.txt'};

files = {'ico_field_136_400m.txt', ...
         'ico_field_136_500m.txt', ...
         'ico_field_136_600m.txt'};

for i = 1:length(files)
    for Q_discharging = [1e6, 2e6]
        
        params.buffer_width = 2000 - i * 100
        params.Q_discharging = Q_discharging
        
        file_name = files{i};
        base_name = file_name(1:end-4);
        
        model = init_quarter_symmetry_hemispherical_model(files{i}, params);
        
        mph_name = sprintf('%s_1Ma_%.0fMW.mph', base_name, params.Q_discharging/1e6);
        fprintf(1, '*** Saving model ''%s''... ', mph_name);
        mphsave(model, mph_name);
        fprintf(1, 'Done.\n');
        
        fprintf(1, '*** Meshing model ''%s''... ', mph_name);
        model.mesh('mesh').run();
        fprintf(1, 'Done.\n');
        
        mph_name = sprintf('%s_meshed_1Ma_%.0fMW.mph', base_name, params.Q_discharging/1e6);
        fprintf(1, '*** Saving model ''%s''... ', mph_name);
        mphsave(model, mph_name);
        fprintf(1, 'Done.\n');
        
        fprintf(1, '*** Solving model ''%s''... ', mph_name);
        model.sol('sol1').runAll();
        fprintf(1, 'Done.\n');
        
        mph_name = sprintf('%s_solved_1Ma_%.0fMW.mph', base_name, params.Q_discharging/1e6);
        fprintf(1, '*** Saving model ''%s''... ', mph_name);
        mphsave(model, mph_name);
        fprintf(1, 'Done.\n');
        
    end
end
