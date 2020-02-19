function model = init_full_cylinder_model(file_name)

clear CoaxialBoreholeHeatExchanger % Resets the persistent id variable.

field_depth = 100;
model_radius = 600;
model_height = 600;

d_borehole = 0.076;
L_borehole = 300;
borehole_offset = 30;
r_buffer = 1;

fluid = HeatCarrierFluid(0, 20, 0.6/1000);
pipe = CoaxialPipe(50e-3, 32e-3, 0.1, 1900, 900);

% =========================================================================
% Constructs the borehole field.
% =========================================================================

% -------------------------------------------------------------------------
% Reads the position vectors of the BHE end points.
% -------------------------------------------------------------------------

config = load(file_name);

x = config(:, 1);
y = config(:, 2);
z = config(:, 3);

%i = [10, 20]; x = x(i); y = y(i); z = z(i);

% -------------------------------------------------------------------------
% Normalizes the position vectors of the BHE end points.
% -------------------------------------------------------------------------

r = sqrt(x.^2 + y.^2 + z.^2);

x = x ./ r;
y = y ./ r;
z = z ./ r;

% -------------------------------------------------------------------------
% Plots the normalized position vectors of the BHE end points.
% -------------------------------------------------------------------------

close all

for i = 1:length(x)
    plot3([0 x(i)], [0 y(i)], [0 z(i)], 'r-')
    if i == 1
        hold on
    end
end
plot3(0, 0, 0, 'ko')

% -------------------------------------------------------------------------
% Calculates the azimuth and tilt angles of the BHEs.
% -------------------------------------------------------------------------

% theta = acos(z ./ r);
theta = acos(z ./ r);
phi = atan2(y, x);

tilt = 90 - 180 * theta / pi;
azim = 180 * phi / pi;

% -------------------------------------------------------------------------
% Plots the end points of the BHEs.
% -------------------------------------------------------------------------

for i = 1:length(x)
    x = sin(pi/2-tilt(i)*pi/180)*cos(azim(i)*pi/180);
    y = sin(pi/2-tilt(i)*pi/180)*sin(azim(i)*pi/180);
    z = cos(pi/2-tilt(i)*pi/180);
    plot3(x, y, z, 'bo')
end

x = [-1 -1 -1 -1 +1 +1 +1 +1];
y = [-1 -1 +1 +1 -1 -1 +1 +1];
z = [-1 +0 -1 +0 -1 +0 -1 +0];

plot3([-1 +1 +1 -1 -1], [-1 -1 +1 +1 -1], [0 0 0 0 0], 'k:')
plot3([-1 +1 +1 -1 -1], [-1 -1 +1 +1 -1], [-1 -1 -1 -1 -1], 'k:')

plot3([-1 -1], [-1 -1], [-1 0], 'k:')
plot3([-1 -1], [+1 +1], [-1 0], 'k:')
plot3([+1 +1], [-1 -1], [-1 0], 'k:')
plot3([+1 +1], [+1 +1], [-1 0], 'k:')

grid on
hold off
title(sprintf('%d BHEs (%s)', length(tilt), file_name))

pause(1)

% -------------------------------------------------------------------------
% Constructs the BHEs.
% -------------------------------------------------------------------------

bhe_array = cell(1, length(tilt));

for i = 1:length(tilt)
    bhe_array{i} = CoaxialBoreholeHeatExchanger([0 0 -field_depth], tilt(i), azim(i), d_borehole, L_borehole, borehole_offset, r_buffer, fluid, pipe);
end

% =========================================================================
% Creates a new model.
% =========================================================================

import com.comsol.model.*
import com.comsol.model.util.*

fprintf(1, 'init_cylinder_model: Creating a new model... ');

model = ModelUtil.create('Cylinder Model');

model.label('cylinder_model');

comp = model.component.create('component', true);

geom = comp.geom.create('geometry', 3);

mesh = comp.mesh.create('mesh');

comp.view('view1').set('renderwireframe', true);
comp.view('view1').camera.set('manualgrid', true);
comp.view('view1').camera.set('xspacing', 50);
comp.view('view1').camera.set('yspacing', 50);
comp.view('view1').camera.set('zspacing', 50);

fprintf(1, 'Done.\n');

% =========================================================================
% Sets up parameters.
% =========================================================================

fprintf(1, 'init_cylinder_model: Setting up parameters... ');

model.param.set('q_geothermal', '40[mW/m^2]');
model.param.set('T_surface', '2.3[degC]');
model.param.set('k_rock', '3[W/(m*K)]');
model.param.set('Cp_rock', '750[J/(kg*K)]');
model.param.set('rho_rock', '2700[kg/m^3]');
model.param.set('T_charge', '30[degC]');
model.param.set('Q_discharge', '1[MW]');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates functions.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating functions... ');

% -------------------------------------------------------------------------
% Creates initial temperature function.
% -------------------------------------------------------------------------

func = model.func.create('initial_temperature_function', 'Analytic');
func.label('Initial Temperature Function');
func.set('funcname', 'T_initial');
func.set('expr', 'T_surface-q_geothermal/k_rock*z');
func.set('args', {'z'});
func.set('argunit', 'm');
func.set('fununit', 'K');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates geometry.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating geometry... ');

% -------------------------------------------------------------------------
% Creates BHE geometries.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createGeometry(geom);
end

% -------------------------------------------------------------------------
% Creates bedrock geometry.
% -------------------------------------------------------------------------

bedrock_cylinder = geom.create('bedrock_cylinder', 'Cylinder');
bedrock_cylinder.label('Bedrock Cylinder');
bedrock_cylinder.set('r', model_radius);
bedrock_cylinder.set('h', model_height);
bedrock_cylinder.set('pos', [0 0 -model_height]);

% =========================================================================
% Creates selections.
% =========================================================================

% -------------------------------------------------------------------------
% Creates BHE selections.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createSelections(geom);
end

% -------------------------------------------------------------------------
% Creates ground surface selection.
% -------------------------------------------------------------------------

surface_boundary_selection = geom.create('surface_boundary_selection', 'CylinderSelection');
surface_boundary_selection.label('Surface Boundary Selection');
surface_boundary_selection.set('entitydim', 2);
surface_boundary_selection.set('r', model_radius+0.001);
surface_boundary_selection.set('top', 0.001);
surface_boundary_selection.set('bottom', -0.001);
surface_boundary_selection.set('pos', {'0' '0' '0'});
surface_boundary_selection.set('condition', 'allvertices');

% -------------------------------------------------------------------------
% Creates bottom surface selection.
% -------------------------------------------------------------------------

bottom_boundary_selection = geom.create('bottom_boundary_selection', 'CylinderSelection');
bottom_boundary_selection.label('Bottom Boundary Selection');
bottom_boundary_selection.set('entitydim', 2);
bottom_boundary_selection.set('r', model_radius+0.001);
bottom_boundary_selection.set('top', -model_height+0.001);
bottom_boundary_selection.set('bottom', -model_height-0.001);
bottom_boundary_selection.set('pos', {'0' '0' '0'});
bottom_boundary_selection.set('condition', 'allvertices');

% Reruns the geometry.

geom.run('fin');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates mesh.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating mesh... ');

% -------------------------------------------------------------------------
% Creates BHE meshes.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createMesh(geom, mesh);
end

% -------------------------------------------------------------------------
% Creates bedrock mesh.
% -------------------------------------------------------------------------

mesh.create('bedrock_mesh', 'FreeTet');

% -------------------------------------------------------------------------
% Runs the mesh.
% -------------------------------------------------------------------------

% mesh.run();

fprintf(1, 'Done.\n');

% =========================================================================
% Creates operators.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating operators... ');

for i = 1:length(bhe_array)
    bhe_array{i}.createOperators(comp, geom);
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates physics.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating physics... ');

% -------------------------------------------------------------------------
% Creates a physics node.
% -------------------------------------------------------------------------

phys = comp.physics.create('heat_transfer_physics', 'HeatTransfer', geom.tag);

phys.label('Heat Transfer Physics');
%phys.name(phys.tag);
phys.identifier(phys.tag);

phys.prop('ShapeProperty').set('order_temperature', 1);
phys.field('temperature').field('T');

% -------------------------------------------------------------------------
% Sets up the bedrock physics.
% -------------------------------------------------------------------------

phys.feature('init1').set('Tinit', 'T_initial(z)');
phys.feature('init1').label('Initial Values');

phys.feature('solid1').set('k_mat', 'userdef');
phys.feature('solid1').set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
phys.feature('solid1').label('Bedrock Solid');

phys.feature('solid1').set('rho_mat', 'userdef');
phys.feature('solid1').set('rho', 'rho_rock');

phys.feature('solid1').set('Cp_mat', 'userdef');
phys.feature('solid1').set('Cp', 'Cp_rock');

% -------------------------------------------------------------------------
% Creates boundary conditions for the bedrock physics.
% -------------------------------------------------------------------------

% surface_heat_flux_bc = phys.create('surface_heat_flux_bc', 'HeatFluxBoundary', 2);
% surface_heat_flux_bc.label('Ground Surface Heat Flux BC');
% surface_heat_flux_bc.selection.named(sprintf('%s_surface_boundary_selection', geom.tag));
% surface_heat_flux_bc.set('q0', '-q_geothermal');

surface_temperature_bc = phys.create('surface_temperature_bc', 'TemperatureBoundary', 2);
surface_temperature_bc.label('Ground Surface Temperature BC');
surface_temperature_bc.selection.named(sprintf('%s_surface_boundary_selection', geom.tag));
surface_temperature_bc.set('T0', 'T_surface');

bottom_heat_flux_bc = phys.create('bottom_heat_flux_bc', 'HeatFluxBoundary', 2);
bottom_heat_flux_bc.label('Geothermal Heat Flux BC');
bottom_heat_flux_bc.selection.named(sprintf('%s_bottom_boundary_selection', geom.tag));
bottom_heat_flux_bc.set('q0', '+q_geothermal');

% -------------------------------------------------------------------------
% Adds the BHE physics to the physics node.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createPhysics(geom, phys);
end

% -------------------------------------------------------------------------
% Creates boundary conditions for the BHE physics.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createBoundaryConditions(geom, phys, 'is_charging*T_charge+is_discharging*(T_outlet-delta_T)');
end

% -------------------------------------------------------------------------
% Creates events.
% -------------------------------------------------------------------------

% events = comp.physics.create('ev', 'Events', geom.tag);
% events.prop('ShapeProperty').set('order', 1);

% discrete_states = events.create('discrete_states', 'DiscreteStates', -1);
% discrete_states.set('dim', {'is_charging'; 'is_discharging'});
% discrete_states.set('dimInit', [1; 0]);

% charging_event = events.create('charging_event', 'ExplicitEvent', -1);
% charging_event.set('start', '0[a]');
% charging_event.set('period', '1[a]');
% charging_event.set('reInitName', {'is_charging'; 'is_discharging'});
% charging_event.set('reInitValue', [1; 0]);
% 
% discharging_event = events.create('discharging_event', 'ExplicitEvent', -1);
% discharging_event.set('start', '0.5[a]');
% discharging_event.set('period', '1[a]');
% discharging_event.set('reInitName', {'is_charging'; 'is_discharging'});
% discharging_event.set('reInitValue', [0; 1]);

fprintf(1, 'Done.\n');

% =========================================================================
% Creates component variables.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating component variables... ');

vars = comp.variable.create('component_variables');
vars.label('Component Variables');

% -------------------------------------------------------------------------
% Creates BHE variables.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createVariables(vars, phys);
end

% -------------------------------------------------------------------------
% Creates borehole field outlet temperature variable.
% -------------------------------------------------------------------------

expr = sprintf('T_outlet%d', bhe_array{1}.id);

for i = 2:length(bhe_array)
    expr = sprintf('%s+T_outlet%d', expr, bhe_array{i}.id);
end

expr = sprintf('(%s)/%d', expr, length(bhe_array));

vars.set('T_outlet', expr);

% -------------------------------------------------------------------------
% Creates borehole field total heating power variable.
% -------------------------------------------------------------------------

expr = sprintf('Q_wall%d', bhe_array{1}.id);

for i = 2:length(bhe_array)
    expr = sprintf('%s+Q_wall%d', expr, bhe_array{i}.id);
end

vars.set('Q_total', expr);

% -------------------------------------------------------------------------
% Creates temperature drop variable.
% -------------------------------------------------------------------------

vars.set('delta_T', sprintf('Q_discharge/(%f[kg/m^3]*%f[J/(kg*K)]*(%d*%f[m^3/s]))', fluid.density, fluid.specificHeatCapacity, length(bhe_array), fluid.flowRate));

fprintf(1, 'Done.\n');

% =========================================================================
% Creates study and solution.
% =========================================================================

fprintf(1, 'init_cylinder_model: Creating study and solution... ');

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
model.study('std1').feature('time').set('tlist', '0 10');
model.study('std1').feature('time').set('usertol', true);
model.study('std1').feature('time').set('rtol', '1e-2');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clist', {'0 10' '1e-6[a]'});
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', '0 10');
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

% model.study('std1').feature('time').activate('ev', true);

% model.sol('sol1').runAll;

fprintf(1, 'Done.\n');

events = comp.physics.create('events', 'Events', 'geometry');
events.label('Charging and Discharging Events');
events.identifier(events.tag);

model.study('std1').feature('time').activate(events.tag, true);

discrete_states = events.create('discrete_states', 'DiscreteStates', -1);
discrete_states.label('Charging and Discharging States');
discrete_states.setIndex('dim', 'is_charging', 0, 0);
discrete_states.setIndex('dimInit', 0, 0, 0);
discrete_states.setIndex('dim', 'is_discharging', 1, 0);
discrete_states.setIndex('dimInit', 0, 1, 0);
discrete_states.setIndex('dimDescr', '', 1, 0);
discrete_states.setIndex('dimInit', 1, 0, 0);

charging_event = events.create('charging_event', 'ExplicitEvent', -1);
charging_event.label('Charging Event');
charging_event.set('start', '0[a]');
charging_event.set('period', '1[a]');
charging_event.setIndex('reInitName', 'is_charging', 0, 0);
charging_event.setIndex('reInitValue', 0, 0, 0);
charging_event.setIndex('reInitValue', 1, 0, 0);
charging_event.setIndex('reInitName', 'is_discharging', 1, 0);
charging_event.setIndex('reInitValue', 0, 1, 0);

discharging_event = events.create('discharging_event', 'ExplicitEvent', -1);
discharging_event.label('Discharging Event');
discharging_event.set('start', '0.5[a]');
discharging_event.set('period', '1[a]');
discharging_event.setIndex('reInitName', 'is_charging', 0, 0);
discharging_event.setIndex('reInitValue', 0, 0, 0);
discharging_event.setIndex('reInitName', 'is_discharging', 1, 0);
discharging_event.setIndex('reInitValue', 0, 1, 0);
discharging_event.setIndex('reInitValue', 1, 1, 0);
