function model = init_full_model_no_soil(k_rock, Cp_rock, rho_rock, T_surface, q_geothermal)

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\Helsingin_Geoenergiapotentiaali\Models');

model.label('full_model_no_soil.mph');

model.comments(['Full model\n\n']);

model.param.set('L_borehole', '300[m]');
model.param.set('r_borehole', '70[mm]');
model.param.set('H_model', '500[m]');
model.param.set('borehole_spacing', '20.000[m]');
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.0f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.0f[kg/m^3]', rho_rock));
model.param.set('annual_energy_demand', '7.5[MW*h]');
model.param.set('monthly_hours', '730.5[h]');

model.component.create('model_comp', true);

model.component('model_comp').geom.create('model_geom', 3);

model.func.create('piecewise', 'Piecewise');
model.func.create('analytic', 'Analytic');
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
model.func('analytic').set('funcname', 'T_initial');
model.func('analytic').set('expr', 'T_surface-q_geothermal/k_rock*z');
model.func('analytic').set('args', {'z'});
model.func('analytic').set('argunit', 'm');
model.func('analytic').set('fununit', 'K');
model.func('analytic').set('plotargs', {'z' '-300' '0'});

model.component('model_comp').mesh.create('model_mesh');

model.component('model_comp').geom('model_geom').create('blk1', 'Block');
model.component('model_comp').geom('model_geom').feature('blk1').set('pos', {'-0.5*borehole_spacing' '-0.5*borehole_spacing' '-L_borehole'});
model.component('model_comp').geom('model_geom').feature('blk1').set('size', {'borehole_spacing' 'borehole_spacing' 'L_borehole'});
model.component('model_comp').geom('model_geom').create('cyl1', 'Cylinder');
model.component('model_comp').geom('model_geom').feature('cyl1').set('pos', {'0' '0' '-L_borehole'});
model.component('model_comp').geom('model_geom').feature('cyl1').set('r', 'r_borehole');
model.component('model_comp').geom('model_geom').feature('cyl1').set('h', 'L_borehole');
model.component('model_comp').geom('model_geom').create('dif1', 'Difference');
model.component('model_comp').geom('model_geom').feature('dif1').selection('input').set({'blk1'});
model.component('model_comp').geom('model_geom').feature('dif1').selection('input2').set({'cyl1'});
model.component('model_comp').geom('model_geom').create('blk2', 'Block');
model.component('model_comp').geom('model_geom').feature('blk2').set('pos', {'-0.5*borehole_spacing' '-0.5*borehole_spacing' '-H_model'});
model.component('model_comp').geom('model_geom').feature('blk2').set('size', {'borehole_spacing' 'borehole_spacing' 'H_model-L_borehole'});
model.component('model_comp').geom('model_geom').run;

model.component('model_comp').variable.create('variables');
model.component('model_comp').variable('variables').set('T_wall', 'wall_aveop(T)');
model.component('model_comp').variable('variables').set('Q_wall', 'wall_intop(-ht.ndflux)');
model.component('model_comp').variable('variables').set('heat_extraction', 'monthly_profile(t)*annual_energy_demand/monthly_hours');

model.component('model_comp').cpl.create('wall_aveop', 'Average');
model.component('model_comp').cpl.create('wall_intop', 'Integration');
model.component('model_comp').cpl('wall_aveop').selection.geom('model_geom', 2);
model.component('model_comp').cpl('wall_aveop').selection.set([10 11 12 13 14]);
model.component('model_comp').cpl('wall_intop').selection.geom('model_geom', 2);
model.component('model_comp').cpl('wall_intop').selection.set([10 11 12 13 14]);

model.component('model_comp').physics.create('model_physics', 'HeatTransfer', 'model_geom');
model.component('model_comp').physics('model_physics').create('temp_bc', 'TemperatureBoundary', 2);
model.component('model_comp').physics('model_physics').feature('temp_bc').selection.set([7]);
model.component('model_comp').physics('model_physics').create('geo_flux_bc', 'HeatFluxBoundary', 2);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').selection.set([3]);
model.component('model_comp').physics('model_physics').create('wall_flux_bc', 'HeatFluxBoundary', 2);
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').selection.set([4 5 6 9 10 11 12 13 14 16]);
model.component('model_comp').physics('model_physics').create('periodic_bc_1', 'PeriodicHeat', 2);
model.component('model_comp').physics('model_physics').feature('periodic_bc_1').selection.set([1 4 15 16]);
model.component('model_comp').physics('model_physics').create('periodic_bc_2', 'PeriodicHeat', 2);
model.component('model_comp').physics('model_physics').feature('periodic_bc_2').selection.set([2 5 8 9]);

model.component('model_comp').mesh('model_mesh').create('edge_mesh', 'Edge');
model.component('model_comp').mesh('model_mesh').create('tri_mesh', 'FreeTri');
model.component('model_comp').mesh('model_mesh').create('swept_mesh', 'Sweep');
model.component('model_comp').mesh('model_mesh').create('tetra_mesh', 'FreeTet');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').selection.set([17 18 21 24]);
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').create('edge_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').selection.set([7]);
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').create('tri_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.geom('model_geom', 3);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.set([2]);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.geom('model_geom', 3);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.set([1]);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').create('tetra_mesh_size', 'Size');

model.component('model_comp').view('view1').set('renderwireframe', true);

model.component('model_comp').cpl('wall_aveop').label('Wall Average Operator');
model.component('model_comp').cpl('wall_intop').label('Wall Integration Operator');

model.component('model_comp').physics('model_physics').prop('ShapeProperty').set('order_temperature', 1);
model.component('model_comp').physics('model_physics').feature('solid1').set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
model.component('model_comp').physics('model_physics').feature('solid1').set('rho', 'rho_rock');
model.component('model_comp').physics('model_physics').feature('solid1').set('Cp', 'Cp_rock');
model.component('model_comp').physics('model_physics').feature('init1').set('Tinit', 'T_initial(z)');
model.component('model_comp').physics('model_physics').feature('temp_bc').set('T0', 'T_surface');
model.component('model_comp').physics('model_physics').feature('temp_bc').label('Surface Temperature');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').set('q0', 'q_geothermal');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').label('Geothermal Heat Flux');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').set('q0', '-heat_extraction/A_wall');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').label('Borehole Wall Heat Flux');

model.component('model_comp').mesh('model_mesh').feature('edge_mesh').label('Borehole Collar Edge Mesh');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').label('Edge Size');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hmax', '20[mm]');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hmin', '1[mm]');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').feature('edge_mesh_size').set('hminactive', true);
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').label('Surface Triangular Mesh');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').feature('tri_mesh_size').label('Triangular Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').feature('tri_mesh_size').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').label('Swept Mesh');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('size1').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('size1').set('hmax', '10[m]');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('size1').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').label('Tetrahedral Mesh');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').label('Tetrahedral Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').run;

model.frame('mesh1').sorder(1);

model.component('model_comp').physics('model_physics').feature('solid1').set('k_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('rho_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('Cp_mat', 'userdef');

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
model.sol('sol1').feature('v1').set('clist', {'range(0,10,50*365.25)'});
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('tunit', 'd');
model.sol('sol1').feature('t1').set('tlist', 'range(0,10,50*365.25)');
model.sol('sol1').feature('t1').set('maxstepbdf', 10);
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
