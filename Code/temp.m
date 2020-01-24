function out = model
%
% temp.m
%
% Model exported on Jan 24 2020, 19:11 by COMSOL 5.5.0.292.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\Work\Energiakaivos\Code');

model.label('temp.mph');

model.component.create('component', true);

model.component('component').geom.create('geometry', 3);

model.component('component').mesh.create('mesh');

model.component('component').geom('geometry').create('work_plane2_borehole_structure', 'WorkPlane');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').label('Borehole Structure Work Plane 2');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').set('planetype', 'normalvector');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').set('normalvector', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').set('normalcoord', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').set('unite', true);
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.create('buffer_circle', 'Circle');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.feature('buffer_circle').set('r', 0.5);
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.create('borehole_circle', 'Circle');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.feature('borehole_circle').set('r', 0.1);
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.create('outer_circle', 'Circle');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.feature('outer_circle').set('r', 0.08);
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.create('inner_circle', 'Circle');
model.component('component').geom('geometry').feature('work_plane2_borehole_structure').geom.feature('inner_circle').set('r', 0.05);
model.component('component').geom('geometry').create('extrusion2_borehole_structure', 'Extrude');
model.component('component').geom('geometry').feature('extrusion2_borehole_structure').label('Borehole Structure Work Plane Extrusion 2');
model.component('component').geom('geometry').feature('extrusion2_borehole_structure').setIndex('distance', '100', 0);
model.component('component').geom('geometry').feature('extrusion2_borehole_structure').selection('input').set({'work_plane2_borehole_structure'});
model.component('component').geom('geometry').create('work_plane2_upper_cylinder', 'WorkPlane');
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').label('Upper Cylinder Work Plane 2');
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').set('planetype', 'normalvector');
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').set('normalvector', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').set('normalcoord', {'-0.000000' '0.000000' '0.500000'});
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').set('unite', true);
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').geom.create('buffer_circle', 'Circle');
model.component('component').geom('geometry').feature('work_plane2_upper_cylinder').geom.feature('buffer_circle').set('r', 0.5);
model.component('component').geom('geometry').create('extrusion2_upper_cylinder', 'Extrude');
model.component('component').geom('geometry').feature('extrusion2_upper_cylinder').label('Upper Cylinder Work Plane Extrusion 2');
model.component('component').geom('geometry').feature('extrusion2_upper_cylinder').setIndex('distance', '0.5', 0);
model.component('component').geom('geometry').feature('extrusion2_upper_cylinder').selection('input').set({'work_plane2_upper_cylinder'});
model.component('component').geom('geometry').create('work_plane2_lower_cylinder', 'WorkPlane');
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').label('Lower Cylinder Work Plane 2');
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').set('planetype', 'normalvector');
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').set('normalvector', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').set('normalcoord', {'0.000000' '0.000000' '-100.000000'});
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').set('unite', true);
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').geom.create('buffer_circle', 'Circle');
model.component('component').geom('geometry').feature('work_plane2_lower_cylinder').geom.feature('buffer_circle').set('r', 0.5);
model.component('component').geom('geometry').create('extrusion2_lower_cylinder', 'Extrude');
model.component('component').geom('geometry').feature('extrusion2_lower_cylinder').label('Lower Cylinder Work Plane Extrusion 2');
model.component('component').geom('geometry').feature('extrusion2_lower_cylinder').setIndex('distance', '0.5', 0);
model.component('component').geom('geometry').feature('extrusion2_lower_cylinder').selection('input').set({'work_plane2_lower_cylinder'});
model.component('component').geom('geometry').create('buffer_zone_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('buffer_zone_selection2').label('Buffer Zone Selection 2');
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('r', 0.501);
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('rin', 0.099);
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('top', 100.001);
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('buffer_zone_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('outer_fluid_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('outer_fluid_selection2').label('Outer Fluid Selection 2');
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('r', 0.101);
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('rin', 0.079);
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('top', 100.001);
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('outer_fluid_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('pipe_wall_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('pipe_wall_selection2').label('Pipe Wall Selection 2');
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('r', 0.081);
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('rin', 0.001);
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('top', 100.001);
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('pipe_wall_selection2').set('condition', 'inside');
model.component('component').geom('geometry').create('inner_fluid_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('inner_fluid_selection2').label('Inner Fluid Selection 2');
model.component('component').geom('geometry').feature('inner_fluid_selection2').set('r', 0.051000000000000004);
model.component('component').geom('geometry').feature('inner_fluid_selection2').set('top', 100.001);
model.component('component').geom('geometry').feature('inner_fluid_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('inner_fluid_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('inner_fluid_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('inner_fluid_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('borehole_wall_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('borehole_wall_selection2').label('Borehole Wall Selection 2');
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('r', 0.101);
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('rin', 0.099);
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('top', 100.001);
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('borehole_wall_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('upper_cylinder_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('upper_cylinder_selection2').label('Upper Cylinder Selection 2');
model.component('component').geom('geometry').feature('upper_cylinder_selection2').set('r', 0.501);
model.component('component').geom('geometry').feature('upper_cylinder_selection2').set('top', 0.501);
model.component('component').geom('geometry').feature('upper_cylinder_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('upper_cylinder_selection2').set('pos', {'-0.000000' '0.000000' '0.500000'});
model.component('component').geom('geometry').feature('upper_cylinder_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('upper_cylinder_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('lower_cylinder_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('lower_cylinder_selection2').label('Lower Cylinder Selection 2');
model.component('component').geom('geometry').feature('lower_cylinder_selection2').set('r', 0.501);
model.component('component').geom('geometry').feature('lower_cylinder_selection2').set('top', 0.501);
model.component('component').geom('geometry').feature('lower_cylinder_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('lower_cylinder_selection2').set('pos', {'0.000000' '0.000000' '-100.000000'});
model.component('component').geom('geometry').feature('lower_cylinder_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('lower_cylinder_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('outer_cap_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('outer_cap_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('outer_cap_selection2').label('Outer Cap Selection 2');
model.component('component').geom('geometry').feature('outer_cap_selection2').set('r', 0.501);
model.component('component').geom('geometry').feature('outer_cap_selection2').set('rin', 0.099);
model.component('component').geom('geometry').feature('outer_cap_selection2').set('top', 0.001);
model.component('component').geom('geometry').feature('outer_cap_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('outer_cap_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('outer_cap_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('outer_cap_selection2').set('condition', 'inside');
model.component('component').geom('geometry').create('inner_cap_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('inner_cap_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('inner_cap_selection2').label('Inner Cap Selection 2');
model.component('component').geom('geometry').feature('inner_cap_selection2').set('r', 0.101);
model.component('component').geom('geometry').feature('inner_cap_selection2').set('top', 0.001);
model.component('component').geom('geometry').feature('inner_cap_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('inner_cap_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('inner_cap_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('inner_cap_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('top_inlet_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('top_inlet_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('top_inlet_selection2').label('Top Inlet Selection 2');
model.component('component').geom('geometry').feature('top_inlet_selection2').set('r', 0.101);
model.component('component').geom('geometry').feature('top_inlet_selection2').set('rin', 0.079);
model.component('component').geom('geometry').feature('top_inlet_selection2').set('top', 0.001);
model.component('component').geom('geometry').feature('top_inlet_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('top_inlet_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('top_inlet_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('top_inlet_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('top_outlet_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('top_outlet_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('top_outlet_selection2').label('Top Outlet Selection 2');
model.component('component').geom('geometry').feature('top_outlet_selection2').set('r', 0.051000000000000004);
model.component('component').geom('geometry').feature('top_outlet_selection2').set('top', 0.001);
model.component('component').geom('geometry').feature('top_outlet_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('top_outlet_selection2').set('pos', {'0.000000' '0.000000' '0.000000'});
model.component('component').geom('geometry').feature('top_outlet_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('top_outlet_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('bottom_outlet_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('bottom_outlet_selection2').label('Bottom Outlet Selection 2');
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('r', 0.101);
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('rin', 0.079);
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('top', 0.001);
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('pos', {'0.000000' '0.000000' '-100.000000'});
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('bottom_outlet_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').create('bottom_inlet_selection2', 'CylinderSelection');
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('entitydim', 2);
model.component('component').geom('geometry').feature('bottom_inlet_selection2').label('Bottom Inlet Selection 2');
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('r', 0.051000000000000004);
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('top', 0.001);
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('bottom', -0.001);
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('pos', {'0.000000' '0.000000' '-100.000000'});
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('axis', {'0.000000' '0.000000' '-1.000000'});
model.component('component').geom('geometry').feature('bottom_inlet_selection2').set('condition', 'allvertices');
model.component('component').geom('geometry').run;

model.component('component').mesh('mesh').create('inner_cap_mesh2', 'FreeTri');
model.component('component').mesh('mesh').create('outer_cap_mesh2', 'FreeTri');
model.component('component').mesh('mesh').feature('inner_cap_mesh2').selection.named('geometry_inner_cap_selection2');
model.component('component').mesh('mesh').feature('inner_cap_mesh2').create('size', 'Size');
model.component('component').mesh('mesh').feature('outer_cap_mesh2').selection.named('geometry_outer_cap_selection2');
model.component('component').mesh('mesh').feature('outer_cap_mesh2').create('size', 'Size');

model.component('component').view('view1').set('renderwireframe', true);

model.component('component').mesh('mesh').feature('inner_cap_mesh2').label('Inner Cap Mesh 2');
model.component('component').mesh('mesh').feature('inner_cap_mesh2').feature('size').set('hauto', 1);
model.component('component').mesh('mesh').feature('inner_cap_mesh2').feature('size').set('custom', 'on');
model.component('component').mesh('mesh').feature('inner_cap_mesh2').feature('size').set('hmax', '15[mm]');
model.component('component').mesh('mesh').feature('inner_cap_mesh2').feature('size').set('hmaxactive', true);

model.component('component').mesh('mesh').feature('outer_cap_mesh2').label('Outer Cap Mesh 2');
model.component('component').mesh('mesh').feature('outer_cap_mesh2').feature('size').set('hauto', 1);
model.component('component').mesh('mesh').feature('outer_cap_mesh2').feature('size').set('custom', 'on');
model.component('component').mesh('mesh').feature('outer_cap_mesh2').feature('size').set('hmax', '100[mm]');
model.component('component').mesh('mesh').feature('outer_cap_mesh2').feature('size').set('hgrad', 1.2);
model.component('component').mesh('mesh').feature('outer_cap_mesh2').feature('size').set('hgradactive', true);
model.component('component').mesh('mesh').feature('outer_cap_mesh2').feature('size').set('hmaxactive', false);

model.component('component').mesh('mesh').run;

out = model;
