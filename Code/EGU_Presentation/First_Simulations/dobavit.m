mph_name = 'ico_field_8_300m_1Ma.mph';

model = mphload(mph_name);

params.k_rock = 2.92;
params.Cp_rock = 682;
params.rho_rock = 2794;
params.T_surface = 3;
params.q_geothermal = 0.038;

% =========================================================================
% Gets component #1.
% =========================================================================

phys1 = model.physics('physics');
comp1 = model.component('component');
geom1 = model.geom('geometry');

% =========================================================================
% Creates component #2.
% =========================================================================

comp2 = model.component.create('component2', true);
geom2 = comp2.geom.create('geometry2', 3);
mesh2 = comp2.mesh.create('mesh2');

% =========================================================================
% Adds work plane #1.
% =========================================================================

work_plane1 = geom2.create('work_plane1', 'WorkPlane');
work_plane1.set('unite', true);
work_plane1.set('quickz', -3800);

work_plane1.geom.create('c1', 'Circle');
work_plane1.geom.feature('c1').set('r', 10000);
work_plane1.geom.feature('c1').set('angle', 90);

work_plane1.geom.create('c2', 'Circle');
work_plane1.geom.feature('c2').set('r', 2300);
work_plane1.geom.feature('c2').set('angle', 90);

work_plane1.geom.create('dif1', 'Difference');
work_plane1.geom.feature('dif1').selection('input').set({'c1'});
work_plane1.geom.feature('dif1').selection('input2').set({'c2'});

geom2.run('fin');
geom2.run(work_plane1.tag);

extrude1 = geom2.feature.create('extrude1', 'Extrude');
extrude1.setIndex('distance', 3800, 0);

geom2.run('fin');

% =========================================================================
% Adds work plane #2.
% =========================================================================

work_plane2 = geom2.create('work_plane2', 'WorkPlane');
work_plane2.set('unite', true);
work_plane2.set('quickz', -10000);

work_plane2.geom.create('c1', 'Circle');
work_plane2.geom.feature('c1').set('r', 10000);
work_plane2.geom.feature('c1').set('angle', 90);

geom2.run('fin');
geom2.run(work_plane2.tag);

extrude2 = geom2.feature.create('extrude2', 'Extrude');
extrude2.setIndex('distance', 10000-3800, 0);

geom2.run('fin');

% =========================================================================
% Adds general extrusions.
% =========================================================================

genext1 = comp1.cpl.create('genext1', 'GeneralExtrusion');
genext1.selection.geom(geom1.tag, 2);
genext1.selection.set([3 41]);

genext2 = comp2.cpl.create('genext2', 'GeneralExtrusion');
genext2.selection.geom(geom2.tag, 2);
genext2.selection.set([4 6]);

% =========================================================================
% Adds physics.
% =========================================================================

phys2 = comp2.physics.create('physics2', 'HeatTransfer', geom2.tag);
phys2.prop('ShapeProperty').set('order_temperature', 1);

phys2.feature('solid1').set('k_mat', 'userdef');
phys2.feature('solid1').set('k', {sprintf('%f',params.k_rock); '0'; '0'; '0'; sprintf('%f',params.k_rock); '0'; '0'; '0'; sprintf('%f',params.k_rock)});

phys2.feature('solid1').set('rho_mat', 'userdef');
phys2.feature('solid1').set('rho', params.rho_rock);

phys2.feature('solid1').set('Cp_mat', 'userdef');
phys2.feature('solid1').set('Cp', params.Cp_rock);
phys2.feature('solid1').label('Bedrock Solid');

phys2.feature('init1').set('Tinit', 'T_initial(z)');
phys2.feature('init1').label('Initial Values');

phys2.create('temp1', 'TemperatureBoundary', 2);
phys2.feature('temp1').selection.set([4 6]);
phys2.feature('temp1').set('T0', sprintf('%s.genext1(%s.T)', comp1.tag, comp1.tag));

phys2.create('temp2', 'TemperatureBoundary', 2);
phys2.feature('temp2').selection.set([8]);
phys2.feature('temp2').set('T0', sprintf('%f[degC]', params.T_surface));

phys2.create('hf1', 'HeatFluxBoundary', 2);
phys2.feature('hf1').selection.set([3]);
phys2.feature('hf1').set('q0', params.q_geothermal);

phys1.feature.remove('bottom_heat_flux_bc');
phys1.create('temp1', 'TemperatureBoundary', 2);
phys1.feature('temp1').selection.set([3 41]);
phys1.feature('temp1').set('T0', sprintf('%s.genext2(%s.T2)', comp2.tag, comp2.tag));

% =========================================================================
% Replaces solver.
% =========================================================================

model.sol.remove('sol1');

model.sol.create('sol1');
model.sol('sol1').study('std1');

model.study('std1').feature('time').set('notlistsolnum', 1);
model.study('std1').feature('time').set('notsolnum', '1');
model.study('std1').feature('time').set('listsolnum', 1);
model.study('std1').feature('time').set('solnum', '1');

model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').set('tlist', '0 1000000');
model.sol('sol1').feature('t1').set('plot', 'off');
model.sol('sol1').feature('t1').set('plotgroup', 'Default');
model.sol('sol1').feature('t1').set('plotfreq', 'tout');
model.sol('sol1').feature('t1').set('probesel', 'all');
model.sol('sol1').feature('t1').set('probes', {});
model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
model.sol('sol1').feature('t1').set('atolglobalvaluemethod', 'factor');
model.sol('sol1').feature('t1').set('atolmethod', {'component2_T2' 'global' 'component_T' 'global'});
model.sol('sol1').feature('t1').set('atol', {'component2_T2' '1e-3' 'component_T' '1e-3'});
model.sol('sol1').feature('t1').set('atolvaluemethod', {'component2_T2' 'factor' 'component_T' 'factor'});
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').create('se1', 'Segregated');
model.sol('sol1').feature('t1').feature('se1').feature.remove('ssDef');
model.sol('sol1').feature('t1').feature('se1').create('ss1', 'SegregatedStep');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('segvar', {'component_T'});
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('subdamp', 0.8);
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('subjtech', 'once');
model.sol('sol1').feature('t1').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').feature('d1').label('Direct, Heat Transfer Variables (physics)');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('linsolver', 'd1');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').label('Heat transfer');
model.sol('sol1').feature('t1').feature('se1').create('ss2', 'SegregatedStep');
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('segvar', {'component2_T2'});
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('subdamp', 0.8);
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('subjtech', 'once');
model.sol('sol1').feature('t1').create('d2', 'Direct');
model.sol('sol1').feature('t1').feature('d2').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d2').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').feature('d2').label('Direct, Heat Transfer Variables (physics2)');
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('linsolver', 'd2');
model.sol('sol1').feature('t1').feature('se1').feature('ss2').label('Heat transfer (2)');
model.sol('sol1').feature('t1').feature('se1').set('segstabacc', 'segaacc');
model.sol('sol1').feature('t1').feature('se1').set('segaaccdim', 5);
model.sol('sol1').feature('t1').feature('se1').set('segaaccmix', 0.9);
model.sol('sol1').feature('t1').feature('se1').set('segaaccdelay', 1);
model.sol('sol1').feature('t1').feature('se1').create('ll1', 'LowerLimit');
model.sol('sol1').feature('t1').feature('se1').feature('ll1').set('lowerlimit', 'component2.T2 0 component.T 0 ');
model.sol('sol1').feature('t1').create('i1', 'Iterative');
model.sol('sol1').feature('t1').feature('i1').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i1').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i1').set('rhob', 400);
model.sol('sol1').feature('t1').feature('i1').label('AMG, Heat Transfer Variables (physics)');
model.sol('sol1').feature('t1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('prefun', 'saamg');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('usesmooth', false);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('saamgcompwise', true);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').create('i2', 'Iterative');
model.sol('sol1').feature('t1').feature('i2').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i2').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i2').set('rhob', 20);
model.sol('sol1').feature('t1').feature('i2').label('GMG, Heat Transfer Variables (physics)');
model.sol('sol1').feature('t1').feature('i2').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').set('prefun', 'gmg');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').set('mcasegen', 'any');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').create('i3', 'Iterative');
model.sol('sol1').feature('t1').feature('i3').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i3').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i3').set('rhob', 400);
model.sol('sol1').feature('t1').feature('i3').label('AMG, Heat Transfer Variables (physics2)');
model.sol('sol1').feature('t1').feature('i3').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').set('prefun', 'saamg');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').set('usesmooth', false);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').set('saamgcompwise', true);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('pr').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('po').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').create('i4', 'Iterative');
model.sol('sol1').feature('t1').feature('i4').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i4').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i4').set('rhob', 20);
model.sol('sol1').feature('t1').feature('i4').label('GMG, Heat Transfer Variables (physics2)');
model.sol('sol1').feature('t1').feature('i4').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i4').feature('mg1').set('prefun', 'gmg');
model.sol('sol1').feature('t1').feature('i4').feature('mg1').set('mcasegen', 'any');
model.sol('sol1').feature('t1').feature('i4').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i4').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i4').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i4').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i4').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i4').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').attach('std1');
model.sol('sol1').feature('t1').set('initialstepbdfactive', true);
model.sol('sol1').feature('t1').set('initialstepbdf', '1e-6');
model.sol('sol1').feature('t1').set('tout', 'tsteps');
model.sol('sol1').feature('t1').feature.remove('i1');
model.sol('sol1').feature('t1').feature.remove('i2');
model.sol('sol1').feature('t1').feature.remove('i3');
model.sol('sol1').feature('t1').feature.remove('i4');
model.sol('sol1').feature('t1').feature.remove('dDef');
model.sol('sol1').feature('t1').feature('se1').feature.remove('ss2');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('segvar', {'component_T' 'component2_T2'});
model.sol('sol1').feature('t1').feature.remove('d2');

model = mphload(sprintf('%s_v2.mph', mph_name(1:end-4)));
