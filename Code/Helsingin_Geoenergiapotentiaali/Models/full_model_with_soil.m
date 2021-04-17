function out = model
%
% full_model_with_soil.m
%
% Model exported on Aug 23 2018, 10:20 by COMSOL 5.3.0.223.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\Helsingin_Geoenergiapotentiaali\Models');

model.component.create('model_comp', true);

model.param.set('L_borehole', '300[m]');
model.param.set('r_borehole', '70[mm]');
model.param.set('H_model', '500[m]');
model.param.set('borehole_spacing', '20.000[m]');
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('q_geothermal', '40[mW/m^2]');
model.param.set('T_surface', '6[degC]');
model.param.set('k_rock', '3[W/(m*K)]');
model.param.set('Cp_rock', '720[J/(kg*K)]');
model.param.set('rho_rock', '2700[kg/m^3]');
model.param.set('annual_energy_demand', '7.5[MW*h]');
model.param.set('monthly_hours', '730.5[h]');

model.func.create('piecewise', 'Piecewise');
model.func('piecewise').label('Monthly Profile');
model.func('piecewise').set('funcname', 'monthly_profile');
model.func('piecewise').set('arg', 't');
model.func('piecewise').set('extrap', 'periodic');
model.func('piecewise').set('smooth', 'contd2');
model.func('piecewise').set('smoothends', true);
model.func('piecewise').set('pieces', {'0/12' '1/12' '0.175';  ...
'1/12' '2/12' '0.107';  ...
'2/12' '3/12' '0.112';  ...
'3/12' '4/12' '0.083';  ...
'4/12' '5/12' '0.045';  ...
'5/12' '6/12' '0.037';  ...
'6/12' '7/12' '0.032';  ...
'7/12' '8/12' '0.035';  ...
'8/12' '9/12' '0.045';  ...
'9/12' '10/12' '0.087';  ...
'10/12' '11/12' '0.119';  ...
'11/12' '12/12' '0.123'});
model.func('piecewise').set('argunit', 'a');
model.func('piecewise').set('fununit', '1');
model.func.create('analytic', 'Analytic');
model.func('analytic').set('funcname', 'T_initial');
model.func('analytic').set('expr', 'T_surface-q_geothermal/k_rock*z');
model.func('analytic').set('args', 'z');
model.func('analytic').set('argunit', 'm');
model.func('analytic').set('fununit', 'K');

model.component('model_comp').geom.create('model_geom', 3);
model.component('model_comp').geom('model_geom').create('work_plane', 'WorkPlane');
model.component('model_comp').geom('model_geom').feature('work_plane').set('quickz', '-L_borehole');
model.component('model_comp').geom('model_geom').feature('work_plane').set('unite', true);
model.component('model_comp').geom('model_geom').feature('work_plane').geom.create('rectangle', 'Rectangle');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('rectangle').set('pos', {'-0.5*borehole_spacing' '-0.5*borehole_spacing'});
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('rectangle').set('size', {'borehole_spacing' 'borehole_spacing'});
model.component('model_comp').geom('model_geom').feature('work_plane').geom.create('circle', 'Circle');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('circle').set('pos', [0 0]);
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('circle').set('r', 'r_borehole');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.create('difference', 'Difference');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('difference').selection('input').set({'rectangle'});
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('difference').selection('input2').set({'circle'});
model.component('model_comp').geom('model_geom').create('extrude', 'Extrude');
model.component('model_comp').geom('model_geom').feature('extrude').setIndex('distance', 'L_borehole', 0);
model.component('model_comp').geom('model_geom').feature('extrude').selection('input').set({'work_plane'});
model.component('model_comp').geom('model_geom').create('block', 'Block');
model.component('model_comp').geom('model_geom').feature('block').set('pos', {'-0.5*borehole_spacing' '-0.5*borehole_spacing' '-H_model'});
model.component('model_comp').geom('model_geom').feature('block').set('size', {'borehole_spacing' 'borehole_spacing' 'H_model-L_borehole'});
model.component('model_comp').geom('model_geom').run;

model.component('model_comp').cpl.create('wall_aveop', 'Average');
model.component('model_comp').cpl('wall_aveop').selection.geom('model_geom', 2);
model.component('model_comp').cpl('wall_aveop').label('Wall Average Operator');
model.component('model_comp').cpl('wall_aveop').set('opname', 'wall_aveop');
model.component('model_comp').cpl('wall_aveop').selection.set([10 11 12 13 14]);
model.component('model_comp').cpl.create('wall_intop', 'Integration');
model.component('model_comp').cpl('wall_intop').selection.geom('model_geom', 2);
model.component('model_comp').cpl('wall_intop').label('Wall Integration Operator');
model.component('model_comp').cpl('wall_intop').set('opname', 'wall_intop');
model.component('model_comp').cpl('wall_intop').selection.set([10 11 12 13 14]);

model.component('model_comp').variable.create('variables');
model.component('model_comp').variable('variables').set('T_wall', 'wall_aveop(T)');
model.component('model_comp').variable('variables').set('Q_wall', 'wall_intop(-ht.ndflux)');
model.component('model_comp').variable('variables').set('heat_extraction', 'monthly_profile(t)*annual_energy_demand/monthly_hours');

model.component('model_comp').physics.create('model_physics', 'HeatTransfer', 'model_geom');
model.component('model_comp').physics('model_physics').prop('ShapeProperty').set('order_temperature', 1);
model.component('model_comp').physics('model_physics').feature('solid1').set('k_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('k', {'k_rock' '0' '0' '0' 'k_rock' '0' '0' '0' 'k_rock'});
model.component('model_comp').physics('model_physics').feature('solid1').set('rho_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('rho', 'rho_rock');
model.component('model_comp').physics('model_physics').feature('solid1').set('Cp_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('Cp', 'Cp_rock');
model.component('model_comp').physics('model_physics').feature('init1').set('Tinit', 'T_initial(z)');
model.component('model_comp').physics('model_physics').create('temp_bc', 'TemperatureBoundary', 2);
model.component('model_comp').physics('model_physics').feature('temp_bc').set('T0', 'T_surface');
model.component('model_comp').physics('model_physics').feature('temp_bc').label('Surface Temperature');
model.component('model_comp').physics('model_physics').feature('temp_bc').selection.set([7]);
model.component('model_comp').physics('model_physics').create('geo_flux_bc', 'HeatFluxBoundary', 2);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').selection.set([3]);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').set('q0', 'q_geothermal');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').label('Geothermal Heat Flux');
model.component('model_comp').physics('model_physics').create('wall_flux_bc', 'HeatFluxBoundary', 2);
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').selection.set([4 5 6 9 10 11 12 13 14 16]);
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').set('q0', '-heat_extraction/A_wall');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').label('Borehole Wall Heat Flux');
model.component('model_comp').physics('model_physics').create('periodic_bc_1', 'PeriodicHeat', 2);
model.component('model_comp').physics('model_physics').feature('periodic_bc_1').selection.set([1 4 15 16]);
model.component('model_comp').physics('model_physics').create('periodic_bc_2', 'PeriodicHeat', 2);
model.component('model_comp').physics('model_physics').feature('periodic_bc_2').selection.set([2 5 8 9]);

model.component('model_comp').mesh.create('model_mesh');
model.component('model_comp').mesh('model_mesh').create('edge_mesh', 'Edge');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').label('Borehole Collar Edge Mesh');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').selection.set([17 18 21 24]);
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').create('edge_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').label('Edge Size');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hmax', '20[mm]');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hmin', '1[mm]');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hminactive', true);
model.component('model_comp').mesh('model_mesh').create('tri_mesh', 'FreeTri');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').label('Surface Triangular Mesh');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').selection.set([7]);
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').create('tri_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').feature('tri_mesh_size').label('Triangular Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').feature('tri_mesh_size').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').create('swept_mesh', 'Sweep');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.geom('model_geom', 3);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.set([2]);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').label('Swept Mesh');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').create('swept_mesh_distr', 'Distribution');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distr').label('Swept Mesh Distribution');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distr').set('numelem', 10);
model.component('model_comp').mesh('model_mesh').create('tetra_mesh', 'FreeTet');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.geom('model_geom', 3);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.set([1]);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').label('Tetrahedral Mesh');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').create('tetra_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').label('Tetrahedral Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').run;

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
model.study('std1').feature('time').set('tunit', 'd');
model.study('std1').feature('time').set('tlist', 'range(0,10,50*365.25)');

model.sol('sol1').attach('std1');
model.sol('sol1').label('Solution');
model.sol('sol1').feature('v1').label('Dependent Variables');
model.sol('sol1').feature('v1').set('clist', 'range(0,10,50*365.25)');
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('control', 'user');
model.sol('sol1').feature('t1').set('tunit', 'd');
model.sol('sol1').feature('t1').set('tlist', 'range(0,10,50*365.25)');
model.sol('sol1').feature('t1').set('maxstepbdf', 10);
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');

model.label('full_model.mph');

model.comments(['Full model\n\n']);

model.func('analytic').setIndex('plotargs', -300, 0, 1);
model.func('analytic').setIndex('plotargs', 0, 0, 2);

model.component('model_comp').view('view1').set('renderwireframe', true);

model.param.set('H_soil', '20[m]');

model.component('model_comp').geom('model_geom').feature('extrude').setIndex('distance', 'L_borehole-H_soil', 0);
model.component('model_comp').geom('model_geom').runPre('fin');
model.component('model_comp').geom('model_geom').feature('extrude').setIndex('distance', 'L_borehole', 0);
model.component('model_comp').geom('model_geom').feature.remove('extrude');
model.component('model_comp').geom('model_geom').feature.remove('work_plane');
model.component('model_comp').geom('model_geom').feature.remove('block');
model.component('model_comp').geom('model_geom').create('blk1', 'Block');
model.component('model_comp').geom('model_geom').feature('blk1').set('size', {'borehole_spacing' '1' '1'});
model.component('model_comp').geom('model_geom').feature('blk1').setIndex('size', 'borehole_spacing', 1);
model.component('model_comp').geom('model_geom').feature('blk1').set('pos', {'-0.5*borehole_spacing' '0' '0'});
model.component('model_comp').geom('model_geom').feature('blk1').setIndex('pos', '-0.5*borehole_spacing', 1);
model.component('model_comp').geom('model_geom').feature('blk1').setIndex('pos', '-L_borehole', 2);
model.component('model_comp').geom('model_geom').runPre('fin');
model.component('model_comp').geom('model_geom').feature('blk1').setIndex('size', 'L_borehole', 2);
model.component('model_comp').geom('model_geom').runPre('fin');
model.component('model_comp').geom('model_geom').feature.duplicate('blk2', 'blk1');
model.component('model_comp').geom('model_geom').feature.remove('blk2');
model.component('model_comp').geom('model_geom').run('blk1');
model.component('model_comp').geom('model_geom').create('cyl1', 'Cylinder');
model.component('model_comp').geom('model_geom').feature('cyl1').set('r', 'r_borehole');
model.component('model_comp').geom('model_geom').feature('cyl1').set('h', 'L_borehole');
model.component('model_comp').geom('model_geom').feature('cyl1').set('pos', {'0' '0' '-L_borehole'});
model.component('model_comp').geom('model_geom').runPre('fin');
model.component('model_comp').geom('model_geom').run('cyl1');
model.component('model_comp').geom('model_geom').create('dif1', 'Difference');
model.component('model_comp').geom('model_geom').feature('dif1').selection('input').set({'blk1'});
model.component('model_comp').geom('model_geom').feature('dif1').selection('input2').set({'cyl1'});
model.component('model_comp').geom('model_geom').feature.duplicate('blk2', 'blk1');
model.component('model_comp').geom('model_geom').feature('blk2').setIndex('size', 'H_model-L_borehole', 2);
model.component('model_comp').geom('model_geom').feature('blk2').setIndex('pos', '-H_model', 2);
model.component('model_comp').geom('model_geom').runPre('fin');
model.component('model_comp').geom('model_geom').run;

model.component('model_comp').mesh('model_mesh').run;

model.sol('sol1').feature('t1').set('control', 'time');

model.param.remove('H_soil');
model.param.set('H_soil', '20[m]');

model.component('model_comp').geom('model_geom').feature.duplicate('blk3', 'blk1');
model.component('model_comp').geom('model_geom').feature.move('blk2', 2);
model.component('model_comp').geom('model_geom').feature.move('blk2', 1);
model.component('model_comp').geom('model_geom').feature('blk3').setIndex('size', 'H_model-L_borehole', 2);
model.component('model_comp').geom('model_geom').feature('blk3').setIndex('pos', '-H_model', 2);
model.component('model_comp').geom('model_geom').feature('blk1').setIndex('size', 'H_soil', 2);
model.component('model_comp').geom('model_geom').feature('blk1').setIndex('pos', '-H_soil', 2);
model.component('model_comp').geom('model_geom').feature('blk2').setIndex('size', 'L_borehole-H_soil', 2);
model.component('model_comp').geom('model_geom').feature('blk2').setIndex('pos', '-L_borehole', 2);
model.component('model_comp').geom('model_geom').run('blk2');
model.component('model_comp').geom('model_geom').run('cyl1');
model.component('model_comp').geom('model_geom').feature('dif1').selection('input').set({'blk1' 'blk2'});
model.component('model_comp').geom('model_geom').runPre('fin');
model.component('model_comp').geom('model_geom').run;

model.component('model_comp').physics('model_physics').create('solid2', 'SolidHeatTransferModel', 3);
model.component('model_comp').physics('model_physics').feature('solid2').selection.set([3]);

model.param.set('k_soil', '1.5[W/(m*K)]');
model.param.set('Cp_soil', '1500[J/(kg*K)]');
model.param.set('rho_soil', '1600[kg/m^3]');

model.component('model_comp').physics('model_physics').feature('solid2').set('k_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid2').set('k', {'k_soil' '0' '0' '0' 'k_soil' '0' '0' '0' 'k_soil'});
model.component('model_comp').physics('model_physics').feature('solid2').set('rho_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid2').set('rho', 'rho_soil');
model.component('model_comp').physics('model_physics').feature('solid2').set('Cp_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid2').set('Cp', 'Cp_soil');
model.component('model_comp').physics('model_physics').feature('periodic_bc_2').selection.set([2 5 8 12 13]);
model.component('model_comp').physics('model_physics').feature('periodic_bc_1').selection.set([1 4 7 23 24 25]);
model.component('model_comp').physics('model_physics').feature('periodic_bc_2').selection.set([2 5 8 11 12 13]);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').selection.set([3 6]);

model.func.remove('analytic');
model.func.create('pw1', 'Piecewise');
model.func('pw1').setIndex('pieces', '-H_model', 0, 0);
model.func('pw1').setIndex('pieces', '-H_soil', 0, 1);
model.func('pw1').setIndex('pieces', 1, 0, 2);
model.func('pw1').setIndex('pieces', '-H_soil', 1, 0);
model.func('pw1').setIndex('pieces', 0, 1, 1);
model.func('pw1').setIndex('pieces', 2, 1, 2);
model.func('pw1').set('funcname', 'T_initial');
model.func('pw1').set('arg', 'z');
model.func('pw1').set('argunit', 'm');
model.func('pw1').set('fununit', 'K');
model.func('pw1').setIndex('pieces', 'T_surface', 1, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*z', 1, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*z', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*H_soil', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface-q_geothermal/k_soil*z', 1, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*H_soil-q_geothermal/k_rock*z', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*H_soil', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*-z', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*H_soil', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*H_soil-q_geothermal/k_rock*(z-H_soil)', 0, 2);
model.func('pw1').setIndex('pieces', 'T_surface+q_geothermal/k_soil*H_soil-q_geothermal/k_rock*(z+H_soil)', 0, 2);
model.func('pw1').set('smooth', 'contd1');
model.func('pw1').set('smoothzone', '0.2');
model.func('pw1').set('extrap', 'none');
model.func('pw1').set('smooth', 'none');

model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.set([2 3]);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.set([1]);
model.component('model_comp').mesh('model_mesh').run;
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.remove([2]);
model.component('model_comp').mesh('model_mesh').feature.duplicate('swept_mesh1', 'swept_mesh');
model.component('model_comp').mesh('model_mesh').feature.move('swept_mesh1', 4);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').label('Soil Swept Mesh');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').label('Rock Swept Mesh');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature.remove('swept_mesh_distr');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('size1').set('custom', true);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('size1').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('size1').set('hmax', '1[m]');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').feature.remove('swept_mesh_distr');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').selection.set([2]);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').feature('size1').set('custom', true);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').feature('size1').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh1').feature('size1').set('hmax', 10);
model.component('model_comp').mesh('model_mesh').run('swept_mesh1');
model.component('model_comp').mesh('model_mesh').run;

model.label('full_model_with_soil.mph');

model.param.set('H_soil', '50[m]');

model.component('model_comp').geom('model_geom').run('fin');

model.component('model_comp').mesh('model_mesh').run;

model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').label('Temperature (model_physics)');
model.result('pg1').set('data', 'dset1');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').feature('surf1').label('Surface');
model.result('pg1').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg1').feature('surf1').set('data', 'parent');
model.result.create('pg2', 'PlotGroup3D');
model.result('pg2').label('Isothermal Contours (model_physics)');
model.result('pg2').set('data', 'dset1');
model.result('pg2').feature.create('iso1', 'Isosurface');
model.result('pg2').feature('iso1').label('Isosurface');
model.result('pg2').feature('iso1').set('number', 10);
model.result('pg2').feature('iso1').set('colortable', 'ThermalLight');
model.result('pg2').feature('iso1').set('data', 'parent');
model.result.remove('pg2');
model.result.remove('pg1');

model.func('pw1').set('extrap', 'interior');

model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').label('Temperature (model_physics)');
model.result('pg1').set('data', 'dset1');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').feature('surf1').label('Surface');
model.result('pg1').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg1').feature('surf1').set('data', 'parent');
model.result.create('pg2', 'PlotGroup3D');
model.result('pg2').label('Isothermal Contours (model_physics)');
model.result('pg2').set('data', 'dset1');
model.result('pg2').feature.create('iso1', 'Isosurface');
model.result('pg2').feature('iso1').label('Isosurface');
model.result('pg2').feature('iso1').set('number', 10);
model.result('pg2').feature('iso1').set('colortable', 'ThermalLight');
model.result('pg2').feature('iso1').set('data', 'parent');
model.result.remove('pg2');
model.result.remove('pg1');

out = model;
