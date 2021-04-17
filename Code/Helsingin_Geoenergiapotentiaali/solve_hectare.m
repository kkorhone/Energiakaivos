% -------------------------------------------------------------------------
% Cleans up.
% -------------------------------------------------------------------------

%clc;

clear all;
close all;

% -------------------------------------------------------------------------
% Sets up global variables.
% -------------------------------------------------------------------------

global model;

% -------------------------------------------------------------------------
% Sets up model.
% -------------------------------------------------------------------------

monthly_profile = [0.175414, 0.107229, 0.111884, 0.082876, 0.044846, 0.037201, 0.032188, 0.034649, 0.044508, 0.086641, 0.119199, 0.123365];

model = init_full_hectare(20, monthly_profile);

% -------------------------------------------------------------------------
% Sets up optimization.
% -------------------------------------------------------------------------

opts = optimset('display', 'iter', 'tolfun', 0.01, 'tolx', 0.01);
%opts = optimset('outputfcn', @output_hectare, 'display', 'iter');
%opts = optimset(opts, 'algorithm', 'levenberg-marquardt');
%opts = optimset(opts, 'maxfunevals', 1000000);
%opts = optimset(opts, 'maxiter', 1000000);
%opts = optimset(opts, 'tolfun', 0.001);
%opts = optimset(opts, 'tolx', 0.001);

%com.comsol.model.util.ModelUtil.showProgress(true);

% -------------------------------------------------------------------------
% Runs optimization.
% -------------------------------------------------------------------------

x = fminsearch(@eval_hectare, 1, opts)
