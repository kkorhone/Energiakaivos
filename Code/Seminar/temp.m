function out = model
%
% temp.m
%
% Model exported on Apr 13 2020, 18:17 by COMSOL 5.5.0.292.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\Energiakaivos\Code\Seminar');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').create('cyl1', 'Cylinder');
model.component('comp1').geom('geom1').feature('cyl1').set('h', 123);
model.component('comp1').geom('geom1').feature('cyl1').set('r', 4.56);
model.component('comp1').geom('geom1').feature('cyl1').set('axistype', 'cartesian');
model.component('comp1').geom('geom1').feature('cyl1').set('ax3', [1.23 2.34 3.45]);
model.component('comp1').geom('geom1').feature('cyl1').set('pos', [1 2 3]);
model.component('comp1').geom('geom1').run('cyl1');

out = model;
