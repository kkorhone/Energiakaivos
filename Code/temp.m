bhe_offset = 0.25;
bhe_length = 0.75;

file_name = 'ico_field_136_1m.txt';

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 3);

field_config = load(file_name);

bhe_collars = field_config(:, 1:3);
bhe_footers = field_config(:, 4:6);
bhe_factors = field_config(:, 7);

for i = 1:length(bhe_factors)
    
    bhe_axis = bhe_footers(i,:) - bhe_collars(i,:);
    bhe_axis = bhe_axis / sqrt(dot(bhe_axis, bhe_axis));
    
    tag = sprintf('cyl%d', i);
    
    model.component('comp1').geom('geom1').create(tag, 'Cylinder');
    model.component('comp1').geom('geom1').feature(tag).set('h', bhe_length);
    model.component('comp1').geom('geom1').feature(tag).set('r', 0.01);
    model.component('comp1').geom('geom1').feature(tag).set('axistype', 'cartesian');
    model.component('comp1').geom('geom1').feature(tag).set('ax3', bhe_axis);
    model.component('comp1').geom('geom1').feature(tag).set('pos', bhe_offset*bhe_axis);

    %tag = sprintf('ls%d', i);

    %model.component('comp1').geom('geom1').create(tag, 'LineSegment');
    %model.component('comp1').geom('geom1').feature(tag).set('specify1', 'coord');
    %model.component('comp1').geom('geom1').feature(tag).set('specify2', 'coord');
    %model.component('comp1').geom('geom1').feature(tag).set('coord2', (bhe_offset+bhe_length)*bhe_axis);

end

%model.component('comp1').geom('geom1').create('imp1', 'Import');
%model.component('comp1').geom('geom1').feature('imp1').set('filename', 'E:\Work\Energiakaivos\Code\tessellation_5_half.stl');
%model.component('comp1').geom('geom1').feature('imp1').set('simplifymesh', false);
%model.component('comp1').geom('geom1').feature('imp1').set('formsolid', false);

model.component('comp1').geom('geom1').run();

mphsave(model, 'temp.mph');
