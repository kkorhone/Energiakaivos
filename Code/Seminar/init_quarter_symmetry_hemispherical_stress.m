% This function uses the CoaxialBoreholeHeatExchanger class.

function model = init_quarter_symmetry_hemispherical_stress(file_name, params)

clear CoaxialBoreholeHeatExchanger % Resets the persistent id variable.

% =========================================================================
% Checks the sanity of the parameters.
% =========================================================================

if params.q_geothermal <= 0
    error('Geothermal heat flux density must be positive.');
end

if params.k_rock <= 0
    error('Bedrock thermal conductivity must be positive.');
end

if params.Cp_rock <= 0
    error('Dedrock specific heat capacity must be positive.');
end

if params.rho_rock <= 0
    error('Bedrock density must be positive.');
end

if params.buffer_width <= 0
    error('Buffer width must be positive.');
end

% =========================================================================
% Constructs the BHE field.
% =========================================================================

% -------------------------------------------------------------------------
% Fetches the BHE field configuration.
% -------------------------------------------------------------------------

field_config = load(file_name);

bhe_collars = field_config(:, 1:3);
bhe_footers = field_config(:, 4:6);
bhe_factors = field_config(:, 7);

fprintf(1, '>> Read %d BHEs from ''%s''.\n', length(bhe_factors), file_name);
fprintf(1, '>> sum(bhe_factors)=%d\n', sum(bhe_factors));

% -------------------------------------------------------------------------
% Calculates the spatial extent of the BHE field.
% -------------------------------------------------------------------------

x_max = max(max(bhe_collars(:, 1)), max(bhe_footers(:, 1)));
y_max = max(max(bhe_collars(:, 2)), max(bhe_footers(:, 2)));

z_min = min(min(bhe_collars(:, 3)), min(bhe_footers(:, 3)));
z_max = max(max(bhe_collars(:, 3)), max(bhe_footers(:, 3)));

z_field = max(max(bhe_collars(:, 3)), max(bhe_footers(:, 3)));
r_field = max(sqrt(bhe_footers(:,1).^2+bhe_footers(:,2).^2+(bhe_footers(:,3)-z_field).^2));

fprintf(1, '>> True spatial extent:\n');
fprintf(1, '>> x_max=%.1f y_max=%.1f\n', x_max, y_max);
fprintf(1, '>> z_min=%.1f z_max=%.1f\n', z_min, z_max);

x_max = ceil(x_max / 100) * 100;
y_max = ceil(y_max / 100) * 100;

z_min = floor(z_min / 100) * 100;
z_max = ceil(z_max / 100) * 100;

x_max = x_max + params.buffer_width;
y_max = y_max + params.buffer_width;

z_min = z_min - params.buffer_width;
z_max = min(0, z_max+params.buffer_width);

fprintf(1, '>> Extended spatial extent:\n');
fprintf(1, '>> x_max=%.1f y_max=%.1f\n', x_max, y_max);
fprintf(1, '>> z_min=%.1f z_max=%.1f\n', z_min, z_max);

% -------------------------------------------------------------------------
% Constructs the BHEs.
% -------------------------------------------------------------------------

working_fluid = HeatCarrierFluid(params.c_fluid, params.T_fluid);
coaxial_pipe = CoaxialPipe(params.d_outer, params.d_inner, params.k_pipe, params.Cp_pipe, params.rho_pipe);

total_flow_rate = 0;

bhe_array = cell(1, length(bhe_factors));

for i = 1:length(bhe_factors)

    bhe_axis = bhe_footers(i,:) - bhe_collars(i,:);
    bhe_axis = bhe_axis / sqrt(dot(bhe_axis, bhe_axis));
    
    if bhe_axis(:, 3) > 0
        error('Upward borehole.');
    end
    
    is_vertical = abs(dot([0, 0, -1], bhe_axis) - 1) < 1e-6;
    
    if (abs(bhe_collars(i, 1)) < 1e-6) && (abs(bhe_collars(i, 2)) < 1e-6)
        
        % BHE is located at the origin.
        
        if is_vertical
            cut_planes = {CutPlane(0), CutPlane(90)};
            bhe_array{i} = CoaxialBoreholeHeatExchanger(bhe_collars(i,:), bhe_footers(i,:), params.d_borehole, coaxial_pipe, params.flow_rate, working_fluid, 'bufferradius', params.r_buffer, 'cutplanes', cut_planes);
            fprintf(1, '>>> Vertical BHE at origin (BHE factor = %d).\n', bhe_factors(i));
        else
            error('Inclined BHE at origin.');
        end
        
    elseif abs(bhe_collars(i, 2)) < 1e-6

        % BHE is located on the x axis.
        
        if is_vertical
            error('Vertical BHE on x axis.');
        else
            cut_planes = {CutPlane(0)};
            bhe_array{i} = CoaxialBoreholeHeatExchanger(bhe_collars(i,:), bhe_footers(i,:), params.d_borehole, coaxial_pipe, params.flow_rate, working_fluid, 'bufferradius', params.r_buffer, 'cutplanes', cut_planes);
            fprintf(1, '>>> Inclined BHE on x axis (BHE factor = %d).\n', bhe_factors(i));
        end
        
    elseif abs(bhe_collars(i, 1)) < 1e-6
        
        % BHE is located on the y axis.
        
        if is_vertical
            error('Vertical BHE on y axis.');
        else
            cut_planes = {CutPlane(180)};
            bhe_array{i} = CoaxialBoreholeHeatExchanger(bhe_collars(i,:), bhe_footers(i,:), params.d_borehole, coaxial_pipe, params.flow_rate, working_fluid, 'bufferradius', params.r_buffer, 'cutplanes', cut_planes);
            fprintf(1, '>>> Inclined BHE on y axis (BHE factor = %d).\n', bhe_factors(i));
        end
        
    else
        
        % BHE is located in the first quadrant.
        
        if is_vertical
            error('Vertical BHE in first quadrant.');
        else
            bhe_array{i} = CoaxialBoreholeHeatExchanger(bhe_collars(i,:), bhe_footers(i,:), params.d_borehole, coaxial_pipe, params.flow_rate, working_fluid, 'bufferradius', params.r_buffer);
            fprintf(1, '>>> Inclined BHE in first quadrant (BHE factor = %d).\n', bhe_factors(i));
        end
    end

    total_flow_rate = total_flow_rate + bhe_factors(i) * bhe_array{i}.flowRate;

end

fprintf(1, '>>> length(bhe_array)=%d\n', length(bhe_array));
fprintf(1, '>>> total_flow_rate=%f\n', total_flow_rate);

close all

plot_bhe_field(bhe_array)

pause(1)

% =========================================================================
% Creates a new model.
% =========================================================================

import com.comsol.model.*
import com.comsol.model.util.*

fprintf(1, '>>> Creating a new model... ');

model = ModelUtil.create('Quarter Symmetry Hemispherical Model');

model.label('quarter_symmetry_hemispherical_model');

comp = model.component.create('component', true);

geom = comp.geom.create('geometry', 3);

mesh = comp.mesh.create('mesh');

fprintf(1, 'Done.\n');

% =========================================================================
% Sets up parameters.
% =========================================================================

model.param.set('delta_T', sprintf('%f[W]/(%f[kg/m^3]*%f[J/(kg*K)]*%f[m^3/s])', params.Q_discharging, working_fluid.density, working_fluid.specificHeatCapacity, total_flow_rate));

% =========================================================================
% Sets up view.
% =========================================================================

fprintf(1, '>>> Setting up view... ');

comp.view('view1').set('renderwireframe', true);
comp.view('view1').camera.set('manualgrid', true);
comp.view('view1').camera.set('xspacing', 100);
comp.view('view1').camera.set('yspacing', 100);
comp.view('view1').camera.set('zspacing', 100);

fprintf(1, 'Done.\n');

% =========================================================================
% Creates functions.
% =========================================================================

fprintf(1, '>>> Creating functions... ');

% -------------------------------------------------------------------------
% Creates initial temperature function.
% -------------------------------------------------------------------------

expr = sprintf('%f[degC]-%f[W/m^2]/%f[W/(m*K)]*z', params.T_surface, params.q_geothermal, params.k_rock);

func = model.func.create('initial_temperature_function', 'Analytic');
func.label('Initial Temperature Function');
func.set('funcname', 'T_initial');
func.set('expr', expr);
func.set('args', {'z'});
func.set('argunit', 'm');
func.set('fununit', 'K');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates geometry.
% =========================================================================

fprintf(1, '>>> Creating geometry... ');

% -------------------------------------------------------------------------
% Creates BHE geometries.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createGeometry(geom);
end

% -------------------------------------------------------------------------
% Creates bedrock geometry.
% -------------------------------------------------------------------------

bedrock_work_plane = geom.create('bedrock_work_plane', 'WorkPlane');
bedrock_work_plane.label('Bedrock Work Plane');
bedrock_work_plane.set('unite', true);
bedrock_work_plane.set('quickz', z_min);

bedrock_circle = bedrock_work_plane.geom.create('bedrock_circle', 'Circle');
bedrock_circle.set('r', max(x_max, y_max));
bedrock_circle.set('angle', 90);

bedrock_extrude = geom.feature.create('bedrock_extrude', 'Extrude');
bedrock_extrude.label('Bedrock Extrusion');
bedrock_extrude.set('workplane', bedrock_work_plane.tag);
bedrock_extrude.selection('input').set({char(bedrock_work_plane.tag)});
bedrock_extrude.setIndex('distance', z_max-z_min, 0);

% -------------------------------------------------------------------------
% Creates a field encompassing surface.
% -------------------------------------------------------------------------

dr_field = 20;

work_plane = geom.create('work_plane', 'WorkPlane');
work_plane.set('quickplane', 'xz');
work_plane.set('unite', true);

circle = work_plane.geom.create('circle', 'Circle');
circle.set('pos', [0 z_field]);
circle.set('rot', -90);
circle.set('r', r_field+dr_field);
circle.set('angle', 90);

rectangle = work_plane.geom.create('rectangle', 'Rectangle');
rectangle.set('pos', [0 z_field]);
rectangle.set('size', [r_field+dr_field dr_field]);

union = work_plane.geom.create('union', 'Union');
union.set('intbnd', false);
union.selection('input').set({char(circle.tag) char(rectangle.tag)});

convert = work_plane.geom.create('convert', 'ConvertToCurve');
convert.selection('input').set({char(union.tag)});

revolve = geom.create('revolve', 'Revolve');
revolve.set('angle1', 0);
revolve.set('angle2', 90);
revolve.set('selresult', true);
revolve.set('selresultshow', 'bnd');
revolve.selection('input').set({char(work_plane.tag)});

fprintf(1, 'Done.\n');

% =========================================================================
% Creates selections.
% =========================================================================

fprintf(1, '>>> Creating selections... ');

% -------------------------------------------------------------------------
% Creates BHE selections.
% -------------------------------------------------------------------------

difference_tags = {};

for i = 1:length(bhe_array)
    selection_tags = bhe_array{i}.createSelections(geom);
    difference_tags{end+1} = selection_tags{5};
    difference_tags{end+1} = selection_tags{9};
end

% -------------------------------------------------------------------------
% Creates ground surface selection.
% -------------------------------------------------------------------------

surface_boundary_selection = geom.create('surface_boundary_selection', 'CylinderSelection');
surface_boundary_selection.label('Surface Boundary Selection');
surface_boundary_selection.set('entitydim', 2);
surface_boundary_selection.set('r', max(x_max,y_max)+0.001);
surface_boundary_selection.set('top', z_max+0.001);
surface_boundary_selection.set('bottom', z_max-0.001);
surface_boundary_selection.set('pos', {'0' '0' '0'});
surface_boundary_selection.set('condition', 'allvertices');

% -------------------------------------------------------------------------
% Creates bottom surface selection.
% -------------------------------------------------------------------------

bottom_boundary_selection = geom.create('bottom_boundary_selection', 'CylinderSelection');
bottom_boundary_selection.label('Bottom Boundary Selection');
bottom_boundary_selection.set('entitydim', 2);
bottom_boundary_selection.set('r', max(x_max, y_max)+0.001);
bottom_boundary_selection.set('top', z_min+0.001);
bottom_boundary_selection.set('bottom', z_min-0.001);
bottom_boundary_selection.set('pos', {'0' '0' '0'});
bottom_boundary_selection.set('condition', 'allvertices');

% -------------------------------------------------------------------------
% Creates selections for the field encompassing surface.
% -------------------------------------------------------------------------

above_surface_selection = geom.create('above_surface_selection', 'CylinderSelection');
above_surface_selection.label('Above Surface Selection');
above_surface_selection.set('entitydim', 2);
above_surface_selection.set('r', r_field+dr_field+1);
above_surface_selection.set('top', dr_field+0.001);
above_surface_selection.set('bottom', dr_field-0.001);
above_surface_selection.set('pos', {'0' '0' num2str(z_field)});
above_surface_selection.set('condition', 'allvertices');

below_surface_selection = geom.create('below_surface_selection', 'DifferenceSelection');
below_surface_selection.label('Below Surface Selection');
below_surface_selection.set('entitydim', 2);
below_surface_selection.set('add', {char(revolve.tag)});
below_surface_selection.set('subtract', {char(above_surface_selection.tag)});

% Runs the geometry.

geom.run('fin');

ball_selection = geom.create('ball_selection', 'BallSelection');
ball_selection.label('Ball Selection');
ball_selection.set('posz', z_field);
ball_selection.set('r', r_field+dr_field+1);
ball_selection.set('condition', 'allvertices');

geom.run(ball_selection.tag);

field_volume_selection = geom.create('field_volume_selection', 'DifferenceSelection');
field_volume_selection.label('Field Volume Selection');
field_volume_selection.set('entitydim', 3);
field_volume_selection.set('add', {char(ball_selection.tag)});
field_volume_selection.set('subtract', difference_tags);

geom.run(field_volume_selection.tag);

% Reruns the geometry.

geom.run('fin');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates mesh.
% =========================================================================

fprintf(1, '>>> Creating mesh... ');

% -------------------------------------------------------------------------
% Creates BHE meshes.
% -------------------------------------------------------------------------

for i = 1:length(bhe_array)
    bhe_array{i}.createMesh(geom, mesh);
end

% -------------------------------------------------------------------------
% Creates bedrock mesh.
% -------------------------------------------------------------------------

field_volume_mesh = mesh.create('field_volume_mesh', 'FreeTet');
field_volume_mesh.selection.geom(geom.tag, 3);
%field_volume_mesh.selection.name(sprintf('%s_%s', geom.tag, field_volume_selection.tag));
field_volume_mesh.selection.named('geometry_field_volume_selection');

field_volume_mesh_size = field_volume_mesh.create('field_volume_mesh_size', 'Size');
field_volume_mesh_size.set('hauto', 2);

% -------------------------------------------------------------------------
% Creates bedrock mesh.
% -------------------------------------------------------------------------

bedrock_mesh = mesh.create('bedrock_mesh', 'FreeTet');

bedrock_mesh_size = bedrock_mesh.create('bedrock_mesh_size', 'Size');
bedrock_mesh_size.set('hauto', 2);

% -------------------------------------------------------------------------
% Runs the mesh.
% -------------------------------------------------------------------------

% mesh.run();

fprintf(1, 'Done.\n');

% =========================================================================
% Creates operators.
% =========================================================================

fprintf(1, '>>> Creating operators... ');

for i = 1:length(bhe_array)
    bhe_array{i}.createOperators(comp, geom);
end

above_surface_intergation_operator = comp.cpl.create('above_surface_integration_operator', 'Integration');
above_surface_intergation_operator.label('Above Surface Integration Operator');
above_surface_intergation_operator.selection.geom(geom.tag, 2);
above_surface_intergation_operator.selection.named(sprintf('%s_%s', geom.tag, above_surface_selection.tag));

below_surface_intergation_operator = comp.cpl.create('below_surface_integration_operator', 'Integration');
below_surface_intergation_operator.label('Below Surface Integration Operator');
below_surface_intergation_operator.selection.geom(geom.tag, 2);
below_surface_intergation_operator.selection.named(sprintf('%s_%s', geom.tag, below_surface_selection.tag));

field_volume_average_operator = comp.cpl.create('field_volume_average_operator', 'Average');
field_volume_average_operator.label('Field Volume Average Operator');
field_volume_average_operator.selection.geom(geom.tag, 3);
field_volume_average_operator.selection.named(sprintf('%s_%s', geom.tag, field_volume_selection.tag));

fprintf(1, 'Done.\n');

% =========================================================================
% Creates physics.
% =========================================================================

fprintf(1, '>>> Creating physics... ');

% -------------------------------------------------------------------------
% Creates a physics node.
% -------------------------------------------------------------------------

phys = comp.physics.create('physics', 'HeatTransfer', geom.tag);

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
phys.feature('solid1').set('k', {sprintf('%f',params.k_rock); '0'; '0'; '0'; sprintf('%f',params.k_rock); '0'; '0'; '0'; sprintf('%f',params.k_rock)});
phys.feature('solid1').label('Bedrock Solid');

phys.feature('solid1').set('rho_mat', 'userdef');
phys.feature('solid1').set('rho', params.rho_rock);

phys.feature('solid1').set('Cp_mat', 'userdef');
phys.feature('solid1').set('Cp', params.Cp_rock);

% -------------------------------------------------------------------------
 % Creates boundary conditions for the bedrock physics.
% -------------------------------------------------------------------------

if z_max == 0
    surface_temperature_bc = phys.create('surface_temperature_bc', 'TemperatureBoundary', 2);
    surface_temperature_bc.label('Ground Surface Temperature BC');
    surface_temperature_bc.selection.named(sprintf('%s_surface_boundary_selection', geom.tag));
    surface_temperature_bc.set('T0', sprintf('%f[degC]', params.T_surface));
else
    surface_heat_flux_bc = phys.create('surface_heat_flux_bc', 'HeatFluxBoundary', 2);
    surface_heat_flux_bc.label('Ground Surface Heat Flux BC');
    surface_heat_flux_bc.selection.named(sprintf('%s_surface_boundary_selection', geom.tag));
    surface_heat_flux_bc.set('q0', -params.q_geothermal);
end

bottom_heat_flux_bc = phys.create('bottom_heat_flux_bc', 'HeatFluxBoundary', 2);
bottom_heat_flux_bc.label('Geothermal Heat Flux BC');
bottom_heat_flux_bc.selection.named(sprintf('%s_bottom_boundary_selection', geom.tag));
bottom_heat_flux_bc.set('q0', params.q_geothermal);

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
    bhe_array{i}.createBoundaryConditions(geom, phys, 'if((T_outlet-delta_T)>2[degC],T_outlet-delta_T,2[degC])');
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates component variables.
% =========================================================================

fprintf(1, '>>> Creating component variables... ');

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

expr = sprintf('%d*T_outlet%d', bhe_factors(1), bhe_array{1}.id);

for i = 2:length(bhe_array)
    expr = sprintf('%s+%d*T_outlet%d', expr, bhe_factors(i), bhe_array{i}.id);
end

expr = sprintf('(%s)/%d', expr, sum(bhe_factors));

vars.set('T_outlet', expr);

% -------------------------------------------------------------------------
% Creates borehole field total heating power variable.
% -------------------------------------------------------------------------

expr = sprintf('%d*Q_wall%d', bhe_factors(1), bhe_array{1}.id);

for i = 2:length(bhe_array)
    expr = sprintf('%s+%d*Q_wall%d', expr, bhe_factors(i), bhe_array{i}.id);
end

vars.set('Q_total', expr);

% -------------------------------------------------------------------------
% Creates ...
% -------------------------------------------------------------------------

vars.set('Q_above', sprintf('4*above_surface_integration_operator(%s.ndflux)', phys.tag));
vars.set('Q_below', sprintf('4*below_surface_integration_operator(%s.ndflux)', phys.tag));
vars.set('T_field', 'field_volume_average_operator(T)');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates study and solution.
% =========================================================================

fprintf(1, '>>> Creating study and solution... ');

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
model.study('std1').feature('time').set('rtol', '1e-3');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clist', {'0 100' '1e-6[a]'});
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', '0 100');
model.sol('sol1').feature('t1').set('rtol', '1e-3');
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

% model.study('std1').feature('time').activate('events', true);

fprintf(1, 'Done.\n');

return

% =========================================================================
% Creates events.
% =========================================================================

fprintf(1, '>>> Creating events... ');

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

fprintf(1, 'Done.\n');
