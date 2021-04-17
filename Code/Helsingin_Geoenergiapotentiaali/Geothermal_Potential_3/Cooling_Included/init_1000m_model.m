function model = init_1000m_model(borehole_spacing, cooling_fraction, tlist)

% -------------------------------------------------------------------------
% Sets up model.
% -------------------------------------------------------------------------

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Bedrock Model');

ModelUtil.showProgress(true);

model_comp = model.component.create('model_comp', true);

% -------------------------------------------------------------------------
% Sets up model parameters.
% -------------------------------------------------------------------------

model.param.set('borehole_spacing', sprintf('%.3f[m]', borehole_spacing));
model.param.set('L_borehole', '1000[m]');
model.param.set('H_model', '1500[m]');
model.param.set('r_borehole', '70[mm]');
model.param.set('T_surface', '6.764[degC]');
model.param.set('q_geothermal', '40.548[mW/m^2]');
model.param.set('k_rock', '2.87[W/(m*K)]');
model.param.set('Cp_rock', '725[J/(kg*K)]');
model.param.set('rho_rock', '2707[kg/m^3]');
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('annual_heating_demand', '36.372[MW*h]');
model.param.set('annual_cooling_demand', sprintf('%.3f*annual_heating_demand', cooling_fraction));
model.param.set('monthly_hours', '730.5[h]');

% -------------------------------------------------------------------------
% Creates monthly profile function.
% -------------------------------------------------------------------------

monthly_heating_profile = model.func.create('monthly_heating_profile', 'Piecewise');
monthly_heating_profile.label('Monthly Heating Profile');
monthly_heating_profile.set('funcname', 'monthly_heating_profile');
monthly_heating_profile.set('arg', 't');
monthly_heating_profile.set('extrap', 'periodic');
monthly_heating_profile.set('pieces', { '0/12',  '1/12', '0.175'; ...
                                        '1/12',  '2/12', '0.111'; ...
                                        '2/12',  '3/12', '0.111'; ...
                                        '3/12',  '4/12', '0.083'; ...
                                        '4/12',  '5/12', '0.045'; ...
                                        '5/12',  '6/12', '0.037'; ...
                                        '6/12',  '7/12', '0.032'; ...
                                        '7/12',  '8/12', '0.034'; ...
                                        '8/12',  '9/12', '0.044'; ...
                                        '9/12', '10/12', '0.086'; ...
                                        '10/12', '11/12', '0.119'; ...
                                        '11/12', '12/12', '0.123'});
monthly_heating_profile.set('argunit', 'a');
monthly_heating_profile.set('fununit', '1');

monthly_cooling_profile = model.func.create('monthly_cooling_profile', 'Piecewise');
monthly_cooling_profile.label('Monthly Cooling Profile');
monthly_cooling_profile.set('funcname', 'monthly_cooling_profile');
monthly_cooling_profile.set('arg', 't');
monthly_cooling_profile.set('extrap', 'periodic');
monthly_cooling_profile.set('pieces', { '0/12',  '1/12', '0.000'; ...
                                        '1/12',  '2/12', '0.000'; ...
                                        '2/12',  '3/12', '0.000'; ...
                                        '3/12',  '4/12', '0.000'; ...
                                        '4/12',  '5/12', '0.105'; ...
                                        '5/12',  '6/12', '0.200'; ...
                                        '6/12',  '7/12', '0.300'; ...
                                        '7/12',  '8/12', '0.295'; ...
                                        '8/12',  '9/12', '0.100'; ...
                                        '9/12', '10/12', '0.000'; ...
                                        '10/12', '11/12', '0.000'; ...
                                        '11/12', '12/12', '0.000'});
monthly_cooling_profile.set('argunit', 'a');
monthly_cooling_profile.set('fununit', '1');

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

model_geom = model_comp.geom.create('model_geom', 3);

work_plane = model_geom.create('work_plane', 'WorkPlane');
work_plane.set('quickz', '-L_borehole');
work_plane.set('unite', true);

rectangle = work_plane.geom.create('rectangle', 'Rectangle');
rectangle.set('pos', [0 0]);
rectangle.set('size', {'0.5*borehole_spacing' '0.5*borehole_spacing'});

circle = work_plane.geom.create('circle', 'Circle');
circle.set('pos', [0, 0]);
circle.set('r', 'r_borehole');
circle.set('angle', 90);

difference = work_plane.geom.create('difference', 'Difference');
difference.selection('input').set({'rectangle'});
difference.selection('input2').set({'circle'});

extrude = model_geom.create('extrude', 'Extrude');
extrude.setIndex('distance', 'L_borehole', 0);
extrude.selection('input').set({'work_plane'});

block = model_geom.create('block', 'Block');
block.set('pos', {'0' '0' '-H_model'});
block.set('size', {'0.5*borehole_spacing' '0.5*borehole_spacing' 'H_model-L_borehole'});

model_geom.run();

% -------------------------------------------------------------------------
% Creates component couplings.
% -------------------------------------------------------------------------

wall_aveop = model_comp.cpl.create('wall_aveop', 'Average');
wall_aveop.selection.geom('model_geom', 2);
wall_aveop.label('Wall Average Operator');
wall_aveop.set('opname', 'wall_aveop');
wall_aveop.selection.set([4 6]);

wall_minop = model_comp.cpl.create('wall_minop', 'Minimum');
wall_minop.selection.geom('model_geom', 2);
wall_minop.label('Wall Minimum Operator');
wall_minop.set('opname', 'wall_minop');
wall_minop.selection.set([4 6]);

wall_intop = model_comp.cpl.create('wall_intop', 'Integration');
wall_intop.selection.geom('model_geom', 2);
wall_intop.label('Wall Integration Operator');
wall_intop.set('opname', 'wall_intop');
wall_intop.selection.set([4 6]);

surface_intop = model_comp.cpl.create('surface_intop', 'Integration');
surface_intop.selection.geom('model_geom', 2);
surface_intop.label('Surface Integration Operator');
surface_intop.set('opname', 'surface_intop');
surface_intop.selection.set([8]);

% -------------------------------------------------------------------------
% Creates component variables.
% -------------------------------------------------------------------------

variables = model_comp.variable.create('variables');
variables.set('T_wall_ave', 'wall_aveop(T)');
variables.set('T_wall_min', 'wall_minop(T)');
variables.set('downward_flux', '-ht.ndflux*(ht.dfluxz<0)');
variables.set('Q_wall', '4*wall_intop(ht.ndflux)');
variables.set('Q_surface', '4*surface_intop(downward_flux)');
variables.set('heat_extraction', 'monthly_heating_profile(t)*annual_heating_demand/monthly_hours');
variables.set('heat_injection', 'monthly_cooling_profile(t)*annual_cooling_demand/monthly_hours');

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

temp_bc = model_physics.create('temp_bc', 'TemperatureBoundary', 2);
temp_bc.set('T0', 'T_surface');
temp_bc.label('Surface Temperature');
temp_bc.selection.set([8]);

geo_flux_bc = model_physics.create('geo_flux_bc', 'HeatFluxBoundary', 2);
geo_flux_bc.set('q0', 'q_geothermal');
geo_flux_bc.label('Geothermal Heat Flux');
geo_flux_bc.selection.set([3]);

wall_flux_bc = model_physics.create('wall_flux_bc', 'HeatFluxBoundary', 2);
wall_flux_bc.set('q0', '(heat_injection-heat_extraction)/A_wall');
wall_flux_bc.label('Borehole Wall Heat Flux');
wall_flux_bc.selection.set([4 6]);

% -------------------------------------------------------------------------
% Creates mesh.
% -------------------------------------------------------------------------

model_mesh = model_comp.mesh.create('model_mesh');

edge_mesh = model_mesh.create('edge_mesh', 'Edge');
edge_mesh.label('Borehole Collar Edge Mesh');
edge_mesh.selection.set([10]);

edge_mesh_size = edge_mesh.create('edge_mesh_size', 'Size');
edge_mesh_size.label('Edge Size');
edge_mesh_size.set('custom', 'on');
edge_mesh_size.set('hmaxactive', true);
edge_mesh_size.set('hminactive', true);
edge_mesh_size.set('hmin', '5[mm]'); % <--- minimum segment size
edge_mesh_size.set('hmax', '5[mm]'); % <--- maximum segment size

tri_mesh = model_mesh.create('tri_mesh', 'FreeTri');
tri_mesh.selection.set([8]);
tri_mesh.label('Surface Triangular Mesh');
tri_mesh.set('method', 'del');

tri_mesh_size = tri_mesh.create('tri_mesh_size', 'Size');
tri_mesh_size.label('Triangular Mesh Size');
tri_mesh_size.set('hauto', 1);
tri_mesh_size.set('custom', 'on');
tri_mesh_size.set('hminactive', true);
tri_mesh_size.set('hmaxactive', true);
tri_mesh_size.set('hgradactive', true);
tri_mesh_size.set('hmin', '1[mm]'); % <--- minimum element size
tri_mesh_size.set('hmax', '5[m]'); % <--- maximum element size
tri_mesh_size.set('hgrad', 1.2); % <--- element growth rate

swept_mesh = model_mesh.create('swept_mesh', 'Sweep');
swept_mesh.selection.geom('model_geom', 3);
swept_mesh.label('Swept Mesh');
swept_mesh.selection.set([2]);

swept_mesh_distr = swept_mesh.create('swept_mesh_distr', 'Distribution');
swept_mesh_distr.label('Swept Mesh Distribution');
swept_mesh_distr.set('type', 'predefined');
swept_mesh_distr.set('method', 'geometric');
swept_mesh_distr.set('symmetric', true);
swept_mesh_distr.set('elemcount', 30);
swept_mesh_distr.set('elemratio', 10);

tetra_mesh = model_mesh.create('tetra_mesh', 'FreeTet');
tetra_mesh.selection.geom('model_geom', 3);
tetra_mesh.label('Tetrahedral Mesh');
tetra_mesh.set('method', 'del');
tetra_mesh.selection.set([1]);

tetra_mesh_size = tetra_mesh.create('tetra_mesh_size', 'Size');
tetra_mesh_size.label('Tetrahedral Mesh Size');
tetra_mesh_size.set('hauto', 1);
tetra_mesh_size.set('custom', 'on');
tetra_mesh_size.set('hmaxactive', true);
tetra_mesh_size.set('hminactive', true);
tetra_mesh_size.set('hgradactive', true);
tetra_mesh_size.set('hgrad', 1.2); % <--- element growth rate
tetra_mesh_size.set('hmin', '1[mm]'); % <--- minimum element size
%tetra_mesh_size.set('hmax', '5[m]'); % <--- maximum element size
tetra_mesh_size.set('hmax', '10[m]'); % <--- maximum element size
tetra_mesh_size.set('hgradactive', true);

model_mesh.run();

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
model.study('std1').feature('time').set('tlist', tlist);

model.sol('sol1').attach('std1');
model.sol('sol1').label('Solution');
model.sol('sol1').feature('v1').label('Dependent Variables');
model.sol('sol1').feature('v1').set('clist', {'range(0,1/36,50)'});
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', tlist);
model.sol('sol1').feature('t1').set('maxstepbdf', '1/36');
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
