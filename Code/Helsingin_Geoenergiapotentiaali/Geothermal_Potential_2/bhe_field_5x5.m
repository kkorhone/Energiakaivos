function model = bhe_field_5x5(num_rows, num_cols, borehole_length, borehole_spacing)

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.param.set('L_borehole', sprintf('%.0f[m]', borehole_length));
model.param.set('r_borehole', '70[mm]');
model.param.set('H_model', '500[m]');
model.param.set('borehole_spacing', sprintf('%.0f[m]', borehole_spacing));
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('q_geothermal', '40[mW/m^2]');
model.param.set('T_surface', '6[degC]');
model.param.set('k_rock', '3[W/(m*K)]');
model.param.set('Cp_rock', '720[J/(kg*K)]');
model.param.set('rho_rock', '2700[kg/m^3]');
model.param.set('annual_energy_demand', '7.5[MW*h]');
model.param.set('monthly_hours', '730.5[h]');
model.param.set('num_rows', num_rows);
model.param.set('num_cols', num_cols);

model.component.create('model_comp', true);

model.component('model_comp').geom.create('model_geom', 3);

model.func.create('piecewise', 'Piecewise');
model.func.create('analytic', 'Analytic');
model.func('piecewise').label('Monthly Profile');
model.func('piecewise').set('funcname', 'monthly_profile');
model.func('piecewise').set('arg', 't');
model.func('piecewise').set('extrap', 'periodic');
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
model.func('analytic').set('plotargs', {'z' '0' '1'});

model.component('model_comp').mesh.create('model_mesh');

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
model.component('model_comp').geom('model_geom').feature('work_plane').geom.create('arr1', 'Array');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('arr1').set('fullsize', {'num_cols' 'num_rows'});
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('arr1').set('displ', {'borehole_spacing' 'borehole_spacing'});
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('arr1').selection('input').set({'difference'});
model.component('model_comp').geom('model_geom').feature('work_plane').geom.create('mov1', 'Move');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('mov1').set('displx', '-(num_cols-1)/2*borehole_spacing');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('mov1').set('disply', '-(num_rows-1)/2*borehole_spacing');
model.component('model_comp').geom('model_geom').feature('work_plane').geom.feature('mov1').selection('input').set({'arr1'});
model.component('model_comp').geom('model_geom').create('extrude', 'Extrude');
model.component('model_comp').geom('model_geom').feature('extrude').setIndex('distance', 'L_borehole', 0);
model.component('model_comp').geom('model_geom').feature('extrude').selection('input').set({'work_plane'});
model.component('model_comp').geom('model_geom').create('block', 'Block');
model.component('model_comp').geom('model_geom').feature('block').set('pos', {'-num_cols/2*borehole_spacing' '-num_rows/2*borehole_spacing' '-H_model'});
model.component('model_comp').geom('model_geom').feature('block').set('size', {'num_cols*borehole_spacing' 'num_rows*borehole_spacing' 'H_model-L_borehole'});
model.component('model_comp').geom('model_geom').run;

k = 1;
for i = 1:num_rows
    for j = 1:num_cols
        tag = sprintf('cyl%d', k);
        model.component('model_comp').selection.create(tag, 'Cylinder');
        model.component('model_comp').selection(tag).set('entitydim', 2);
        model.component('model_comp').selection(tag).set('r', 'r_borehole+1[mm]');
        model.component('model_comp').selection(tag).set('top', '+1[mm]');
        model.component('model_comp').selection(tag).set('bottom', '-L_borehole-1[mm]');
        model.component('model_comp').selection(tag).set('pos', {'-borehole_spacing' '-borehole_spacing' '0'});
        model.component('model_comp').selection(tag).set('condition', 'inside');
        k = k + 1;
    end
end

model.component('model_comp').variable.create('variables');
k = 1;
for i = 1:num_rows
    for j = 1:num_cols
        model.component('model_comp').variable('variables').set(sprintf('T_wall%d', k), sprintf('aveop%d(T)', k));
        k = k + 1;
    end
end
k = 1;
for i = 1:num_rows
    for j = 1:num_cols
        model.component('model_comp').variable('variables').set(sprintf('Q_wall%d', k), sprintf('intop%d(T)', k));
        k = k + 1;
    end
end
model.component('model_comp').variable('variables').set('heat_extraction', 'monthly_profile(t)*annual_energy_demand/monthly_hours');

k = 1;
for i = 1:num_rows
    for j = 1:num_cols
        tag = sprintf('intop%d', k);
        model.component('model_comp').cpl.create(tag, 'Integration');
        model.component('model_comp').cpl(tag).selection.named(sprintf('cyl%d', k));
        k = k + 1;
    end
end

k = 1;
for i = 1:num_rows
    for j = 1:num_cols
        tag = sprintf('aveop%d', k);
        model.component('model_comp').cpl.create(tag, 'Average');
        model.component('model_comp').cpl(tag).selection.named(sprintf('cyl%d', k));
        k = k + 1;
    end
end

model.component('model_comp').physics.create('model_physics', 'HeatTransfer', 'model_geom');
model.component('model_comp').physics('model_physics').create('temp_bc', 'TemperatureBoundary', 2);
model.component('model_comp').physics('model_physics').feature('temp_bc').selection.set([7 11 15 19 23 54 58 62 66 70 100 104 108 112 116 146 150 154 158 162 192 196 200 204 208]);
model.component('model_comp').physics('model_physics').create('geo_flux_bc', 'HeatFluxBoundary', 2);
model.component('model_comp').physics('model_physics').feature('geo_flux_bc').selection.set([3]);
model.component('model_comp').physics('model_physics').create('wall_flux_bc', 'HeatFluxBoundary', 2);
model.component('model_comp').physics('model_physics').feature('wall_flux_bc').selection.named('cyl1');
model.component('model_comp').physics('model_physics').create('periodic_bc_1', 'PeriodicHeat', 2);
model.component('model_comp').physics('model_physics').feature('periodic_bc_1').selection.set([1 4 8 12 16 20 235 236 237 238 239 240]);
model.component('model_comp').physics('model_physics').create('periodic_bc_2', 'PeriodicHeat', 2);
model.component('model_comp').physics('model_physics').feature('periodic_bc_2').selection.set([2 5 24 25 98 117 144 163 190 209]);

model.component('model_comp').mesh('model_mesh').create('edge_mesh', 'Edge');
model.component('model_comp').mesh('model_mesh').create('tri_mesh', 'FreeTri');
model.component('model_comp').mesh('model_mesh').create('swept_mesh', 'Sweep');
model.component('model_comp').mesh('model_mesh').create('tetra_mesh', 'FreeTet');
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').selection.set([37 38 42 43 47 48 52 53 57 58 61 64 67 70 73 76 79 82 85 88 125 126 130 131 135 136 140 141 145 146 149 152 155 158 161 164 167 170 173 176 213 214 218 219 223 224 228 229 233 234 237 240 243 246 249 252 255 258 261 264 301 302 306 307 311 312 316 317 321 322 325 328 331 334 337 340 343 346 349 352 389 390 394 395 399 400 404 405 409 410 413 416 419 422 425 428 431 434 437 440]);
model.component('model_comp').mesh('model_mesh').feature('edge_mesh').create('edge_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').selection.set([7 11 15 19 23 54 58 62 66 70 100 104 108 112 116 146 150 154 158 162 192 196 200 204 208]);
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').create('tri_mesh_size', 'Size');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.geom('model_geom', 3);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').selection.set([2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26]);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').create('swept_mesh_distr', 'Distribution');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.geom('model_geom', 3);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').selection.set([1]);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').create('tetra_mesh_size', 'Size');

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
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').feature('tri_mesh_size').label('Triangular Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('tri_mesh').feature('tri_mesh_size').set('hauto', 1);
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').label('Swept Mesh');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distr').label('Swept Mesh Distribution');
model.component('model_comp').mesh('model_mesh').feature('swept_mesh').feature('swept_mesh_distr').set('numelem', 10);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').label('Tetrahedral Mesh');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').set('method', 'del');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').label('Tetrahedral Mesh Size');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').set('hauto', 2);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').set('custom', 'on');
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').set('hgrad', 1.2);
model.component('model_comp').mesh('model_mesh').feature('tetra_mesh').feature('tetra_mesh_size').set('hgradactive', true);
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
model.sol('sol1').feature('t1').set('control', 'user');
model.sol('sol1').feature('t1').set('tunit', 'd');
model.sol('sol1').feature('t1').set('tlist', 'range(0,10,50*365.25)');
model.sol('sol1').feature('t1').set('maxstepbdf', 10);
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
