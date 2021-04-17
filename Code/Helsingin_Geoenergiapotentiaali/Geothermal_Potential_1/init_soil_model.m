function model = init_soil_model(borehole_length, borehole_spacing, monthly_profile)

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Soil Model');

ModelUtil.showProgress(true);

model_comp = model.component.create('model_comp', true);

% -------------------------------------------------------------------------
% Sets up model parameters.
% -------------------------------------------------------------------------

model.param.set('L_borehole', sprintf('%.3f[m]', borehole_length));
model.param.set('r_borehole', '70[mm]');
model.param.set('H_model', '500[m]');
model.param.set('borehole_spacing', sprintf('%.3f[m]', borehole_spacing));
model.param.set('A_wall', '2*pi*r_borehole*L_borehole+pi*r_borehole^2');
model.param.set('q_geothermal', '40[mW/m^2]');
model.param.set('T_surface', '6[degC]');
model.param.set('k_rock', '3[W/(m*K)]');
model.param.set('Cp_rock', '720[J/(kg*K)]');
model.param.set('rho_rock', '2700[kg/m^3]');
model.param.set('annual_energy_demand', '7.5[MW*h]');
model.param.set('monthly_hours', '730.5[h]');
model.param.set('H_soil', '50[m]');
model.param.set('k_soil', '0.5[W/(m*K)]');
model.param.set('Cp_soil', '1550[J/(kg*K)]');
model.param.set('rho_soil', '1550[kg/m^3]');

% -------------------------------------------------------------------------
% Creates monthly profile function.
% -------------------------------------------------------------------------

pieces = cell(12, 3);

for i = 1:12
    pieces{i, 1} = sprintf('%d/12', i-1);
    pieces{i, 2} = sprintf('%d/12', i);
    pieces{i, 3} = sprintf('%.3f', monthly_profile(i));
end

piecewise1 = model.func.create('piecewise1', 'Piecewise');
piecewise1.label('Monthly Profile');
piecewise1.set('funcname', 'monthly_profile');
piecewise1.set('arg', 't');
piecewise1.set('extrap', 'periodic');
piecewise1.set('smooth', 'contd2');
piecewise1.set('smoothends', true);
piecewise1.set('pieces', pieces);
piecewise1.set('argunit', 'a');
piecewise1.set('fununit', '1');

% -------------------------------------------------------------------------
% Creates initial temperature function.
% -------------------------------------------------------------------------

piecewise2 = model.func.create('piecewise2', 'Piecewise');
piecewise2.label('Initial Temperature Function');
piecewise2.set('funcname', 'T_initial');
piecewise2.set('arg', 'z');
piecewise2.set('pieces', {'-H_model' '-H_soil' 'T_surface+q_geothermal/k_soil*H_soil-q_geothermal/k_rock*(z+H_soil)'; '-H_soil' '0' 'T_surface-q_geothermal/k_soil*z'});
piecewise2.set('argunit', 'm');
piecewise2.set('fununit', 'K');

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
extrude.set('distance', {'L_borehole-H_soil' 'L_borehole'});
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
wall_aveop.selection.set([4 6 9]);

wall_intop = model_comp.cpl.create('wall_intop', 'Integration');
wall_intop.selection.geom('model_geom', 2);
wall_intop.label('Wall Integration Operator');
wall_intop.set('opname', 'wall_intop');
wall_intop.selection.set([4 6 9]);

% -------------------------------------------------------------------------
% Creates component variables.
% -------------------------------------------------------------------------

variables = model_comp.variable.create('variables');
variables.set('T_wall', 'wall_aveop(T)');
variables.set('Q_wall', 'wall_intop(-ht.ndflux)');
variables.set('heat_extraction', 'monthly_profile(t)*annual_energy_demand/monthly_hours');

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

model_physics.create('solid2', 'SolidHeatTransferModel', 3);
model_physics.feature('solid2').set('k_mat', 'userdef');
model_physics.feature('solid2').set('k', {'k_soil'; '0'; '0'; '0'; 'k_soil'; '0'; '0'; '0'; 'k_soil'});
model_physics.feature('solid2').set('rho_mat', 'userdef');
model_physics.feature('solid2').set('rho', 'rho_soil');
model_physics.feature('solid2').set('Cp_mat', 'userdef');
model_physics.feature('solid2').set('Cp', 'Cp_soil');
model_physics.feature('solid2').selection.set([3]);

temp_bc = model_physics.create('temp_bc', 'TemperatureBoundary', 2);
temp_bc.set('T0', 'T_surface');
temp_bc.label('Surface Temperature');
temp_bc.selection.set([11]);

geo_flux_bc = model_physics.create('geo_flux_bc', 'HeatFluxBoundary', 2);
geo_flux_bc.set('q0', 'q_geothermal');
geo_flux_bc.label('Geothermal Heat Flux');
geo_flux_bc.selection.set([3]);

wall_flux_bc = model_physics.create('wall_flux_bc', 'HeatFluxBoundary', 2);
wall_flux_bc.set('q0', '-heat_extraction/A_wall');
wall_flux_bc.label('Borehole Wall Heat Flux');
wall_flux_bc.selection.set([4 6 9]);

% -------------------------------------------------------------------------
% Creates mesh.
% -------------------------------------------------------------------------

model_mesh = model_comp.mesh.create('model_mesh');

edge_mesh = model_mesh.create('edge_mesh', 'Edge');
edge_mesh.label('Borehole Collar Edge Mesh');
edge_mesh.selection.set([13]);

edge_mesh_size = edge_mesh.create('edge_mesh_size', 'Size');
edge_mesh_size.label('Edge Size');
edge_mesh_size.set('custom', 'on');
edge_mesh_size.set('hmaxactive', true);
edge_mesh_size.set('hminactive', true);
edge_mesh_size.set('hmin', '10[mm]'); % <--- minimum segment size
edge_mesh_size.set('hmax', '10[mm]'); % <--- maximum segment size

tri_mesh = model_mesh.create('tri_mesh', 'FreeTri');
tri_mesh.label('Surface Triangular Mesh');
tri_mesh.set('method', 'del');
tri_mesh.selection.set([11]);

tri_mesh_size = tri_mesh.create('tri_mesh_size', 'Size');
tri_mesh_size.label('Triangular Mesh Size');
tri_mesh_size.set('hauto', 1);
tri_mesh_size.set('custom', 'on');
tri_mesh_size.set('hminactive', true);
tri_mesh_size.set('hmaxactive', true);
tri_mesh_size.set('hgradactive', true);
tri_mesh_size.set('hmin', '1[mm]'); % <--- minimum element size
tri_mesh_size.set('hmax', '20[m]'); % <--- maximum element size
tri_mesh_size.set('hgrad', 1.2); % <--- element growth rate

swept_mesh = model_mesh.create('swept_mesh', 'Sweep');
swept_mesh.selection.geom('model_geom', 3);
swept_mesh.label('Swept Mesh');
swept_mesh.selection.set([2 3]);

swept_mesh_distr1 = swept_mesh.create('swept_mesh_distr1', 'Distribution');
swept_mesh_distr1.label('Soil Mesh Distribution');
swept_mesh_distr1.set('numelem', 10); % <--- number of sweeps
swept_mesh_distr1.selection.set([3]);

swept_mesh_distr2 = swept_mesh.create('swept_mesh_distr2', 'Distribution');
swept_mesh_distr2.label('Bedrock Mesh Distribution');
swept_mesh_distr2.set('numelem', 30); % <--- number of sweeps
swept_mesh_distr2.selection.set([2]);

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
tetra_mesh_size.set('hgrad', 1.3); % <--- element growth rate
tetra_mesh_size.set('hmin', '1[mm]'); % <--- minimum element size
tetra_mesh_size.set('hmax', '20[m]'); % <--- maximum element size
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
model.study('std1').feature('time').set('tlist', 'range(0,1/24,50)');

model.sol('sol1').attach('std1');
model.sol('sol1').label('Solution');
model.sol('sol1').feature('v1').label('Dependent Variables');
model.sol('sol1').feature('v1').set('clist', {'range(0,1/36,50)'});
model.sol('sol1').feature('t1').label('Time-Dependent Solver');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', 'range(0,1/24,50)');
model.sol('sol1').feature('t1').set('maxstepbdf', '1/24');
model.sol('sol1').feature('t1').set('maxstepbdfactive', true);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').feature('d1').label('Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
