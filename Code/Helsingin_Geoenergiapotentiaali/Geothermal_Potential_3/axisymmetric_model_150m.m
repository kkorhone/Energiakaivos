function out = model
%
% axisymmetric_model_150m.m
%
% Model exported on Mar 21 2019, 17:03 by COMSOL 5.4.0.295.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3');

model.label('axisymmetric_model_150m.mph');

model.comments(['Axisymmetric model 150m\n\n']);

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
model.param.set('annual_energy_demand', '16.24[MW*h]');
model.param.set('monthly_hours', '730.5[h]');
model.param.set('h_buffer', '1[m]');
model.param.set('h_vertical', '100[mm]');
model.param.set('h_horizontal', '5[mm]');

model.component.create('model_comp', true);

model.component('model_comp').geom.create('model_geom', 2);

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
model.func('analytic').label('Initial Temperature Function');
model.func('analytic').set('funcname', 'T_initial');
model.func('analytic').set('expr', 'T_surface-q_geothermal/k_rock*z');
model.func('analytic').set('args', {'z'});
model.func('analytic').set('argunit', 'm');
model.func('analytic').set('fununit', 'K');
model.func('analytic').set('plotargs', {'z' '0' '1'});

model.component('model_comp').geom('model_geom').axisymmetric(true);

model.component('model_comp').mesh.create('model_mesh');

model.component('model_comp').geom('model_geom').create('bedrock_polygon', 'Polygon');
model.component('model_comp').geom('model_geom').feature('bedrock_polygon').label('Bedrock Polygon');
model.component('model_comp').geom('model_geom').feature('bedrock_polygon').set('x', '0 r_borehole+h_buffer r_borehole+h_buffer r_model r_model 0');
model.component('model_comp').geom('model_geom').feature('bedrock_polygon').set('y', '-L_borehole-h_buffer -L_borehole-h_buffer 0 0 -H_model -H_model');
model.component('model_comp').geom('model_geom').create('buffer_polygon', 'Polygon');
model.component('model_comp').geom('model_geom').feature('buffer_polygon').label('Buffer Polygon');
model.component('model_comp').geom('model_geom').feature('buffer_polygon').set('x', '0 0 r_borehole r_borehole r_borehole+h_buffer r_borehole+h_buffer');
model.component('model_comp').geom('model_geom').feature('buffer_polygon').set('y', '-L_borehole-h_buffer -L_borehole -L_borehole 0 0 0-L_borehole-h_buffer');
model.component('model_comp').geom('model_geom').run;

model.component('model_comp').variable.create('variables');
model.component('model_comp').variable('variables').set('T_wall_min', 'wall_minop(T)');
model.component('model_comp').variable('variables').set('T_wall_ave', 'wall_aveop(T)');
model.component('model_comp').variable('variables').set('Q_wall', 'wall_intop(-ht.ndflux)');
model.component('model_comp').variable('variables').set('heat_extraction', 'monthly_profile(t)*annual_energy_demand/monthly_hours');

model.view.create('view2', 2);
model.view.create('view3', 2);

model.component('model_comp').cpl.create('wall_minop', 'Minimum');
model.component('model_comp').cpl.create('wall_aveop', 'Average');
model.component('model_comp').cpl.create('wall_intop', 'Integration');
model.component('model_comp').cpl('wall_minop').selection.geom('model_geom', 1);
model.component('model_comp').cpl('wall_minop').selection.set([5 6]);
model.component('model_comp').cpl('wall_aveop').selection.geom('model_geom', 1);
model.component('model_comp').cpl('wall_aveop').selection.set([5 6]);
model.component('model_comp').cpl('wall_intop').selection.geom('model_geom', 1);
model.component('model_comp').cpl('wall_intop').selection.set([5 6]);

model.component('model_comp').common.create('amth_model_physics', 'AmbientThermalProperties');

model.component('model_comp').physics.create('model_physics', 'HeatTransfer', 'model_geom');
model.component('model_comp').physics('model_physics').create('temp_bc', 'TemperatureBoundary', 1);
model.component('model_comp').physics('model_physics').feature('temp_bc').selection.set([7 9]);
model.component('model_comp').physics('model_physics').create('geo_flux_bc', 'HeatFluxBoundary', 1);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').selection.set([2]);
model.component('model_comp').physics('model_physics').create('wall_flux_bc', 'HeatFluxBoundary', 1);
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').selection.set([5 6]);

model.component('model_comp').mesh('model_mesh').create('edg1', 'Edge');
model.component('model_comp').mesh('model_mesh').create('ftri1', 'FreeTri');
model.component('model_comp').mesh('model_mesh').create('ftri2', 'FreeTri');
model.component('model_comp').mesh('model_mesh').feature('edg1').selection.set([5 6]);
model.component('model_comp').mesh('model_mesh').feature('edg1').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').create('size2', 'Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').selection.set([5]);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').selection.set([6]);
model.component('model_comp').mesh('model_mesh').feature('ftri1').selection.geom('model_geom', 2);
model.component('model_comp').mesh('model_mesh').feature('ftri1').selection.set([2]);
model.component('model_comp').mesh('model_mesh').feature('ftri1').create('size1', 'Size');
model.component('model_comp').mesh('model_mesh').feature('ftri2').selection.geom('model_geom', 2);
model.component('model_comp').mesh('model_mesh').feature('ftri2').selection.set([1]);
model.component('model_comp').mesh('model_mesh').feature('ftri2').create('size1', 'Size');

model.component('model_comp').view('view1').axis.set('xmin', -63.80226135253906);
model.component('model_comp').view('view1').axis.set('xmax', 305.56402587890625);
model.component('model_comp').view('view1').axis.set('ymin', -185.50537109375);
model.component('model_comp').view('view1').axis.set('ymax', 14.967207908630371);
model.view('view2').axis.set('xmin', -19.6239013671875);
model.view('view2').axis.set('xmax', 349.6239013671875);
model.view('view2').axis.set('ymin', -190.00001525878906);
model.view('view2').axis.set('ymax', 10.40826416015625);
model.view('view3').axis.set('xmin', -2376.65869140625);
model.view('view3').axis.set('xmax', 7306.837890625);
model.view('view3').axis.set('ymin', -5125.1357421875);
model.view('view3').axis.set('ymax', 130.55648803710938);

model.component('model_comp').cpl('wall_minop').label('Wall Minimum Operator');
model.component('model_comp').cpl('wall_aveop').label('Wall Average Operator');
model.component('model_comp').cpl('wall_intop').label('Wall Integration Operator');

model.component('model_comp').common('amth_model_physics').label('Ambient Thermal Properties (model_physics)');
model.common('cminpt').label('Common model inputs 1');

model.component('model_comp').physics('model_physics').prop('ShapeProperty').set('order_temperature', 1);
model.component('model_comp').physics('model_physics').prop('PhysicalModelProperty').set('BackCompStateT', 0);
model.component('model_comp').physics('model_physics').prop('ConsistentStabilization').set('glim', '(0.01[K])/ht.helem');
model.component('model_comp').physics('model_physics').prop('RadiationSettings').set('opaque', 'model_physics.dfltopaque');
model.component('model_comp').physics('model_physics').feature('solid1').set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
model.component('model_comp').physics('model_physics').feature('solid1').set('rho', 'rho_rock');
model.component('model_comp').physics('model_physics').feature('solid1').set('Cp', 'Cp_rock');
model.component('model_comp').physics('model_physics').feature('init1').set('Tinit', 'T_initial(z)');
model.component('model_comp').physics('model_physics').feature('idi1').feature('lopac1').label('Layer Opacity');
model.component('model_comp').physics('model_physics').feature('temp_bc').set('T0', 'T_surface');
model.component('model_comp').physics('model_physics').feature('temp_bc').label('Surface Temperature');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').set('q0', 'q_geothermal');
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').label('Geothermal Heat Flux');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').set('q0', '-heat_extraction/A_wall');
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').label('Borehole Wall Heat Flux');

model.component('model_comp').mesh('model_mesh').feature('edg1').label('Borehole Wall Edge');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').label('Horizontal Edge Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('hmax', 'h_horizontal');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size1').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').label('Vertical Edge Size');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hmax', 'h_vertical');
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hmaxactive', true);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hmin', 3);
model.component('model_comp').mesh('model_mesh').feature('edg1').feature('size2').set('hminactive', false);
model.component('model_comp').mesh('model_mesh').feature('ftri1').label('Buffer Mesh');
model.component('model_comp').mesh('model_mesh').feature('ftri1').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('ftri1').feature('size1').label('Buffer Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('ftri1').feature('size1').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').feature('ftri2').label('Rock Mesh');
model.component('model_comp').mesh('model_mesh').feature('ftri2').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').label('Rock Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').set('hgrad', 1.1);
model.component('model_comp').mesh('model_mesh').feature('ftri2').feature('size1').set('hgradactive', true);
model.component('model_comp').mesh('model_mesh').run;

model.component('model_comp').physics('model_physics').feature('solid1').set('k_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('rho_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('Cp_mat', 'userdef');
model.component('model_comp').physics('model_physics').feature('solid1').set('minput_strainreferencetemperature_src', 'userdef');

model.study.create('std1');
model.study('std1').create('time', 'Transient');
model.study('std1').feature('time').set('activate', {'model_physics' 'on'});

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('dDef');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.result.create('pg1', 'PlotGroup2D');
model.result.create('pg2', 'PlotGroup1D');
model.result('pg1').create('con1', 'Contour');
model.result('pg1').create('con2', 'Contour');
model.result('pg1').create('str1', 'Streamline');
model.result('pg1').create('arws1', 'ArrowSurface');
model.result('pg1').create('arws2', 'ArrowSurface');
model.result('pg2').create('glob1', 'Global');
model.result.export.create('anim1', 'Animation');
model.result.export.create('img1', 'Image2D');

model.study('std1').label('Study');
model.study('std1').feature('time').set('tunit', 'a');
model.study('std1').feature('time').set('tlist', 'range(0,1/36,500)');
model.study('std1').feature('time').set('discretization', {'model_physics' 'physics'});

model.sol('sol1').attach('std1');
model.sol('sol1').label('Solution');
model.sol('sol1').feature('v1').label('Dependent Variables');
model.sol('sol1').feature('v1').set('resscalemethod', 'auto');
model.sol('sol1').feature('v1').set('clist', {'range(0,1/36,500)' '0.5[a]'});
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', 'range(0,1/36,500)');
model.sol('sol1').feature('t1').set('maxstepconstraintbdf', 'const');
model.sol('sol1').feature('t1').set('maxstepbdf', '1/36');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').runAll;

model.result('pg1').set('looplevel', {'interp'});
model.result('pg1').setIndex('interp', '101', 0);
model.result('pg1').set('titletype', 'manual');
model.result('pg1').set('title', '150-m borehole, year eval(t[1/a]) (grey = temperature, black = streamline, blue = temperature disturbance, blue arrows = ground heat flow, red arrows = surface heat flow)');
model.result('pg1').set('allowevalintitle', true);
model.result('pg1').set('titleprecision', 3);
model.result('pg1').set('showlegends', false);
model.result('pg1').set('window', 'window1');
model.result('pg1').set('windowtitle', 'Plot 1');
model.result('pg1').set('windowtitleactive', true);
model.result('pg1').feature('con1').set('unit', 'degC');
model.result('pg1').feature('con1').set('levelmethod', 'levels');
model.result('pg1').feature('con1').set('levels', 'range(0,0.1,10)');
model.result('pg1').feature('con1').set('coloring', 'uniform');
model.result('pg1').feature('con1').set('color', 'gray');
model.result('pg1').feature('con1').set('smooth', 'internal');
model.result('pg1').feature('con1').set('resolution', 'normal');
model.result('pg1').feature('con2').set('expr', 'T-T_initial(z)');
model.result('pg1').feature('con2').set('descr', 'T-T_initial(z)');
model.result('pg1').feature('con2').set('levelmethod', 'levels');
model.result('pg1').feature('con2').set('levels', -0.1);
model.result('pg1').feature('con2').set('coloring', 'uniform');
model.result('pg1').feature('con2').set('color', 'blue');
model.result('pg1').feature('con2').set('smooth', 'internal');
model.result('pg1').feature('con2').set('resolution', 'normal');
model.result('pg1').feature('str1').set('posmethod', 'start');
model.result('pg1').feature('str1').set('startmethod', 'coord');
model.result('pg1').feature('str1').set('xcoord', 'range(0,300/50,300)');
model.result('pg1').feature('str1').set('ycoord', 'range(-200,200/50,0)');
model.result('pg1').feature('str1').set('resolution', 'normal');
model.result('pg1').feature('arws1').set('expr', {'(ht.dfluxz>0)*ht.dfluxr' '(ht.dfluxz>0)*ht.dfluxz'});
model.result('pg1').feature('arws1').set('descr', '');
model.result('pg1').feature('arws1').set('arrowxmethod', 'coord');
model.result('pg1').feature('arws1').set('xcoord', 'range(5,200/50,300)');
model.result('pg1').feature('arws1').set('arrowymethod', 'coord');
model.result('pg1').feature('arws1').set('ycoord', 'range(-200,200/50,0)');
model.result('pg1').feature('arws1').set('arrowlength', 'logarithmic');
model.result('pg1').feature('arws1').set('logrange', 25);
model.result('pg1').feature('arws1').set('scale', 20);
model.result('pg1').feature('arws1').set('scaleactive', true);
model.result('pg1').feature('arws1').set('color', 'blue');
model.result('pg1').feature('arws2').set('expr', {'(ht.dfluxz<0)*ht.dfluxr' '(ht.dfluxz<0)*ht.dfluxz'});
model.result('pg1').feature('arws2').set('descr', '');
model.result('pg1').feature('arws2').set('arrowxmethod', 'coord');
model.result('pg1').feature('arws2').set('xcoord', 'range(5,200/50,200)');
model.result('pg1').feature('arws2').set('arrowymethod', 'coord');
model.result('pg1').feature('arws2').set('ycoord', 'range(-200,200/50,0)');
model.result('pg1').feature('arws2').set('arrowlength', 'logarithmic');
model.result('pg1').feature('arws2').set('logrange', 25);
model.result('pg1').feature('arws2').set('scale', 20);
model.result('pg1').feature('arws2').set('scaleactive', true);
model.result('pg2').set('xlabel', 'Time (a)');
model.result('pg2').set('xlabelactive', false);
model.result('pg2').feature('glob1').set('expr', {'T_wall_min'});
model.result('pg2').feature('glob1').set('unit', {'degC'});
model.result('pg2').feature('glob1').set('descr', {''});
model.result.export('anim1').set('movietype', 'avi');
model.result.export('anim1').set('avifilename', 'E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\example.avi');
model.result.export('anim1').set('aviqual', '1.0');
model.result.export('anim1').set('fps', 1);
model.result.export('anim1').set('looplevelinput', 'interp');
model.result.export('anim1').set('interp', '0 range(0,1/12,1) range(2,1,5)');
model.result.export('anim1').set('framesel', 'all');
model.result.export('anim1').set('width', 1096);
model.result.export('anim1').set('height', 634);
model.result.export('anim1').set('options', true);
model.result.export('anim1').set('resolution', 150);
model.result.export('anim1').set('antialias', false);
model.result.export('anim1').set('synchronize', false);
model.result.export('anim1').set('title', 'on');
model.result.export('anim1').set('legend', 'off');
model.result.export('anim1').set('logo', 'off');
model.result.export('anim1').set('options', 'on');
model.result.export('anim1').set('fontsize', '1');
model.result.export('anim1').set('customcolor', [0.03529411926865578 0.4627451002597809 0.03529411926865578]);
model.result.export('anim1').set('background', 'current');
model.result.export('anim1').set('axisorientation', 'off');
model.result.export('anim1').set('grid', 'off');
model.result.export('anim1').set('axes', 'on');
model.result.export('anim1').set('showgrid', 'on');
model.result.export('img1').set('view', 'view1');
model.result.export('img1').set('weblockratio', false);
model.result.export('img1').set('pngfilename', 'E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\koe2.png');
model.result.export('img1').set('printunit', 'mm');
model.result.export('img1').set('webunit', 'px');
model.result.export('img1').set('printheight', '90');
model.result.export('img1').set('webheight', '634');
model.result.export('img1').set('printwidth', '120');
model.result.export('img1').set('webwidth', '1096');
model.result.export('img1').set('printlockratio', 'off');
model.result.export('img1').set('weblockratio', 'off');
model.result.export('img1').set('printresolution', '300');
model.result.export('img1').set('webresolution', '150');
model.result.export('img1').set('size', 'manualweb');
model.result.export('img1').set('antialias', 'off');
model.result.export('img1').set('zoomextents', 'off');
model.result.export('img1').set('title', 'on');
model.result.export('img1').set('legend', 'off');
model.result.export('img1').set('logo', 'off');
model.result.export('img1').set('options', 'on');
model.result.export('img1').set('fontsize', '1');
model.result.export('img1').set('customcolor', [0.03529411926865578 0.4627451002597809 0.03529411926865578]);
model.result.export('img1').set('background', 'current');
model.result.export('img1').set('axes', 'on');
model.result.export('img1').set('qualitylevel', '92');
model.result.export('img1').set('qualityactive', 'off');
model.result.export('img1').set('imagetype', 'png');
model.result('pg1').set('window', 'window1');
model.result('pg1').run;
model.result('pg1').set('window', 'graphics');
model.result('pg1').run;
model.result('pg1').run;
model.result('pg1').set('view', 'view1');
model.result('pg1').run;

out = model;
