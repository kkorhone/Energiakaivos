function out = model
%
% temp.m
%
% Model exported on Jun 20 2019, 14:02 by COMSOL 5.4.0.295.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\QHeat\Helsingin_Geoenergiapotentiaali');

model.label('Model');

model.component.create('model_component', true);

model.component('model_component').label('Model Component');

model.param.set('borehole_spacing', '200.000[m]');
model.param.set('W_model', '1[km]');
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
model.param.set('h_borehole', '10[mm]');
model.param.set('g_borehole', '1.2');
model.param.set('g_rock', '1.2');
model.param.set('n_swept', '100');
model.param.set('g_bottom', '1.3');
model.param.set('dt', '1/12');

model.func.create('initial_temperature_function', 'Analytic');
model.func('initial_temperature_function').set('funcname', 'T_initial');
model.func('initial_temperature_function').set('expr', 'T_surface-q_geothermal/k_rock*z');
model.func('initial_temperature_function').set('args', 'z');
model.func('initial_temperature_function').set('argunit', 'm');
model.func('initial_temperature_function').set('fununit', 'K');
model.func('initial_temperature_function').label('Initial Temperature Function');

model.component('model_component').geom.create('model_geometry', 3);
model.component('model_component').geom('model_geometry').create('work_plane', 'WorkPlane');
model.component('model_component').geom('model_geometry').feature('work_plane').set('quickz', '-L_borehole');
model.component('model_component').geom('model_geometry').feature('work_plane').set('unite', true);
model.component('model_component').geom('model_geometry').feature('work_plane').label('Work Plane');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.create('bedrock_rectangle', 'Rectangle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('bedrock_rectangle').set('pos', {'-(W_model+0.5*borehole_spacing)' '0'});
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('bedrock_rectangle').set('size', {'W_model+0.5*borehole_spacing' 'W_model'});
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('bedrock_rectangle').label('Bedrock Rectangle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.create('borehole_circle', 'Circle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('borehole_circle').set('pos', {'-0.5*borehole_spacing' '0'});
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('borehole_circle').set('r', 'r_borehole');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('borehole_circle').set('angle', 180);
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('borehole_circle').label('Borehole Circle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.create('outer_circle', 'Circle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('outer_circle').set('pos', {'-0.5*borehole_spacing' '0'});
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('outer_circle').set('r', 'r_outer');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('outer_circle').set('angle', 180);
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('outer_circle').label('Outer Circle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.create('inner_circle', 'Circle');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('inner_circle').set('pos', {'-0.5*borehole_spacing' '0'});
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('inner_circle').set('r', 'r_inner');
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('inner_circle').set('angle', 180);
model.component('model_component').geom('model_geometry').feature('work_plane').geom.feature('inner_circle').label('Inner Circle');
model.component('model_component').geom('model_geometry').create('extrude', 'Extrude');
model.component('model_component').geom('model_geometry').feature('extrude').setIndex('distance', 'L_borehole', 0);
model.component('model_component').geom('model_geometry').feature('extrude').selection('input').set({'work_plane'});
model.component('model_component').geom('model_geometry').feature('extrude').label('Work Plane Extrude Operation');
model.component('model_component').geom('model_geometry').create('bottom_bedrock_block', 'Block');
model.component('model_component').geom('model_geometry').feature('bottom_bedrock_block').set('pos', {'-(W_model+0.5*borehole_spacing)' '0' '-H_model'});
model.component('model_component').geom('model_geometry').feature('bottom_bedrock_block').set('size', {'W_model+0.5*borehole_spacing' 'W_model' 'H_model-L_borehole'});
model.component('model_component').geom('model_geometry').feature('bottom_bedrock_block').label('Bottom Bedrock Block');
model.component('model_component').geom('model_geometry').run;
model.component('model_component').geom('model_geometry').run('fin');

model.component('model_component').variable.create('component_variables');
model.component('model_component').variable('component_variables').set('borehole_wall_heat_rate', '2*borehole_wall_integration_operator(ht.ndflux)');
model.component('model_component').variable('component_variables').set('T_outlet', 'outlet_average_operator(T)');
model.component('model_component').variable('component_variables').set('T_bottom', 'bottom_average_operator(T)');
model.component('model_component').variable('component_variables').label('Component Variables');

model.component('model_component').cpl.create('borehole_wall_integration_operator', 'Integration');
model.component('model_component').cpl('borehole_wall_integration_operator').selection.geom('model_geometry', 2);
model.component('model_component').cpl('borehole_wall_integration_operator').selection.set([11 25]);
model.component('model_component').cpl('borehole_wall_integration_operator').label('Borehole Wall Integration Operator');
model.component('model_component').cpl.create('outlet_average_operator', 'Average');
model.component('model_component').cpl('outlet_average_operator').selection.geom('model_geometry', 2);
model.component('model_component').cpl('outlet_average_operator').selection.set([21]);
model.component('model_component').cpl('outlet_average_operator').label('Outlet Average Operator');
model.component('model_component').cpl.create('bottom_average_operator', 'Average');
model.component('model_component').cpl('bottom_average_operator').selection.geom('model_geometry', 2);
model.component('model_component').cpl('bottom_average_operator').selection.set([12]);
model.component('model_component').cpl('bottom_average_operator').label('Bottom Average Operator');

model.component('model_component').physics.create('ht', 'HeatTransfer', 'model_geometry');
model.component('model_component').physics('ht').label('Heat Transfer Physics');
model.component('model_component').physics('ht').prop('ShapeProperty').set('order_temperature', 1);
model.component('model_component').physics('ht').feature('init1').set('Tinit', 'T_initial(z)');
model.component('model_component').physics('ht').feature('solid1').set('k_mat', 'userdef');
model.component('model_component').physics('ht').feature('solid1').set('k', {'k_rock' '0' '0' '0' 'k_rock' '0' '0' '0' 'k_rock'});
model.component('model_component').physics('ht').feature('solid1').set('rho_mat', 'userdef');
model.component('model_component').physics('ht').feature('solid1').set('rho', 'rho_rock');
model.component('model_component').physics('ht').feature('solid1').set('Cp_mat', 'userdef');
model.component('model_component').physics('ht').feature('solid1').set('Cp', 'Cp_rock');
model.component('model_component').physics('ht').feature('solid1').label('Bedrock Solid Model');
model.component('model_component').physics('ht').create('pipe_wall_solid_model', 'SolidHeatTransferModel', 3);
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').selection.set([4]);
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').set('k_mat', 'userdef');
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').set('k', {'k_pipe' '0' '0' '0' 'k_pipe' '0' '0' '0' 'k_pipe'});
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').set('rho_mat', 'userdef');
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').set('rho', 'rho_pipe');
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').set('Cp_mat', 'userdef');
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').set('Cp', 'Cp_pipe');
model.component('model_component').physics('ht').feature('pipe_wall_solid_model').label('Pipe Wall Solid Model');
model.component('model_component').physics('ht').create('inner_fluid_model', 'FluidHeatTransferModel', 3);
model.component('model_component').physics('ht').feature('inner_fluid_model').selection.set([5]);
model.component('model_component').physics('ht').feature('inner_fluid_model').set('k_mat', 'userdef');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('k', {'1000' '0' '0' '0' '1000' '0' '0' '0' 'k_fluid'});
model.component('model_component').physics('ht').feature('inner_fluid_model').set('rho_mat', 'userdef');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('rho', 'rho_fluid');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('Cp_mat', 'userdef');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('Cp', 'Cp_fluid');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('gamma_mat', 'userdef');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('gamma', '1.0');
model.component('model_component').physics('ht').feature('inner_fluid_model').set('minput_velocity', {'0' '0' 'v_inner'});
model.component('model_component').physics('ht').feature('inner_fluid_model').label('Inner Fluid Model');
model.component('model_component').physics('ht').create('outer_fluid_model', 'FluidHeatTransferModel', 3);
model.component('model_component').physics('ht').feature('outer_fluid_model').selection.set([3]);
model.component('model_component').physics('ht').feature('outer_fluid_model').set('k_mat', 'userdef');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('k', {'1000' '0' '0' '0' '1000' '0' '0' '0' 'k_fluid'});
model.component('model_component').physics('ht').feature('outer_fluid_model').set('rho_mat', 'userdef');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('rho', 'rho_fluid');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('Cp_mat', 'userdef');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('Cp', 'Cp_fluid');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('gamma_mat', 'userdef');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('gamma', '1.0');
model.component('model_component').physics('ht').feature('outer_fluid_model').set('minput_velocity', {'0' '0' '-v_outer'});
model.component('model_component').physics('ht').feature('outer_fluid_model').label('Outer Fluid Model');
model.component('model_component').physics('ht').create('bottom_heat_flux_boundary', 'HeatFluxBoundary', 2);
model.component('model_component').physics('ht').feature('bottom_heat_flux_boundary').selection.set([3]);
model.component('model_component').physics('ht').feature('bottom_heat_flux_boundary').set('q0', 'q_geothermal');
model.component('model_component').physics('ht').feature('bottom_heat_flux_boundary').label('Bottom Heat Flux Boundary');
model.component('model_component').physics('ht').create('surface_heat_flux_boundary', 'HeatFluxBoundary', 2);
model.component('model_component').physics('ht').feature('surface_heat_flux_boundary').selection.set([7]);
model.component('model_component').physics('ht').feature('surface_heat_flux_boundary').set('q0', '-q_geothermal');
model.component('model_component').physics('ht').feature('surface_heat_flux_boundary').label('Surface Heat Flux Boundary');
model.component('model_component').physics('ht').create('bottom_temperature_boundary', 'TemperatureBoundary', 2);
model.component('model_component').physics('ht').feature('bottom_temperature_boundary').selection.set([20]);
model.component('model_component').physics('ht').feature('bottom_temperature_boundary').set('T0', 'T_bottom');
model.component('model_component').physics('ht').feature('bottom_temperature_boundary').label('Bottom Temperature Boundary');
model.component('model_component').physics('ht').create('inlet_temperature_boundary', 'TemperatureBoundary', 2);
model.component('model_component').physics('ht').feature('inlet_temperature_boundary').selection.set([13]);
model.component('model_component').physics('ht').feature('inlet_temperature_boundary').set('T0', 'T_inlet');
model.component('model_component').physics('ht').feature('inlet_temperature_boundary').label('Inlet Temperature Boundary');

model.component('model_component').mesh.create('model_mesh');
model.component('model_component').mesh('model_mesh').create('pipe_wall_mesh', 'FreeTri');
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').selection.set([17]);
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').set('method', 'del');
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').label('Pipe Wall Mesh');
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').create('pipe_wall_mesh_size', 'Size');
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').feature('pipe_wall_mesh_size').set('custom', 'on');
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').feature('pipe_wall_mesh_size').set('hmax', 'h_borehole');
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').feature('pipe_wall_mesh_size').set('hmaxactive', true);
model.component('model_component').mesh('model_mesh').feature('pipe_wall_mesh').feature('pipe_wall_mesh_size').label('Pipe Wall Mesh Size');
model.component('model_component').mesh('model_mesh').create('inner_fluid_mesh', 'FreeTri');
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').selection.set([21]);
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').set('method', 'del');
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').label('Inner Fluid Mesh');
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').create('inner_fluid_mesh_size', 'Size');
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').feature('inner_fluid_mesh_size').set('custom', 'on');
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').feature('inner_fluid_mesh_size').set('hmax', 'h_borehole');
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').feature('inner_fluid_mesh_size').set('hmaxactive', true);
model.component('model_component').mesh('model_mesh').feature('inner_fluid_mesh').feature('inner_fluid_mesh_size').label('Inner Fluid Mesh Size');
model.component('model_component').mesh('model_mesh').create('outer_fluid_mesh', 'FreeTri');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').selection.set([13]);
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').set('method', 'del');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').label('Outer Fluid Mesh');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').create('outer_fluid_mesh_size', 'Size');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').feature('outer_fluid_mesh_size').set('custom', 'on');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').feature('outer_fluid_mesh_size').set('hmax', 'h_borehole');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').feature('outer_fluid_mesh_size').set('hmaxactive', true);
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').feature('outer_fluid_mesh_size').set('hgrad', 'g_borehole');
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').feature('outer_fluid_mesh_size').set('hgradactive', true);
model.component('model_component').mesh('model_mesh').feature('outer_fluid_mesh').feature('outer_fluid_mesh_size').label('Outer Fluid Mesh Size');
model.component('model_component').mesh('model_mesh').create('bedrock_mesh', 'FreeTri');
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').selection.set([7]);
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').set('method', 'del');
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').label('Bedrock Mesh');
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').create('bedrock_mesh_size', 'Size');
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').feature('bedrock_mesh_size').set('hauto', 3);
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').feature('bedrock_mesh_size').set('custom', 'on');
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').feature('bedrock_mesh_size').set('hgrad', 'g_rock');
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').feature('bedrock_mesh_size').set('hgradactive', true);
model.component('model_component').mesh('model_mesh').feature('bedrock_mesh').feature('bedrock_mesh_size').label('Bedrock Mesh Size');
model.component('model_component').mesh('model_mesh').create('swept_mesh', 'Sweep');
model.component('model_component').mesh('model_mesh').feature('swept_mesh').selection.geom('model_geometry', 3);
model.component('model_component').mesh('model_mesh').feature('swept_mesh').selection.set([2 3 4 5]);
model.component('model_component').mesh('model_mesh').feature('swept_mesh').label('Swepth Mesh');
model.component('model_component').mesh('model_mesh').feature('swept_mesh').create('swept_mesh_distribution', 'Distribution');
model.component('model_component').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distribution').set('type', 'predefined');
model.component('model_component').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distribution').set('elemcount', 'n_swept');
model.component('model_component').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distribution').set('elemratio', 500);
model.component('model_component').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distribution').set('method', 'geometric');
model.component('model_component').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distribution').set('symmetric', true);
model.component('model_component').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distribution').label('Swepth Mesh Distribution');
model.component('model_component').mesh('model_mesh').create('bottom_bedrock_mesh', 'FreeTet');
model.component('model_component').mesh('model_mesh').feature('bottom_bedrock_mesh').label('Bottom Bedrock Mesh');
model.component('model_component').mesh('model_mesh').feature('bottom_bedrock_mesh').create('bottom_bedrock_mesh_size', 'Size');
model.component('model_component').mesh('model_mesh').feature('bottom_bedrock_mesh').feature('bottom_bedrock_mesh_size').set('custom', 'on');
model.component('model_component').mesh('model_mesh').feature('bottom_bedrock_mesh').feature('bottom_bedrock_mesh_size').set('hgrad', 'g_bottom');
model.component('model_component').mesh('model_mesh').feature('bottom_bedrock_mesh').feature('bottom_bedrock_mesh_size').set('hgradactive', true);
model.component('model_component').mesh('model_mesh').feature('bottom_bedrock_mesh').feature('bottom_bedrock_mesh_size').label('Bottom Bedrock Mesh Size');
model.component('model_component').mesh('model_mesh').run;

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
model.sol('sol1').runAll;
model.sol('sol1').getSizeMulti;
model.sol('sol1').getSize;
model.sol('sol1').getPVals;
model.sol('sol1').getPValsImag;

model.result.numerical.remove('global_internal');
model.result.numerical.create('global_internal', 'Global');
model.result.numerical('global_internal').set('expr', 'borehole_wall_heat_rate');
model.result.numerical('global_internal').set('matherr', 'off');
model.result.numerical('global_internal').set('phase', 0);
model.result.numerical('global_internal').set('unit', {'W'});
model.result.numerical('global_internal').set('outersolnum', 1);
model.result.numerical('global_internal').set('solnum', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'  ...
'11' '12' '13' '14' '15' '16' '17' '18' '19' '20'  ...
'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'  ...
'31' '32' '33' '34' '35' '36' '37' '38' '39' '40'  ...
'41' '42' '43' '44' '45' '46' '47' '48' '49' '50'  ...
'51' '52' '53' '54' '55' '56' '57' '58' '59' '60'  ...
'61' '62' '63' '64' '65' '66' '67' '68' '69' '70'  ...
'71' '72' '73' '74'});
model.result.numerical('global_internal').set('outersolnum', 1);
model.result.numerical('global_internal').set('expr', {'borehole_wall_heat_rate'});
model.result.numerical('global_internal').set('evalmethodactive', 'off');
model.result.numerical('global_internal').set('outertype', 'none');
model.result.numerical('global_internal').set('solvertype', 'time');
model.result.numerical('global_internal').set('outersolnum', '1');
model.result.numerical('global_internal').set('solnum', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74');
model.result.numerical('global_internal').set('timeinterp', 'off');
model.result.numerical('global_internal').getData;
model.result.numerical.remove('global_internal');

model.label('temp.mph');

model.result.create('pg1', 'PlotGroup1D');
model.result('pg1').run;
model.result('pg1').create('glob1', 'Global');
model.result('pg1').feature('glob1').setIndex('expr', 'borehole_wall_heat_rate', 0);
model.result('pg1').feature('glob1').setIndex('unit', 'kW', 0);
model.result('pg1').run;
model.result('pg1').feature('glob1').setIndex('expr', 'T_outlet', 0);
model.result('pg1').feature('glob1').setIndex('unit', 'degC', 0);
model.result('pg1').run;
model.result('pg1').feature('glob1').setIndex('expr', 'T_inlet', 1);
model.result('pg1').feature('glob1').setIndex('unit', 'degC', 1);
model.result('pg1').run;
model.result.create('pg2', 'PlotGroup2D');
model.result('pg2').run;
model.result('pg2').create('con1', 'Contour');
model.result('pg2').feature('con1').set('expr', 'T-T_initial(z)');
model.result('pg2').feature('con1').set('levelmethod', 'levels');
model.result('pg2').feature('con1').set('levels', '-0.1 -0.01 -0.001');
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;

out = model;
