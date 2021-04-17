function model = init_borehole_field_model(borehole_spacing)

% Prints out summary of function arguments --------------------------------

fprintf(1, 'borehole_spacing = %.3f m\n', borehole_spacing);

% Creates model -----------------------------------------------------------

model = com.comsol.model.util.ModelUtil.create('Model');

model.label('Model');

% Creates component -------------------------------------------------------

model_component = model.component.create('model_component', true);

model_component.label('Model Component');

% Sets up parameters ------------------------------------------------------

model.param.set('borehole_spacing', sprintf('%.3f[m]', borehole_spacing));

model.param.set('H_model', '3[km]');

model.param.set('L_borehole', '2[km]');
model.param.set('r_borehole', '190[mm]/2');

model.param.set('r_inner', '76[mm]/2');
model.param.set('r_outer', '114[mm]/2');

model.param.set('T_surface', '6[degC]');
model.param.set('q_geothermal', '42[mW/m^2]');

model.param.set('T_inlet', '2[degC]');

model.param.set('k_rock', '3[W/(m*K)]');
model.param.set('Cp_rock', '860[J/(kg*K)]');
model.param.set('rho_rock', '2600[kg/m^3]');

model.param.set('k_pipe', '0.02[W/(m*K)]');
model.param.set('Cp_pipe', '1926[J/(kg*K)]');
model.param.set('rho_pipe', '950[kg/m^3]');

model.param.set('k_fluid', '0.6[W/(m*K)]');
model.param.set('rho_fluid', '1000[kg/m^3]');
model.param.set('Cp_fluid', '4184[J/(kg*K)]');

model.param.set('m_fluid', '2.5[kg/s]');
model.param.set('Q_fluid', 'm_fluid/rho_fluid');

model.param.set('A_inner', 'pi*r_inner^2');
model.param.set('A_outer', 'pi*r_borehole^2-pi*r_outer^2');

model.param.set('v_inner', 'Q_fluid/A_inner');
model.param.set('v_outer', 'Q_fluid/A_outer');

model.param.set('h_borehole', '5[mm]');
model.param.set('g_borehole', '1.1');
model.param.set('g_rock', '1.2');
model.param.set('n_swept', '200');
model.param.set('g_bottom', '1.1');

model.param.set('dt', '0.05');

% Creates functions -------------------------------------------------------

initial_temperature_function = model.func.create('initial_temperature_function', 'Analytic');
initial_temperature_function.set('funcname', 'T_initial');
initial_temperature_function.set('expr', 'T_surface-q_geothermal/k_rock*z');
initial_temperature_function.set('args', {'z'});
initial_temperature_function.set('argunit', 'm');
initial_temperature_function.set('fununit', 'K');
initial_temperature_function.label('Initial Temperature Function');

% Creates model geometry --------------------------------------------------

model_geometry = model_component.geom.create('model_geometry', 3);

work_plane = model_geometry.create('work_plane', 'WorkPlane');
work_plane.set('quickz', '-L_borehole');
work_plane.set('unite', true);
work_plane.label('Work Plane');

bedrock_rectangle = work_plane.geom.create('bedrock_rectangle', 'Rectangle');
bedrock_rectangle.set('pos', {'-0.5*borehole_spacing' '0'});
bedrock_rectangle.set('size', {'0.5*borehole_spacing' '0.5*borehole_spacing'});
bedrock_rectangle.label('Bedrock Rectangle');

borehole_circle = work_plane.geom.create('borehole_circle', 'Circle');
borehole_circle.set('pos', [0 0]);
borehole_circle.set('rot', 90);
borehole_circle.set('r', 'r_borehole');
borehole_circle.set('angle', 90);
borehole_circle.label('Borehole Circle');

outer_circle = work_plane.geom.create('outer_circle', 'Circle');
outer_circle.set('pos', [0 0]);
outer_circle.set('rot', 90);
outer_circle.set('r', 'r_outer');
outer_circle.set('angle', 90);
outer_circle.label('Outer Circle');

inner_circle = work_plane.geom.create('inner_circle', 'Circle');
inner_circle.set('pos', [0 0]);
inner_circle.set('rot', 90);
inner_circle.set('r', 'r_inner');
inner_circle.set('angle', 90);
inner_circle.label('Inner Circle');

extrude = model_geometry.create('extrude', 'Extrude');
extrude.setIndex('distance', 'L_borehole', 0);
extrude.selection('input').set({'work_plane'});
extrude.label('Work Plane Extrude Operation');

bottom_bedrock_block = model_geometry.create('bottom_bedrock_block', 'Block');
bottom_bedrock_block.set('pos', {'-0.5*borehole_spacing' '0' '-H_model'});
bottom_bedrock_block.set('size', {'0.5*borehole_spacing' '0.5*borehole_spacing' 'H_model-L_borehole'});
bottom_bedrock_block.label('Bottom Bedrock Block');

model_geometry.run();
model_geometry.run('fin');

% Creates component variables ---------------------------------------------

component_variables = model_component.variable.create('component_variables');
component_variables.set('borehole_wall_heat_rate', '4*borehole_wall_integration_operator(ht.ndflux)');
component_variables.set('T_outlet', 'outlet_average_operator(T)');
component_variables.set('T_bottom', 'bottom_average_operator(T)');
component_variables.label('Component Variables');

% Creates component couplings ---------------------------------------------

borehole_wall_integration_operator = model_component.cpl.create('borehole_wall_integration_operator', 'Integration');
borehole_wall_integration_operator.selection.geom('model_geometry', 2);
borehole_wall_integration_operator.selection.set([11]);
borehole_wall_integration_operator.label('Borehole Wall Integration Operator');

outlet_average_operator = model_component.cpl.create('outlet_average_operator', 'Average');
outlet_average_operator.selection.geom('model_geometry', 2);
outlet_average_operator.selection.set([21]);
outlet_average_operator.label('Outlet Average Operator');

bottom_average_operator = model_component.cpl.create('bottom_average_operator', 'Average');
bottom_average_operator.selection.geom('model_geometry', 2);
bottom_average_operator.selection.set([12]);
bottom_average_operator.label('Bottom Average Operator');

% Creates physics ---------------------------------------------------------

heat_transfer_physics = model_component.physics.create('ht', 'HeatTransfer', 'model_geometry');

heat_transfer_physics.label('Heat Transfer Physics');

heat_transfer_physics.prop('ShapeProperty').set('order_temperature', 1);

heat_transfer_physics.feature('init1').set('Tinit', 'T_initial(z)');

bedrock_solid_model = heat_transfer_physics.feature('solid1');
bedrock_solid_model.set('k_mat', 'userdef');
bedrock_solid_model.set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
bedrock_solid_model.set('rho_mat', 'userdef');
bedrock_solid_model.set('rho', 'rho_rock');
bedrock_solid_model.set('Cp_mat', 'userdef');
bedrock_solid_model.set('Cp', 'Cp_rock');
bedrock_solid_model.label('Bedrock Solid Model');

pipe_wall_solid_model = heat_transfer_physics.create('pipe_wall_solid_model', 'SolidHeatTransferModel', 3);
pipe_wall_solid_model.selection.set([4]);
pipe_wall_solid_model.set('k_mat', 'userdef');
pipe_wall_solid_model.set('k', {'k_pipe'; '0'; '0'; '0'; 'k_pipe'; '0'; '0'; '0'; 'k_pipe'});
pipe_wall_solid_model.set('rho_mat', 'userdef');
pipe_wall_solid_model.set('rho', 'rho_pipe');
pipe_wall_solid_model.set('Cp_mat', 'userdef');
pipe_wall_solid_model.set('Cp', 'Cp_pipe');
pipe_wall_solid_model.label('Pipe Wall Solid Model');

inner_fluid_model = heat_transfer_physics.create('inner_fluid_model', 'FluidHeatTransferModel', 3);
inner_fluid_model.selection.set([5]);
inner_fluid_model.set('k_mat', 'userdef');
inner_fluid_model.set('k', {'1000'; '0'; '0'; '0'; '1000'; '0'; '0'; '0'; 'k_fluid'});
inner_fluid_model.set('rho_mat', 'userdef');
inner_fluid_model.set('rho', 'rho_fluid');
inner_fluid_model.set('Cp_mat', 'userdef');
inner_fluid_model.set('Cp', 'Cp_fluid');
inner_fluid_model.set('gamma_mat', 'userdef');
inner_fluid_model.set('gamma', '1.0');
inner_fluid_model.set('minput_velocity', {'0'; '0'; 'v_inner'});
inner_fluid_model.label('Inner Fluid Model');

outer_fluid_model = heat_transfer_physics.create('outer_fluid_model', 'FluidHeatTransferModel', 3);
outer_fluid_model.selection.set([3]);
outer_fluid_model.set('k_mat', 'userdef');
outer_fluid_model.set('k', {'1000'; '0'; '0'; '0'; '1000'; '0'; '0'; '0'; 'k_fluid'});
outer_fluid_model.set('rho_mat', 'userdef');
outer_fluid_model.set('rho', 'rho_fluid');
outer_fluid_model.set('Cp_mat', 'userdef');
outer_fluid_model.set('Cp', 'Cp_fluid');
outer_fluid_model.set('gamma_mat', 'userdef');
outer_fluid_model.set('gamma', '1.0');
outer_fluid_model.set('minput_velocity', {'0'; '0'; '-v_outer'});
outer_fluid_model.label('Outer Fluid Model');

bottom_heat_flux_boundary = heat_transfer_physics.create('bottom_heat_flux_boundary', 'HeatFluxBoundary', 2);
bottom_heat_flux_boundary.selection.set([3]);
bottom_heat_flux_boundary.set('q0', 'q_geothermal');
bottom_heat_flux_boundary.label('Bottom Heat Flux Boundary');

surface_heat_flux_boundary = heat_transfer_physics.create('surface_heat_flux_boundary', 'HeatFluxBoundary', 2);
surface_heat_flux_boundary.selection.set([7]);
surface_heat_flux_boundary.set('q0', '-q_geothermal');
surface_heat_flux_boundary.label('Surface Heat Flux Boundary');

bottom_temperature_boundary = heat_transfer_physics.create('bottom_temperature_boundary', 'TemperatureBoundary', 2);
bottom_temperature_boundary.selection.set([20]);
bottom_temperature_boundary.set('T0', 'T_bottom');
bottom_temperature_boundary.label('Bottom Temperature Boundary');

inlet_temperature_boundary = heat_transfer_physics.create('inlet_temperature_boundary', 'TemperatureBoundary', 2);
inlet_temperature_boundary.selection.set([13]);
inlet_temperature_boundary.set('T0', 'T_inlet');
inlet_temperature_boundary.label('Inlet Temperature Boundary');

% Creates model mesh ------------------------------------------------------

model_mesh = model_component.mesh.create('model_mesh');

pipe_wall_mesh = model_mesh.create('pipe_wall_mesh', 'FreeTri');
pipe_wall_mesh.selection.set([17]);
pipe_wall_mesh.set('method', 'del');
pipe_wall_mesh.label('Pipe Wall Mesh');

pipe_wall_mesh_size = pipe_wall_mesh.create('pipe_wall_mesh_size', 'Size');
pipe_wall_mesh_size.set('custom', 'on');
pipe_wall_mesh_size.set('hmax', 'h_borehole');
pipe_wall_mesh_size.set('hmaxactive', true);
pipe_wall_mesh_size.label('Pipe Wall Mesh Size');

inner_fluid_mesh = model_mesh.create('inner_fluid_mesh', 'FreeTri');
inner_fluid_mesh.selection.set([21]);
inner_fluid_mesh.set('method', 'del');
inner_fluid_mesh.label('Inner Fluid Mesh');

inner_fluid_mesh_size = inner_fluid_mesh.create('inner_fluid_mesh_size', 'Size');
inner_fluid_mesh_size.set('custom', 'on');
inner_fluid_mesh_size.set('hmax', 'h_borehole');
inner_fluid_mesh_size.set('hmaxactive', true);
inner_fluid_mesh_size.label('Inner Fluid Mesh Size');

outer_fluid_mesh = model_mesh.create('outer_fluid_mesh', 'FreeTri');
outer_fluid_mesh.selection.set([13]);
outer_fluid_mesh.set('method', 'del');
outer_fluid_mesh.label('Outer Fluid Mesh');

outer_fluid_mesh_size = outer_fluid_mesh.create('outer_fluid_mesh_size', 'Size');
outer_fluid_mesh_size.set('custom', 'on');
outer_fluid_mesh_size.set('hmax', 'h_borehole');
outer_fluid_mesh_size.set('hmaxactive', true);
outer_fluid_mesh_size.set('hgrad', 'g_borehole');
outer_fluid_mesh_size.set('hgradactive', true);
outer_fluid_mesh_size.label('Outer Fluid Mesh Size');

bedrock_mesh = model_mesh.create('bedrock_mesh', 'FreeTri');
bedrock_mesh.selection.set([7]);
bedrock_mesh.set('method', 'del');
bedrock_mesh.label('Bedrock Mesh');

bedrock_mesh_size = bedrock_mesh.create('bedrock_mesh_size', 'Size');
bedrock_mesh_size.set('hauto', 3);
bedrock_mesh_size.set('custom', 'on');
bedrock_mesh_size.set('hgrad', 'g_rock');
bedrock_mesh_size.set('hgradactive', true);
bedrock_mesh_size.label('Bedrock Mesh Size');

swept_mesh = model_mesh.create('swept_mesh', 'Sweep');
swept_mesh.selection.geom('model_geometry', 3);
swept_mesh.selection.set([2 3 4 5]);
swept_mesh.label('Swepth Mesh');

swept_mesh_distribution = swept_mesh.create('swept_mesh_distribution', 'Distribution');
swept_mesh_distribution.set('type', 'predefined');
swept_mesh_distribution.set('elemcount', 'n_swept');
swept_mesh_distribution.set('elemratio', 500);
swept_mesh_distribution.set('method', 'geometric');
swept_mesh_distribution.set('symmetric', true);
swept_mesh_distribution.label('Swepth Mesh Distribution');

bottom_bedrock_mesh = model_mesh.create('bottom_bedrock_mesh', 'FreeTet');
bottom_bedrock_mesh.label('Bottom Bedrock Mesh');

bottom_bedrock_mesh_size = bottom_bedrock_mesh.create('bottom_bedrock_mesh_size', 'Size');
bottom_bedrock_mesh_size.set('custom', 'on');
bottom_bedrock_mesh_size.set('hgrad', 'g_bottom');
bottom_bedrock_mesh_size.set('hgradactive', true);
bottom_bedrock_mesh_size.label('Bottom Bedrock Mesh Size');

boundary_layer_mesh = model_mesh.create('bl1', 'BndLayer');
boundary_layer_mesh.selection.geom('model_geometry', 3);
boundary_layer_mesh.selection.set([2 3]); % Domains

boundary_layer_mesh_properties = boundary_layer_mesh.create('blp', 'BndLayerProp');
boundary_layer_mesh_properties.selection.set([11]); % Boundaries
boundary_layer_mesh_properties.set('blnlayers', 3);

model_mesh.run();

% Creates study and solution ----------------------------------------------

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
model.sol('sol1').feature('t1').feature.remove('dDef');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.study('std1').feature('time').set('tunit', 'a');
model.study('std1').feature('time').set('tlist', '0 10^range(-3,dt,3)');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clist', {'0 10^range(-3,dt,3)' '1.0[a]'});
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', '0 10^range(-3,dt,3)');
model.sol('sol1').feature('t1').set('tstepsbdf', 'intermediate');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol1').feature('t1').feature('fc1').set('damp', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
model.sol('sol1').feature('t1').feature('fc1').set('aaccdim', 5);
model.sol('sol1').feature('t1').feature('fc1').set('aaccmix', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('aaccdelay', 1);
model.sol('sol1').feature('t1').feature('d1').label('PARDISO (ht)');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d1').set('pivotperturb', 1.0E-13);
