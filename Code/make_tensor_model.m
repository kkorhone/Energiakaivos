function make_tensor_model(cbhe)

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 3);
model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').create('sph1', 'Sphere');
model.component('comp1').geom('geom1').feature('sph1').set('r', '10[m]');
model.component('comp1').geom('geom1').create('sph2', 'Sphere');

model.component('comp1').geom('geom1').feature('sph2').set('r', '1[m]');
model.component('comp1').geom('geom1').create('dif1', 'Difference');
model.component('comp1').geom('geom1').feature('dif1').selection('input').set({'sph1'});
model.component('comp1').geom('geom1').feature('dif1').selection('input2').set({'sph2'});

model.component('comp1').geom('geom1').create('ls1', 'LineSegment');
model.component('comp1').geom('geom1').feature('ls1').set('specify1', 'coord');
model.component('comp1').geom('geom1').feature('ls1').set('specify2', 'coord');
model.component('comp1').geom('geom1').feature('ls1').set('coord2', 10*cbhe.axis);

model.component('comp1').geom('geom1').run();

model.component('comp1').physics.create('ht', 'HeatTransfer', 'geom1');
model.component('comp1').physics('ht').prop('ShapeProperty').set('order_temperature', 1);

model.component('comp1').physics('ht').create('temp1', 'TemperatureBoundary', 2);
model.component('comp1').physics('ht').feature('temp1').selection.set([5 6 7 8 11 12 14 15]);
model.component('comp1').physics('ht').feature('temp1').set('T0', '0[degC]');

model.component('comp1').physics('ht').create('temp2', 'TemperatureBoundary', 2);
model.component('comp1').physics('ht').feature('temp2').selection.set([1 2 3 4 9 10 13 16]);
model.component('comp1').physics('ht').feature('temp2').set('T0', '10[degC]');

model.component('comp1').physics('ht').feature('solid1').set('k_mat', 'userdef');
model.component('comp1').physics('ht').feature('solid1').set('k', reshape(to_cell_array(cbhe.thermalConductivityTensor), 1, []));
model.component('comp1').physics('ht').feature('solid1').set('rho_mat', 'userdef');
model.component('comp1').physics('ht').feature('solid1').set('rho', '1000[kg/m^3]');
model.component('comp1').physics('ht').feature('solid1').set('Cp_mat', 'userdef');
model.component('comp1').physics('ht').feature('solid1').set('Cp', '4200[J/(kg*K)]');

model.component('comp1').mesh('mesh1').create('ftet1', 'FreeTet');
model.component('comp1').mesh('mesh1').feature('ftet1').create('size1', 'Size');
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hauto', 2);

model.component('comp1').mesh('mesh1').run();

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('d1', 'Direct');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').create('i2', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('s1').feature('i2').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('s1').feature('fc1').set('initstep', 0.01);
model.sol('sol1').feature('s1').feature('fc1').set('minstep', 1.0E-6);
model.sol('sol1').feature('s1').feature('fc1').set('maxiter', 50);
model.sol('sol1').feature('s1').feature('fc1').set('termonres', false);
model.sol('sol1').feature('s1').feature('d1').label('Direct, Heat Transfer Variables (ht)');
model.sol('sol1').feature('s1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('s1').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('s1').feature('i1').label('AMG, Heat Transfer Variables (ht)');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'saamg');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('saamgcompwise', true);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('usesmooth', false);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('s1').feature('i2').label('GMG, Heat Transfer Variables (ht)');
model.sol('sol1').feature('s1').feature('i2').set('rhob', 20);
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');

model.sol('sol1').runAll();

model.component('comp1').view('view1').camera.set('projection', 'orthographic');
model.component('comp1').view('view1').camera.set('orthoscale', 39.81048583984375);
model.component('comp1').view('view1').camera.set('position', [0 -181.86532592773438 0]);
model.component('comp1').view('view1').camera.set('target', [0 0 0]);
model.component('comp1').view('view1').camera.set('up', [0 0 1]);
model.component('comp1').view('view1').camera.set('rotationpoint', [0 0 0]);
model.component('comp1').view('view1').camera.set('viewoffset', [-0.04240630939602852 -0.02347417362034321]);

model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').create('iso1', 'Isosurface');
model.result('pg1').feature('iso1').set('unit', 'degC');
model.result('pg1').feature('iso1').set('resolution', 'normal');
model.result('pg1').set('titletype', 'manual');
model.result('pg1').set('title', sprintf('Thermal Conductivity Tensor Plot'));
model.result('pg1').set('view', 'view1');
model.result('pg1').run();

model.result.export.create('img1', 'Image');
model.result.export('img1').set('size', 'current');
model.result.export('img1').set('lockratio', 'off');
model.result.export('img1').set('resolution', '300');
model.result.export('img1').set('antialias', 'on');
model.result.export('img1').set('zoomextents', 'on');
model.result.export('img1').set('fontsize', '9');
model.result.export('img1').set('customcolor', [1 1 1]);
model.result.export('img1').set('background', 'color');
model.result.export('img1').set('gltfincludelines', 'on');
model.result.export('img1').set('title1d', 'on');
model.result.export('img1').set('legend1d', 'on');
model.result.export('img1').set('logo1d', 'on');
model.result.export('img1').set('options1d', 'on');
model.result.export('img1').set('title2d', 'on');
model.result.export('img1').set('legend2d', 'on');
model.result.export('img1').set('logo2d', 'on');
model.result.export('img1').set('options2d', 'off');
model.result.export('img1').set('title3d', 'on');
model.result.export('img1').set('legend3d', 'off');
model.result.export('img1').set('logo3d', 'off');
model.result.export('img1').set('options3d', 'on');
model.result.export('img1').set('axisorientation', 'on');
model.result.export('img1').set('grid', 'on');
model.result.export('img1').set('axes1d', 'on');
model.result.export('img1').set('axes2d', 'on');
model.result.export('img1').set('showgrid', 'on');
model.result.export('img1').set('target', 'file');
model.result.export('img1').set('qualitylevel', '92');
model.result.export('img1').set('qualityactive', 'off');
model.result.export('img1').set('imagetype', 'png');
model.result.export('img1').set('sourceobject', 'pg1');

model.result.export('img1').set('pngfilename', 'E:\\Work\\Energiakaivos\\Code\\tensor.png');
model.result.export('img1').run();

mphsave(model, 'tensor.mph');
