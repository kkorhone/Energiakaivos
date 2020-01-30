function model = init_slice_model(borehole_tilts, slice_width, num_slices, varargin)

% =========================================================================
% Handles the input parameters.
% =========================================================================

if any(borehole_tilts < -90) || any(borehole_tilts > 0)
    error('Borehole tilts must be between -90 and 0.');
end

if length(varargin)/2 ~= floor(length(varargin)/2)
    error('Invalid number of named arguments.');
end

borehole_tilts = sort(unique(borehole_tilts), 'ascend');

if borehole_tilts(1) > -90
    warning('Vertical borehole missing.');
end

L_borehole = 300;
d_borehole = 76e-3;
d_outer = 50e-3;
d_inner = 32e-3;
buffer_width = 400;
borehole_offset = 10;
r_buffer = 0.5;
T_inlet = 6;

for i = 1:length(varargin)/2
    if strcmp(varargin{(i-1)*2+1}, 'L_borehole')
        L_borehole = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'd_borehole')
        d_borehole = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'd_outer')
        d_outer = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'd_inner')
        d_inner = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'borehole_offset')
        borehole_offset = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'r_buffer')
        r_buffer = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'buffer_width')
        buffer_width = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'T_inlet')
        T_inlet = varargin{(i-1)*2+2};
    else
        error('Unrecognized named argument: ''%s''.', string(varargin{(i-1)*2+1}));
    end
end

if d_borehole <= 0
    error('Borehole diameter must be positive.');
end

if d_borehole < 76e-3 || d_borehole > 200e-3
    warning('Borehole diameter should be 76 <= d_borehole <= 200');
end

if d_outer >= d_borehole
    warning('Outer pipe wall diameter must be <= %.0f mm.', d_borehole);
end

if d_inner >= d_outer
    warning('Inner pipe wall diameter must be <= %.0f mm.', d_outer);
end

if d_inner == 0
    warning('Inner pipe wall diameter can not be 0 mm.');
end

if L_borehole <= 0
    error('Borehole length must be positive.');
end

if L_borehole < 50 || L_borehole > 2000
    warning('Borehole length should be 50 <= L_borehole <= 2000.');
end

if length(T_inlet) ~= 1 && length(T_inlet) ~= 12
    error('Inlet temperature must be scalar or vector with 12 elements.');
end

if any(T_inlet < 6) || any(T_inlet > 100)
    warning('Inlet temperature should be 6 <= T_inlet <= 100.');
end

if r_buffer < 0
    error('Borehole buffer radius must be positive.');
end

if r_buffer < 0.1 || r_buffer > 1.0
    warning('Borehole buffer radius should be 0.1 <= r_buffer <= 1.0.');
end

if buffer_width <= 0
    error('Buffer zone width width must be positive.');
end

if buffer_width < 100 || buffer_width > 1000
    warning('Buffer zone width width should be 100 <= buffer_width <= 1000.');
end

% =========================================================================
% Prints out a summary of the input parameters.
% =========================================================================

fprintf(1, '==================================================\n');

for i = 1:length(borehole_tilts)
    fprintf(1, 'init_slice_model: Borehole #%d (tilt = %f deg).\n', i, borehole_tilts(i));
end

fprintf(1, 'init_slice_model: slice_width = %f m.\n', slice_width);
fprintf(1, 'init_slice_model: num_slices = %f deg.\n', num_slices);
fprintf(1, 'init_slice_model: d_borehole = %f mm.\n', d_borehole*1e3);
fprintf(1, 'init_slice_model: d_outer = %f mm.\n', d_outer*1e3);
fprintf(1, 'init_slice_model: d_inner = %f mm.\n', d_inner*1e3);
fprintf(1, 'init_slice_model: L_borehole = %f m.\n', L_borehole);
fprintf(1, 'init_slice_model: borehole_offset = %f m.\n', borehole_offset);
fprintf(1, 'init_slice_model: r_buffer = %f m.\n', r_buffer);
fprintf(1, 'init_slice_model: buffer_width = %f m.\n', buffer_width);

if length(T_inlet) == 1
    fprintf(1, 'init_slice_model: T_inlet = %f degC.\n', T_inlet);
else
    for i = 1:12
        fprintf(1, 'init_slice_model: T_inlet(%d) = %f degC.\n', i, T_inlet(i));
    end
end

fprintf(1, '==================================================\n');

% =========================================================================
% Imports the required Java packages.
% =========================================================================

import com.comsol.model.*
import com.comsol.model.util.*

% =========================================================================
% Creates a new model.
% =========================================================================

fprintf(1, 'init_slice_model: Creating new model... ');

model = ModelUtil.create('Fan Model 3D');

model.label('fan_model_3d');

component = model.component.create('component', true);

geometry = component.geom.create('geometry', 3);

mesh = component.mesh.create('mesh');

fprintf(1, 'Done.\n');

% =========================================================================

model.param.set('q_geothermal', '40[mW/m^2]');
model.param.set('T_surface', '2.3[degC]');
model.param.set('T_inlet', '6[degC]');
model.param.set('k_rock', '3[W/(m*K)]');
model.param.set('Cp_rock', '750[J/(kg*K)]');
model.param.set('rho_rock', '2700[kg/m^3]');

func = model.func.create('initial_temperature_function', 'Analytic');
func.label('Initial Temperature Function');
func.set('funcname', 'T_initial');
func.set('expr', 'T_surface-q_geothermal/k_rock*z');
func.set('args', {'z'});
func.set('argunit', 'm');
func.set('fununit', 'K');

heatCarrierFluid = HeatCarrierFluid(0, 10, 0.6/1000)
coaxialPipe = CoaxialPipe(50e-3, 32e-3, 0.1, 1900, 900)

cbheArray = { CoaxialBoreholeHeatExchanger([0 0 0], -90, 0, 76e-3, 300, 20, 0.5, heatCarrierFluid, coaxialPipe); };
cbheArray{1}
xxx
% make_tensor_model(cbheArray{1});

for i = 1:length(cbheArray)
    cbheArray{i}.createGeometry(geometry);
end

geometry.create('blk1', 'Block');
geometry.feature('blk1').set('pos', [-150 -150 -500]);
geometry.feature('blk1').set('size', [300 300 500]);

geometry.run('fin');

% Creates CBHE selections.

for i = 1:length(cbheArray)
    cbheArray{i}.createSelections(geometry);
end

geometry.run('fin');

for i = 1:length(cbheArray)
    cbheArray{i}.createMesh(mesh);
end

physics = component.physics.create('physics', 'HeatTransfer', geometry.tag);
physics.prop('ShapeProperty').set('order_temperature', 1);
physics.field('temperature').field('T');
physics.identifier('physics');
physics.name('physics');
physics.label('Heat Transfer');

physics.feature('init1').set('Tinit', 'T_initial(z)');
physics.feature('init1').label('Initial Values');

physics.feature('solid1').set('k_mat', 'userdef');
physics.feature('solid1').set('k', {'3'; '0'; '0'; '0'; '3'; '0'; '0'; '0'; '3'});
physics.feature('solid1').label('Bedrock Physics');

physics.feature('solid1').set('rho_mat', 'userdef');
physics.feature('solid1').set('rho', 2700);

physics.feature('solid1').set('Cp_mat', 'userdef');
physics.feature('solid1').set('Cp', 730);

for i = 1:length(cbheArray)
    cbheArray{i}.createPhysics(physics);
end

model.component('component').physics('physics').create('temp1', 'TemperatureBoundary', 2);
model.component('component').physics('physics').feature('temp1').selection.set([4]);
model.component('component').physics('physics').create('hf1', 'HeatFluxBoundary', 2);
model.component('component').physics('physics').feature('hf1').selection.set([3]);
model.component('component').physics('physics').feature('temp1').set('T0', 'T_surface');
model.component('component').physics('physics').feature('temp1').label('Temperature 1');
model.component('component').physics('physics').feature('hf1').set('q0', 'q_geothermal');

for i = 1:length(cbheArray)
    cbheArray{i}.createBoundaryConditions(physics, 'T_inlet');
end

for i = 1:length(cbheArray)
    cbheArray{i}.createOperators(component, geometry);
end

variables = component.variable.create('component_variables');

for i = 1:length(cbheArray)
    cbheArray{i}.createVariables(variables, physics);
end

return

% =========================================================================
% Creates events (if inlet temperature is not scalar)
% =========================================================================

fprintf(1, 'init_slice_model: Creating events... ');

month_names = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August','September', 'October', 'November', 'December'};

if length(T_inlet) == 12

    events = component.physics.create('ev', 'Events', 'geometry');
    
    for i = 1:12
    
        event = events.create(sprintf('explicit_event%d',i), 'ExplicitEvent', -1);
        event.set('start', sprintf('(%d/12)[a]', i-1));
        event.set('period', '1[a]');
        event.label(sprintf('%s Event', month_names{i}));
        
    end
    
end

return

% =========================================================================
% Creates study and solution
% =========================================================================

fprintf(1, 'init_slice_model: Creating study and solution... ');

model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').feature('t1').feature.remove('dDef');

model.study('std1').setGenPlots(false);
model.study('std1').feature('time').set('tunit', 'a');
model.study('std1').feature('time').set('tlist', '0 100');
model.study('std1').feature('time').set('usertol', true);
model.study('std1').feature('time').set('rtol', '1e-2');

if length(T_inlet) == 12
    model.study('std1').feature('time').activate('ev', true);
end

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clist', {'0 100' '1e-6[a]'});
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', '0 100');
model.sol('sol1').feature('t1').set('rtol', '1e-2');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').set('plot', true);
model.sol('sol1').feature('t1').set('tout', 'tsteps');
model.sol('sol1').feature('t1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol1').feature('t1').feature('fc1').set('damp', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
model.sol('sol1').feature('t1').feature('fc1').set('aaccdim', 5);
model.sol('sol1').feature('t1').feature('fc1').set('aaccmix', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('aaccdelay', 1);
model.sol('sol1').feature('t1').feature('d1').label('Direct, Heat Transfer Variables (physics)');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tout', 'tsteps');
model.sol('sol1').feature('t1').set('initialstepbdfactive', true);
model.sol('sol1').feature('t1').set('initialstepbdf', '1e-6');

% model.sol('sol1').runAll;

fprintf(1, 'Done.\n');

% =========================================================================
% Creates results
% =========================================================================

fprintf(1, 'init_slice_model: Creating results... ');

% -------------------------------------------------------------------------
% Individual heat rates
% -------------------------------------------------------------------------

plot_group = model.result.create('plot_group1', 'PlotGroup1D');
plot_group.label('Individual heat rates');
plot_group.set('xlabel', 'Time [a]');
plot_group.set('xlabelactive', false);
plot_group.set('ylabel', 'Heat rate through single borehole wall [W]');
plot_group.set('ylabelactive', false);
plot_group.set('titletype', 'manual');
plot_group.set('title', 'Individual heat rates');

global_plot = plot_group.create(sprintf('global_plot%d',i), 'Global');
global_plot.set('expr', compose('Q_wall%d', 1:length(borehole_tilt)));
global_plot.set('unit', repelem({'kW'},1,length(borehole_tilt)));
global_plot.set('descr', compose('Borehole #%d', 1:length(borehole_tilt)));

% -------------------------------------------------------------------------
% Total heat rate
% -------------------------------------------------------------------------

plot_group = model.result.create('plot_group2', 'PlotGroup1D');
plot_group.label('Total heat rate');
plot_group.set('xlabel', 'Time [a]');
plot_group.set('xlabelactive', false);
plot_group.set('ylabel', 'Total heat rate through all borehole walls [W]');
plot_group.set('ylabelactive', false);
plot_group.set('titletype', 'manual');
plot_group.set('title', 'Total heat rate');

global_plot = plot_group.create(sprintf('global_plot%d',i), 'Global');
global_plot.set('expr', 'Q_walls');
global_plot.set('unit', 'kW');
global_plot.set('descr', 'Total heat rate');

% -------------------------------------------------------------------------
% Fluid temperatures
% -------------------------------------------------------------------------

line_colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'gray'};

plot_group = model.result.create('plot_group3', 'PlotGroup1D');
plot_group.label('Fluid temperatures');
plot_group.set('titletype', 'manual');
plot_group.set('title', 'Fluid temperatures');

for i = 1:length(borehole_tilt)

    line_graph = plot_group.create(sprintf('inner_line%d',i), 'LineGraph');
    line_graph.selection.named(sprintf('geometry_inner_edge_selection%d', i));
    line_graph.set('expr', sprintf('-sqrt((x-nx%d*borehole_offset)^2+(z-nz%d*borehole_offset)^2)', i, i));
    line_graph.set('xdata', 'expr');
    line_graph.set('xdataunit', 'degC');
    line_graph.set('linecolor', line_colors{mod(i,length(line_colors))+1});
    line_graph.set('resolution', 'normal');

    line_graph = plot_group.create(sprintf('outer_line%d',i), 'LineGraph');
    line_graph.selection.named(sprintf('geometry_outer_edge_selection%d', i));
    line_graph.set('expr', sprintf('-sqrt((x-nx%d*borehole_offset)^2+(z-nz%d*borehole_offset)^2)', i, i));
    line_graph.set('xdata', 'expr');
    line_graph.set('xdataunit', 'degC');
    line_graph.set('linecolor', line_colors{mod(i,length(line_colors))+1});
    line_graph.set('resolution', 'normal');

end

% plot_group.set('looplevelinput', {'last'});
plot_group.set('xlabel', 'Temperature [degC]');
plot_group.set('ylabel', 'Distance along borehole axis [m]');
plot_group.set('showlegends', false);
plot_group.set('xlabelactive', false);
plot_group.set('ylabelactive', false);

% -------------------------------------------------------------------------
% Inlet and outlet temperatures
% -------------------------------------------------------------------------

plot_group = model.result.create('plot_group4', 'PlotGroup1D');
plot_group.label('Inlet and outlet temperatures');
plot_group.set('xlabel', 'Time [a]');
plot_group.set('ylabel', 'Temperature [degC]');
plot_group.set('xlabelactive', false);
plot_group.set('ylabelactive', false);

global_plot1 = plot_group.create('global_plot1', 'Global');
global_plot2 = plot_group.create('global_plot2', 'Global');

if length(T_inlet) == 1
    global_plot1.set('expr', {'T_inlet'});
else
    global_plot1.set('expr', {'T_inlet(t)'});
end

global_plot1.set('descr', {'Inlet Temperature'});
global_plot1.set('unit', {'degC'});
global_plot1.set('linemarker', 'point');
global_plot1.set('markerpos', 'datapoints');

global_plot2.set('expr', compose('T_outlet%d', 1:length(borehole_tilt)));
global_plot2.set('unit', repelem({'degC'},1,length(borehole_tilt)));
global_plot2.set('descr', compose('Borehole #%d', 1:length(borehole_tilt)));
global_plot2.set('linemarker', 'point');
global_plot2.set('markerpos', 'datapoints');

% -------------------------------------------------------------------------
% Cut plane
% -------------------------------------------------------------------------

cut_plane = model.result.dataset.create('cut_plane', 'CutPlane');
cut_plane.set('quickplane', 'xz');

plot_group = model.result.create('plot_group5', 'PlotGroup2D');

surface = plot_group.create('surface', 'Surface');
surface.set('unit', 'degC');
surface.set('resolution', 'normal');

contour = plot_group.create('contour', 'Contour');
contour.set('expr', 'T-T_initial(z-tunnel_depth)');
contour.set('levelmethod', 'levels');
contour.set('levels', '-0.1 -0.01 -0.001');
contour.set('coloring', 'uniform');
contour.set('color', 'black');
contour.set('resolution', 'normal');

fprintf(1, 'Done.\n');

% =========================================================================
% Makes tensor models
% =========================================================================

% make_tensor_models(model);

fprintf(1, 'init_slice_model: Completed.\n');
