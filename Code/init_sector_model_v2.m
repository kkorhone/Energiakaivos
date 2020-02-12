function model = init_sector_model_v2(borehole_tilt, sector_angle, varargin)

% =========================================================================
% Checks input parameters
% =========================================================================

if any(borehole_tilt < -90) || any(borehole_tilt > 0)
    error('Borehole tilt must be -90 <= borehole_tilt <= 0.');
end

if sector_angle <= 0 || sector_angle >= 360
    error('Sector angle must be 0 < sector_angle < 360.');
end

if 360/sector_angle ~= floor(360/sector_angle)
    error('Invalid sector angle.');
end

if length(varargin)/2 ~= floor(length(varargin)/2)
    error('Invalid number of named arguments.');
end

borehole_tilt = sort(unique(borehole_tilt), 'ascend');

if borehole_tilt(1) > -90
    warning('Vertical borehole missing.');
end

L_borehole = 300;
d_borehole = 76;
buffer_width = 400;
borehole_offset = 10;
r_buffer = 0.5;
T_inlet = 6;

for i = 1:length(varargin)/2
    if strcmp(varargin{(i-1)*2+1}, 'L_borehole')
        L_borehole = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'd_borehole')
        d_borehole = varargin{(i-1)*2+2};
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

if d_borehole < 76 || d_borehole > 200
    warning('Borehole diameter should be 76 <= d_borehole <= 200');
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

fprintf(1, '==================================================\n');

for i = 1:length(borehole_tilt)
    fprintf(1, 'init_model: Borehole #%d (tilt = %f deg).\n', i, borehole_tilt(i));
end

fprintf(1, 'init_model: sector_angle = %f deg.\n', sector_angle);
fprintf(1, 'init_model: d_borehole = %f mm.\n', d_borehole);
fprintf(1, 'init_model: L_borehole = %f m.\n', L_borehole);
fprintf(1, 'init_model: borehole_offset = %f m.\n', borehole_offset);
fprintf(1, 'init_model: r_buffer = %f m.\n', r_buffer);
fprintf(1, 'init_model: buffer_width = %f m.\n', buffer_width);

if length(T_inlet) == 1
    fprintf(1, 'init_model: T_inlet = %f degC.\n', T_inlet);
else
    for i = 1:12
        fprintf(1, 'init_model: T_inlet(%d) = %f degC.\n', i, T_inlet(i));
    end
end

fprintf(1, '==================================================\n');

% =========================================================================
% Imports Java packages
% =========================================================================

import com.comsol.model.*
import com.comsol.model.util.*

% =========================================================================
% Creates new model
% =========================================================================

fprintf(1, 'init_model: Creating new model... ');

model = ModelUtil.create('Sector Model 3D');

model.label('sector_model_3d');

component = model.component.create('component', true);

geometry = component.geom.create('geometry', 3);

mesh = component.mesh.create('mesh');

fprintf(1, 'Done.\n');

% =========================================================================
% Sets up parameters
% =========================================================================

fprintf(1, 'init_model: Setting up parameters... ');

% -------------------------------------------------------------------------
% Sets up model parameters
% -------------------------------------------------------------------------

parameters = model.param('default');
parameters.label('General Parameters');
parameters.set('sector_angle', sprintf('%.6f[deg]', sector_angle));
parameters.set('num_sectors', '360[deg]/sector_angle');
parameters.set('tunnel_depth', '1450[m]');
parameters.set('q_geothermal', '40[mW/m^2]');
parameters.set('T_surface', '2.3[degC]');
parameters.set('k_large', '1000[W/(m*K)]');
parameters.set('buffer_width', sprintf('%f[m]', buffer_width));
parameters.set('r_buffer', sprintf('%f[m]', r_buffer));
parameters.set('borehole_offset', sprintf('%f[m]', borehole_offset));

if length(T_inlet) == 1
    parameters.set('T_inlet', sprintf('%f[degC]', T_inlet));
end

% -------------------------------------------------------------------------
% Sets up borehole parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('borehole_parameters');
parameters.label('Borehole Parameters');
parameters.set('L_borehole', sprintf('%f[m]', L_borehole));
parameters.set('d_borehole', sprintf('%f[mm]', d_borehole));
parameters.set('r_borehole', 'd_borehole/2');

% -------------------------------------------------------------------------
% Sets up bedrock parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('bedrock_parameters');
parameters.label('Bedrock parameters');
parameters.set('k_rock', '3[W/(m*K)]');
parameters.set('Cp_rock', '750[J/(kg*K)]');
parameters.set('rho_rock', '2700[kg/m^3]');

% -------------------------------------------------------------------------
% Sets up pipe parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('pipe_parameters');
parameters.label('Pipe Parameters');
parameters.set('d_outer', '50[mm]');
parameters.set('d_inner', '32[mm]');
parameters.set('r_outer', 'd_outer/2');
parameters.set('r_inner', 'd_inner/2');
parameters.set('A_outer', 'pi*r_borehole^2-pi*r_outer^2');
parameters.set('A_inner', 'pi*r_inner^2');
parameters.set('A_hdpe', '0.0006056[m^2]');
parameters.set('A_air', '0.00082697[m^2]');
parameters.set('rho_hdpe', '960[kg/m^3]');
parameters.set('Cp_hdpe', '1900[J/(kg*K)]');
parameters.set('rho_air', '1.2[kg/m^3]');
parameters.set('Cp_air', '1005[J/(kg*K)]');
parameters.set('k_pipe', '0.1[W/(m*K)]');
parameters.set('Cp_pipe', '(A_hdpe*rho_hdpe*Cp_hdpe+A_air*rho_air*Cp_air)/(A_hdpe*rho_hdpe+A_air*rho_air)');
parameters.set('rho_pipe', '(A_hdpe*rho_hdpe+A_air*rho_air)/(A_hdpe+A_air)');

% -------------------------------------------------------------------------
% Sets up fluid parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('fluid_parameters');
parameters.label('Fluid Parameters');
parameters.set('k_fluid', '0.60[W/(m*K)]');
parameters.set('Cp_fluid', '4186[J/(kg*K)]');
parameters.set('rho_fluid', '1000[kg/m^3]');
parameters.set('Q_fluid', '0.6[L/s]');
parameters.set('v_outer', 'Q_fluid/A_outer');
parameters.set('v_inner', 'Q_fluid/A_inner');

% -------------------------------------------------------------------------
% Sets up vector parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('vector_parameters');
parameters.label('Vector Parameters');

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('theta%d',i), sprintf('%.6f[deg]', borehole_tilt(i)));
end

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('nx%d',i), sprintf('cos(theta%d)', i));
    parameters.set(sprintf('nz%d',i), sprintf('sin(theta%d)', i));
end

% -------------------------------------------------------------------------
% Sets up tensor parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('tensor_parameters');
parameters.label('Tensor Parameters');

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('alpha%d', i), sprintf('-theta%d-90[deg]', i));
end

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('kxx_%d', i), sprintf('k_fluid*sin(alpha%d)^2+k_large*cos(alpha%d)^2', i, i));
    parameters.set(sprintf('kxy_%d', i), '0');
    parameters.set(sprintf('kxz_%d', i), sprintf('(k_fluid-k_large)*sin(2*alpha%d)/2', i));
    parameters.set(sprintf('kyx_%d', i), '0');
    parameters.set(sprintf('kyy_%d', i), 'k_large');
    parameters.set(sprintf('kyz_%d', i), '0');
    parameters.set(sprintf('kzx_%d', i), sprintf('(k_fluid-k_large)*sin(2*alpha%d)/2', i));
    parameters.set(sprintf('kzy_%d', i), '0');
    parameters.set(sprintf('kzz_%d', i), sprintf('k_fluid*cos(alpha%d)^2+k_large*sin(alpha%d)^2', i, i));
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates functions
% =========================================================================

fprintf(1, 'init_model: Creating functions... ');

% -------------------------------------------------------------------------
% Creates inlet temperature function
% -------------------------------------------------------------------------

if length(T_inlet) == 12
    
    pieces = cell(12, 3);

    for i = 1:12
        pieces{i, 1} = sprintf('%d/12', i-1);
        pieces{i, 2} = sprintf('%d/12', i);
        pieces{i, 3} = sprintf('%f', T_inlet(i));
    end
    
    func = model.func.create('inlet_temperature_function', 'Piecewise');
    func.label('Inlet Temperature Function');
    func.set('funcname', 'T_inlet');
    func.set('arg', 't');
    func.set('extrap', 'periodic');
    func.set('pieces', pieces);
    func.set('argunit', 'a');
    func.set('fununit', 'degC');

end

% -------------------------------------------------------------------------
% Creates initial temperature function
% -------------------------------------------------------------------------

func = model.func.create('initial_temperature_function', 'Analytic');
func.label('Initial Temperature Function');
func.set('funcname', 'T_initial');
func.set('expr', 'T_surface-q_geothermal/k_rock*z');
func.set('args', {'z'});
func.set('argunit', 'm');
func.set('fununit', 'K');

% -------------------------------------------------------------------------
% Creates step function
% -------------------------------------------------------------------------

func = model.func.create('step_function', 'Step');
func.label('Step Function');
func.set('funcname', 'step');
func.set('location', '1/24');
func.set('smooth', '1/12');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates geometry
% =========================================================================

fprintf(1, 'init_model: Creating geometry... ');

% -------------------------------------------------------------------------
% Creates work planes and extrusions for borehole structures
% -------------------------------------------------------------------------

fluid = HeatCarrierFluid(0, 20, 0.6/1000);

pipe = CoaxialPipe(50e-3, 32e-3, 0.1, 1900, 900);

cbhe_array = cell(1, length(borehole_tilt));

for i = 1:length(borehole_tilt)
    if borehole_tilt(i) == -90
        planes = {MirrorPlane(0), MirrorPlane(180-0.5*sector_angle)};
        cbhe_array{i} = CoaxialBoreholeHeatExchanger([0 0 0], borehole_tilt(i), 0, 76e-3, L_borehole, borehole_offset, r_buffer, fluid, pipe, planes);
    else
        planes = {MirrorPlane(0)};
        cbhe_array{i} = CoaxialBoreholeHeatExchanger([0 0 0], borehole_tilt(i), 0, 76e-3, L_borehole, borehole_offset, r_buffer, fluid, pipe, planes);
    end
end

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createGeometry(geometry);
end

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createSelections(geometry);
end

% -------------------------------------------------------------------------
% Creates work plane and extrusion for bedrock domain
% -------------------------------------------------------------------------

work_plane = geometry.create(sprintf('work_plane%d', 1+3*length(borehole_tilt)), 'WorkPlane');
work_plane.set('unite', true);
work_plane.set('quickz', '-L_borehole-buffer_width');

circle = work_plane.geom.create('sector_circle', 'Circle');
circle.set('angle', '0.5*sector_angle');
circle.set('r', 'L_borehole+buffer_width');

extrusion = geometry.feature.create(sprintf('extrusion%d', 1+3*length(borehole_tilt)), 'Extrude');
extrusion.set('workplane', work_plane.tag);
extrusion.selection('input').set(char(work_plane.tag));
extrusion.setIndex('distance', 'L_borehole+2*buffer_width', 0);

selection = geometry.create('surface_selection', 'CylinderSelection');
selection.label('Surface Selection');
selection.set('entitydim', 2);
selection.set('r', 'L_borehole+buffer_width+1[mm]');
selection.set('top', '+1[mm]');
selection.set('bottom', '-1[mm]');
selection.set('pos', {'0' '0' 'buffer_width'});
selection.set('condition', 'allvertices');

selection = geometry.create('bottom_selection', 'CylinderSelection');
selection.label('Bottom Selection');
selection.set('entitydim', 2);
selection.set('r', 'L_borehole+buffer_width+1[mm]');
selection.set('top', '+1[mm]');
selection.set('bottom', '-1[mm]');
selection.set('pos', {'0' '0' '-L_borehole-buffer_width'});
selection.set('condition', 'allvertices');

% -------------------------------------------------------------------------
% Generates geometry
% -------------------------------------------------------------------------

geometry.run('fin');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates mesh
% =========================================================================

fprintf(1, 'init_model: Creating mesh... ');

% -------------------------------------------------------------------------
% Crates inner triangle mesh for sweeping
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createMesh(mesh);
end

% hauto 9 = extremenly coarse
% hauto 8 = extra coarse
% hauto 7 = coarser
% hauto 6 = coarse
% hauto 5 = normal
% hauto 4 = fine
% hauto 3 = finer
% hauto 2 = extra fine
% hauto 1 = extremenly fine

%mesh.run('cap_cylinders_mesh');
%mesh.run('bedrock_mesh');

% mesh.run();

fprintf(1, 'Done.\n');

% =========================================================================
% Creates operators
% =========================================================================

fprintf(1, 'init_model: Creating operators... ');

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createOperators(component, geometry);
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates physics
% =========================================================================

fprintf(1, 'init_model: Creating physics... ');

% -------------------------------------------------------------------------
% Crates bedrock physics
% -------------------------------------------------------------------------

physics = component.physics.create('physics', 'HeatTransfer', geometry.tag);
physics.prop('ShapeProperty').set('order_temperature', 1);
physics.field('temperature').field('T');
physics.identifier('physics');
physics.name('physics');
physics.label('Heat Transfer');

physics.feature('init1').set('Tinit', 'T_initial(z-tunnel_depth)');
physics.feature('init1').label('Initial Values');

physics.feature('solid1').set('k_mat', 'userdef');
physics.feature('solid1').set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
physics.feature('solid1').label('Bedrock Solid');

physics.feature('solid1').set('rho_mat', 'userdef');
physics.feature('solid1').set('rho', 'rho_rock');

physics.feature('solid1').set('Cp_mat', 'userdef');
physics.feature('solid1').set('Cp', 'Cp_rock');

physics.create('hf1', 'HeatFluxBoundary', 2);
physics.feature('hf1').selection.named('geometry_surface_selection');
physics.feature('hf1').set('q0', '-q_geothermal');
physics.feature('hf1').label('Ground Surface Heat Flux BC');

physics.create('hf2', 'HeatFluxBoundary', 2);
physics.feature('hf2').selection.named('geometry_bottom_selection');
physics.feature('hf2').set('q0', '+q_geothermal');
physics.feature('hf2').label('Geothermal Heat Flux BC');

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createPhysics(physics);
end

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createBoundaryConditions(physics, 'T_inlet');
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates component variables
% =========================================================================

fprintf(1, 'init_model: Creating component variables... ');

variables = component.variable.create('component_variables');
variables.label('Component Variables');

for i = 1:length(borehole_tilt)
    cbhe_array{i}.createVariables(variables, physics);
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates events (if inlet temperature is not scalar)
% =========================================================================

fprintf(1, 'init_model: Creating events... ');

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

fprintf(1, 'Done.\n');

% =========================================================================
% Creates study and solution
% =========================================================================

fprintf(1, 'init_model: Creating study and solution... ');

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

return

% =========================================================================
% Creates results
% =========================================================================

fprintf(1, 'init_model: Creating results... ');

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

fprintf(1, 'init_model: Completed.\n');
