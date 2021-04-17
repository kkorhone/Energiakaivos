function out = model
%
% temp.m
%
% Model exported on Sep 3 2019, 13:29 by COMSOL 5.4.0.295.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\Helsingin_Geoenergiapotentiaali\Recovery');

model.component.create('model_comp', true);

model.param.set('L_borehole', '150.000[m]');
model.param.set('r_borehole', '70[mm]');
model.param.set('H_model', '5000[m]');
model.param.set('r_model', '5000[m]');
model.param.set('T_surface', '6.764[degC]');
model.param.set('q_geothermal', '40.548[mW/m^2]');
model.param.set('k_rock', '2.870[W/(m*K)]');
model.param.set('Cp_rock', '725.000[J/(kg*K)]');
model.param.set('rho_rock', '2707.000[kg/m^3]');
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('annual_energy_demand', '16.250000000000000000000000000000[MW*h]');
model.param.set('monthly_hours', '730.5[h]');
model.param.set('h_buffer', '1[m]');
model.param.set('h_vertical', '100[mm]');
model.param.set('h_horizontal', '5[mm]');

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
model.func('analytic').label('Initial Temperature Function');
model.func('analytic').set('funcname', 'T_initial');
model.func('analytic').set('expr', 'T_surface-q_geothermal/k_rock*z');
model.func('analytic').set('args', 'z');
model.func('analytic').set('argunit', 'm');
model.func('analytic').set('fununit', 'K');

model.component('model_comp').geom.create('model_geom', 2);
model.component('model_comp').geom('model_geom').axisymmetric(true);
model.component('model_comp').geom('model_geom').create('bedrock_polygon', 'Polygon');
model.component('model_comp').geom('model_geom').feature('bedrock_polygon').label('Bedrock Polygon');
model.component('model_comp').geom('model_geom').feature('bedrock_polygon').set('x', '0 r_borehole+h_buffer r_borehole+h_buffer r_model r_model 0');
model.component('model_comp').geom('model_geom').feature('bedrock_polygon').set('y', '-L_borehole-h_buffer -L_borehole-h_buffer 0 0 -H_model -H_model');
model.component('model_comp').geom('model_geom').create('buffer_polygon', 'Polygon');
model.component('model_comp').geom('model_geom').feature('buffer_polygon').label('Buffer Polygon');
model.component('model_comp').geom('model_geom').feature('buffer_polygon').set('x', '0 0 r_borehole r_borehole r_borehole+h_buffer r_borehole+h_buffer');
model.component('model_comp').geom('model_geom').feature('buffer_polygon').set('y', '-L_borehole-h_buffer -L_borehole -L_borehole 0 0 0-L_borehole-h_buffer');
model.component('model_comp').geom('model_geom').run;

model.component('model_comp').cpl.create('wall_minop', 'Minimum');
model.component('model_comp').cpl('wall_minop').selection.geom('model_geom', 1);
model.component('model_comp').cpl('wall_minop').label('Wall Minimum Operator');
model.component('model_comp').cpl('wall_minop').set('opname', 'wall_minop');
model.component('model_comp').cpl('wall_minop').selection.set([5 6]);
model.component('model_comp').cpl.create('wall_aveop', 'Average');
model.component('model_comp').cpl('wall_aveop').selection.geom('model_geom', 1);
model.component('model_comp').cpl('wall_aveop').label('Wall Average Operator');
model.component('model_comp').cpl('wall_aveop').set('opname', 'wall_aveop');
model.component('model_comp').cpl('wall_aveop').selection.set([5 6]);
model.component('model_comp').cpl.create('wall_intop', 'Integration');
model.component('model_comp').cpl('wall_intop').selection.geom('model_geom', 1);
model.component('model_comp').cpl('wall_intop').label('Wall Integration Operator');
model.component('model_comp').cpl('wall_intop').set('opname', 'wall_intop');
model.component('model_comp').cpl('wall_intop').selection.set([5 6]);

model.component('model_comp').variable.create('variables');
model.component('model_comp').variable('variables').set('T_wall_min', 'wall_minop(T)');
model.component('model_comp').variable('variables').set('T_wall_ave', 'wall_aveop(T)');
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
model.component('model_comp').physics('model_physics').create('temp_bc', 'TemperatureBoundary', 1);
model.component('model_comp').physics('model_physics').feature('temp_bc').set('T0', 'T_surface');
model.component('model_comp').physics('model_physics').feature('temp_bc').label('Surface Temperature');
model.component('model_comp').physics('model_physics').feature('temp_bc').selection.set([7 9]);
model.component('model_comp').physics('model_physics').create('geo_flux_bc', 'HeatFluxBoundary', 1);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').set('q0', 'q_geothermal');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').label('Geothermal Heat Flux');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').selection.set([2]);
model.component('model_comp').physics('model_physics').create('wall_flux_bc', 'HeatFluxBoundary', 1);
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').set('q0', '-heat_extraction/A_wall*(t<=50[a])');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').label('Borehole Wall Heat Flux');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').selection.set([5 6]);

model.component('model_comp').mesh.create('model_mesh');
model.component('model_comp').mesh('model_mesh').create('edg1', 'Edge');
model.component('model_comp').mesh('model_mesh').feature('edg1').label('Borehole Wall Edge');
model.component('model_comp').mesh('model_mesh').feature('edg1').selection.set([5 6]);
model.component('model_comp').mesh('model_mesh').feature('edg1').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').selection.set([5]);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').label('Horizontal Edge Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('hmax', 'h_horizontal');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('edg1').create('size2', 'Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').selection.set([6]);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').label('Vertical Edge Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hmax', 'h_vertical');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hmin', 3);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hminactive', false);
model.component('model_comp').mesh('model_mesh').create('ftri1', 'FreeTri');
model.component('model_comp').mesh('model_mesh').feature('ftri1').selection.geom('model_geom', 2);
model.component('model_comp').mesh('model_mesh').feature('ftri1').selection.set([2]);
model.component('model_comp').mesh('model_mesh').feature('ftri1').label('Buffer Mesh');
model.component('model_comp').mesh('model_mesh').feature('ftri1').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('ftri1').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('ftri1').feature('size1').label('Buffer Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('ftri1').feature('size1').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').create('ftri2', 'FreeTri');
model.component('model_comp').mesh('model_mesh').feature('ftri2').selection.geom('model_geom', 2);
model.component('model_comp').mesh('model_mesh').feature('ftri2').selection.set([1]);
model.component('model_comp').mesh('model_mesh').feature('ftri2').label('Rock Mesh');
model.component('model_comp').mesh('model_mesh').feature('ftri2').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('ftri2').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').label('Rock Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').set('hgrad', 1.1);
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').set('hgradactive', true);
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
model.study('std1').feature('time').set('tunit', 'a');
model.study('std1').feature('time').set('tlist', 'range(0,1/36,200)');

model.sol('sol1').attach('std1');
model.sol('sol1').label('Solution');
model.sol('sol1').feature('v1').label('Dependent Variables');
model.sol('sol1').feature('v1').set('clist', 'range(0,1/36,200)');
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', 'range(0,1/36,200)');
model.sol('sol1').feature('t1').set('maxstepbdf', '1/36');
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').runAll;

model.label('axisymmetric_model_150m.mph');

model.result.create('pg1', 'PlotGroup1D');
model.result('pg1').run;
model.result('pg1').setIndex('looplevelinput', 'interp', 0);
model.result('pg1').setIndex('interp', '50 60 70 80 90 100', 0);
model.result('pg1').create('lngr1', 'LineGraph');
model.result('pg1').feature('lngr1').selection.set([6]);
model.result('pg1').feature('lngr1').set('expr', 'z');
model.result('pg1').feature('lngr1').set('xdata', 'expr');
model.result('pg1').feature('lngr1').set('xdataexpr', 'T-T_initial(z)');
model.result('pg1').run;
model.result.export.create('plot1', 'Plot');
model.result.export('plot1').set('filename', 'E:\Work\Helsingin_Geoenergiapotentiaali\Recovery\wall_temp_150m.txt');
model.result.export('plot1').run;
model.result.export('plot1').run;
model.result.export('plot1').run;
model.result.export('plot1').run;

out = model;
