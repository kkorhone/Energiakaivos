function model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, borehole_length)

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Bedrock_Model');

ModelUtil.showProgress(true);

model_comp = model.component.create('model_comp', true);

% -------------------------------------------------------------------------
% Sets up model parameters.
% -------------------------------------------------------------------------

model.param.set('L_borehole', sprintf('%.3f[m]', borehole_length));
model.param.set('r_borehole', '70[mm]');
model.param.set('H_model', '5000[m]');
model.param.set('r_model', '5000[m]');
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('annual_energy_demand', '12[MW*h]');
model.param.set('monthly_hours', '730.5[h]');
model.param.set('h_buffer', '1[m]');
model.param.set('h_vertical', '100[mm]');
model.param.set('h_horizontal', '5[mm]');

% -------------------------------------------------------------------------
% Creates monthly profile function.
% -------------------------------------------------------------------------

piecewise = model.func.create('piecewise', 'Piecewise');
piecewise.label('Monthly Profile');
piecewise.set('funcname', 'monthly_profile');
piecewise.set('arg', 't');
piecewise.set('extrap', 'periodic');
piecewise.set('smooth', 'contd2');
piecewise.set('smoothends', true);
piecewise.set('pieces', { '0/12',  '1/12', '0.175'; ...
                          '1/12',  '2/12', '0.107'; ...
                          '2/12',  '3/12', '0.112'; ...
                          '3/12',  '4/12', '0.083'; ...
                          '4/12',  '5/12', '0.045'; ...
                          '5/12',  '6/12', '0.037'; ...
                          '6/12',  '7/12', '0.032'; ...
                          '7/12',  '8/12', '0.035'; ...
                          '8/12',  '9/12', '0.045'; ...
                          '9/12', '10/12', '0.087'; ...
                         '10/12', '11/12', '0.119'; ...
                         '11/12', '12/12', '0.123'});
piecewise.set('argunit', 'a');
piecewise.set('fununit', '1');

% -------------------------------------------------------------------------
% Creates initial temperature function.
% -------------------------------------------------------------------------

analytic = model.func.create('analytic', 'Analytic');
analytic.label('Initial Temperature Function');
analytic.set('funcname', 'T_initial');
analytic.set('expr', 'T_surface-q_geothermal/k_rock*z');
analytic.set('args', {'z'});
analytic.set('argunit', 'm');
analytic.set('fununit', 'K');

% -------------------------------------------------------------------------
% Creates model geometry.
% -------------------------------------------------------------------------

model_geom = model_comp.geom.create('model_geom', 2);

model_geom.axisymmetric(true);

model_geom.create('bedrock_polygon', 'Polygon');
model_geom.feature('bedrock_polygon').label('Bedrock Polygon');
model_geom.feature('bedrock_polygon').set('x', '0 r_borehole+h_buffer r_borehole+h_buffer r_model r_model 0');
model_geom.feature('bedrock_polygon').set('y', '-L_borehole-h_buffer -L_borehole-h_buffer 0 0 -H_model -H_model');

model_geom.create('buffer_polygon', 'Polygon');
model_geom.feature('buffer_polygon').label('Buffer Polygon');
model_geom.feature('buffer_polygon').set('x', '0 0 r_borehole r_borehole r_borehole+h_buffer r_borehole+h_buffer');
model_geom.feature('buffer_polygon').set('y', '-L_borehole-h_buffer -L_borehole -L_borehole 0 0 0-L_borehole-h_buffer');

model_geom.run();

% -------------------------------------------------------------------------
% Creates component couplings.
% -------------------------------------------------------------------------

wall_minop = model_comp.cpl.create('wall_minop', 'Minimum');
wall_minop.selection.geom('model_geom', 1);
wall_minop.label('Wall Minimum Operator');
wall_minop.set('opname', 'wall_minop');
wall_minop.selection.set([5 6]);

wall_aveop = model_comp.cpl.create('wall_aveop', 'Average');
wall_aveop.selection.geom('model_geom', 1);
wall_aveop.label('Wall Average Operator');
wall_aveop.set('opname', 'wall_aveop');
wall_aveop.selection.set([5 6]);

wall_intop = model_comp.cpl.create('wall_intop', 'Integration');
wall_intop.selection.geom('model_geom', 1);
wall_intop.label('Wall Integration Operator');
wall_intop.set('opname', 'wall_intop');
wall_intop.selection.set([5 6]);

% -------------------------------------------------------------------------
% Creates component variables.
% -------------------------------------------------------------------------

variables = model_comp.variable.create('variables');
variables.set('T_wall_min', 'wall_minop(T)');
variables.set('T_wall_ave', 'wall_aveop(T)');
variables.set('Q_wall', 'wall_intop(-ht.ndflux)');
variables.set('heat_extraction', 'monthly_profile(t)*annual_energy_demand/monthly_hours');

% -------------------------------------------------------------------------
% Creates physics.
% -------------------------------------------------------------------------

model_physics = model_comp.physics.create('model_physics', 'HeatTransfer', 'model_geom');
model_physics.prop('ShapeProperty').set('order_temperature', 1);
model_physics.feature('solid1').set('k_mat', 'userdef');
model_physics.feature('solid1').set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
model_physics.feature('solid1').set('rho_mat', 'userdef');
model_physics.feature('solid1').set('rho', 'rho_rock');
model_physics.feature('solid1').set('Cp_mat', 'userdef');
model_physics.feature('solid1').set('Cp', 'Cp_rock');
model_physics.feature('init1').set('Tinit', 'T_initial(z)');

temp_bc = model_physics.create('temp_bc', 'TemperatureBoundary', 1);
temp_bc.set('T0', 'T_surface');
temp_bc.label('Surface Temperature');
temp_bc.selection.set([7 9]);

geo_flux_bc = model_physics.create('geo_flux_bc', 'HeatFluxBoundary', 1);
geo_flux_bc.set('q0', 'q_geothermal');
geo_flux_bc.label('Geothermal Heat Flux');
geo_flux_bc.selection.set([2]);

wall_flux_bc = model_physics.create('wall_flux_bc', 'HeatFluxBoundary', 1);
wall_flux_bc.set('q0', '-heat_extraction/A_wall');
wall_flux_bc.label('Borehole Wall Heat Flux');
wall_flux_bc.selection.set([5 6]);

% -------------------------------------------------------------------------
% Creates mesh.
% -------------------------------------------------------------------------

model_mesh = model_comp.mesh.create('model_mesh');

model_mesh.create('edg1', 'Edge');
model_mesh.feature('edg1').label('Borehole Wall Edge');
model_mesh.feature('edg1').selection.set([5 6]);

model_mesh.feature('edg1').create('size1', 'Size');
model_mesh.feature('edg1').feature('size1').selection.set([5]);
model_mesh.feature('edg1').feature('size1').label('Horizontal Edge Size');
model_mesh.feature('edg1').feature('size1').set('hauto', 1);
model_mesh.feature('edg1').feature('size1').set('custom', 'on');
model_mesh.feature('edg1').feature('size1').set('hmax', 'h_horizontal');
model_mesh.feature('edg1').feature('size1').set('hmaxactive', true);

model_mesh.feature('edg1').create('size2', 'Size');
model_mesh.feature('edg1').feature('size2').selection.set([6]);
model_mesh.feature('edg1').feature('size2').label('Vertical Edge Size');
model_mesh.feature('edg1').feature('size2').set('custom', 'on');
model_mesh.feature('edg1').feature('size2').set('hmax', 'h_vertical');
model_mesh.feature('edg1').feature('size2').set('hmaxactive', true);
model_mesh.feature('edg1').feature('size2').set('hmin', 3);
model_mesh.feature('edg1').feature('size2').set('hminactive', false);

model_mesh.create('ftri1', 'FreeTri');
model_mesh.feature('ftri1').selection.geom('model_geom', 2);
model_mesh.feature('ftri1').selection.set([2]);
model_mesh.feature('ftri1').label('Buffer Mesh');
model_mesh.feature('ftri1').set('method', 'del');

model_mesh.feature('ftri1').create('size1', 'Size');
model_mesh.feature('ftri1').feature('size1').label('Buffer Mesh Size');
model_mesh.feature('ftri1').feature('size1').set('hauto', 1);

model_mesh.create('ftri2', 'FreeTri');
model_mesh.feature('ftri2').selection.geom('model_geom', 2);
model_mesh.feature('ftri2').selection.set([1]);
model_mesh.feature('ftri2').label('Rock Mesh');
model_mesh.feature('ftri2').set('method', 'del');

model_mesh.feature('ftri2').create('size1', 'Size');
model_mesh.feature('ftri2').feature('size1').label('Rock Mesh Size');
model_mesh.feature('ftri2').feature('size1').set('custom', 'on');
model_mesh.feature('ftri2').feature('size1').set('hgrad', 1.1);
model_mesh.feature('ftri2').feature('size1').set('hgradactive', true);

model_mesh.run();

model.frame('mesh1').sorder(1);

% -------------------------------------------------------------------------
% Study and solution.
% -------------------------------------------------------------------------

model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('dDef');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.study('std1').label('Study');
model.study('std1').feature('time').set('tunit', 'a');
model.study('std1').feature('time').set('tlist', 'range(0,1/36,50)');

model.sol('sol1').attach('std1');
model.sol('sol1').label('Solution');
model.sol('sol1').feature('v1').label('Dependent Variables');
model.sol('sol1').feature('v1').set('clist', {'range(0,1/36,50)'});
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', 'range(0,1/36,50)');
model.sol('sol1').feature('t1').set('maxstepbdf', '1/36');
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
