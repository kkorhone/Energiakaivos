function model = init_sector_model(borehole_tilt, sector_angle, varargin)

% =========================================================================
% Checks input parameters
% =========================================================================

if any(borehole_tilt < -90) || any(borehole_tilt > 0)
    error('Borehole tilt must be -90 <= borehole_tilt <= 0.');
end

if sector_angle <= 0 || sector_angle >= 360
    error('Sector angle must be 0 < sector_angle < 360.');
end

if 360/sector_angle ~= floor(360/sector_angle)
    error('Invalid sector angle.');
end

if length(varargin)/2 ~= floor(length(varargin)/2)
    error('Invalid number of named arguments.');
end

borehole_tilt = sort(unique(borehole_tilt), 'ascend');

if borehole_tilt(1) > -90
    warning('Vertical borehole missing.');
end

L_borehole = 300;
d_borehole = 76;
buffer_width = 400;
borehole_offset = 10;
r_buffer = 0.5;
T_inlet = 6;

for i = 1:length(varargin)/2
    if strcmp(varargin{(i-1)*2+1}, 'L_borehole')
        L_borehole = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'd_borehole')
        d_borehole = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'borehole_offset')
        borehole_offset = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'r_buffer')
        r_buffer = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'buffer_width')
        buffer_width = varargin{(i-1)*2+2};
    elseif strcmp(varargin{(i-1)*2+1}, 'T_inlet')
        T_inlet = varargin{(i-1)*2+2};
    else
        error('Unrecognized named argument: ''%s''.', string(varargin{(i-1)*2+1}));
    end
end

if d_borehole <= 0
    error('Borehole diameter must be positive.');
end

if d_borehole < 76 || d_borehole > 200
    warning('Borehole diameter should be 76 <= d_borehole <= 200');
end

if L_borehole <= 0
    error('Borehole length must be positive.');
end

if L_borehole < 50 || L_borehole > 2000
    warning('Borehole length should be 50 <= L_borehole <= 2000.');
end

if length(T_inlet) ~= 1 && length(T_inlet) ~= 12
    error('Inlet temperature must be scalar or vector with 12 elements.');
end

if any(T_inlet < 6) || any(T_inlet > 100)
    warning('Inlet temperature should be 6 <= T_inlet <= 100.');
end

if r_buffer < 0
    error('Borehole buffer radius must be positive.');
end

if r_buffer < 0.1 || r_buffer > 1.0
    warning('Borehole buffer radius should be 0.1 <= r_buffer <= 1.0.');
end

if buffer_width <= 0
    error('Buffer zone width width must be positive.');
end

if buffer_width < 100 || buffer_width > 1000
    warning('Buffer zone width width should be 100 <= buffer_width <= 1000.');
end

fprintf(1, '==================================================\n');

for i = 1:length(borehole_tilt)
    fprintf(1, 'init_model: Borehole #%d (tilt = %f deg).\n', i, borehole_tilt(i));
end

fprintf(1, 'init_model: sector_angle = %f deg.\n', sector_angle);
fprintf(1, 'init_model: d_borehole = %f mm.\n', d_borehole);
fprintf(1, 'init_model: L_borehole = %f m.\n', L_borehole);
fprintf(1, 'init_model: borehole_offset = %f m.\n', borehole_offset);
fprintf(1, 'init_model: r_buffer = %f m.\n', r_buffer);
fprintf(1, 'init_model: buffer_width = %f m.\n', buffer_width);

if length(T_inlet) == 1
    fprintf(1, 'init_model: T_inlet = %f degC.\n', T_inlet);
else
    for i = 1:12
        fprintf(1, 'init_model: T_inlet(%d) = %f degC.\n', i, T_inlet(i));
    end
end

fprintf(1, '==================================================\n');

% =========================================================================
% Imports Java packages
% =========================================================================

import com.comsol.model.*
import com.comsol.model.util.*

% =========================================================================
% Creates new model
% =========================================================================

fprintf(1, 'init_model: Creating new model... ');

model = ModelUtil.create('Sector Model 3D');

model.label('sector_model_3d');

component = model.component.create('component', true);

geometry = component.geom.create('geometry', 3);

mesh = component.mesh.create('mesh');

fprintf(1, 'Done.\n');

% =========================================================================
% Sets up parameters
% =========================================================================

fprintf(1, 'init_model: Setting up parameters... ');

% -------------------------------------------------------------------------
% Sets up model parameters
% -------------------------------------------------------------------------

parameters = model.param('default');
parameters.label('General Parameters');
parameters.set('sector_angle', sprintf('%.6f[deg]', sector_angle));
parameters.set('num_sectors', '360[deg]/sector_angle');
parameters.set('tunnel_depth', '1450[m]');
parameters.set('q_geothermal', '40[mW/m^2]');
parameters.set('T_surface', '2.3[degC]');
parameters.set('k_large', '1000[W/(m*K)]');
parameters.set('buffer_width', sprintf('%f[m]', buffer_width));
parameters.set('r_buffer', sprintf('%f[m]', r_buffer));
parameters.set('borehole_offset', sprintf('%f[m]', borehole_offset));

if length(T_inlet) == 1
    parameters.set('T_inlet', sprintf('%f[degC]', T_inlet));
end

% -------------------------------------------------------------------------
% Sets up borehole parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('borehole_parameters');
parameters.label('Borehole Parameters');
parameters.set('L_borehole', sprintf('%f[m]', L_borehole));
parameters.set('d_borehole', sprintf('%f[mm]', d_borehole));
parameters.set('r_borehole', 'd_borehole/2');

% -------------------------------------------------------------------------
% Sets up bedrock parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('bedrock_parameters');
parameters.label('Bedrock parameters');
parameters.set('k_rock', '3[W/(m*K)]');
parameters.set('Cp_rock', '750[J/(kg*K)]');
parameters.set('rho_rock', '2700[kg/m^3]');

% -------------------------------------------------------------------------
% Sets up pipe parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('pipe_parameters');
parameters.label('Pipe Parameters');
parameters.set('d_outer', '50[mm]');
parameters.set('d_inner', '32[mm]');
parameters.set('r_outer', 'd_outer/2');
parameters.set('r_inner', 'd_inner/2');
parameters.set('A_outer', 'pi*r_borehole^2-pi*r_outer^2');
parameters.set('A_inner', 'pi*r_inner^2');
parameters.set('A_hdpe', '0.0006056[m^2]');
parameters.set('A_air', '0.00082697[m^2]');
parameters.set('rho_hdpe', '960[kg/m^3]');
parameters.set('Cp_hdpe', '1900[J/(kg*K)]');
parameters.set('rho_air', '1.2[kg/m^3]');
parameters.set('Cp_air', '1005[J/(kg*K)]');
parameters.set('k_pipe', '0.1[W/(m*K)]');
parameters.set('Cp_pipe', '(A_hdpe*rho_hdpe*Cp_hdpe+A_air*rho_air*Cp_air)/(A_hdpe*rho_hdpe+A_air*rho_air)');
parameters.set('rho_pipe', '(A_hdpe*rho_hdpe+A_air*rho_air)/(A_hdpe+A_air)');

% -------------------------------------------------------------------------
% Sets up fluid parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('fluid_parameters');
parameters.label('Fluid Parameters');
parameters.set('k_fluid', '0.60[W/(m*K)]');
parameters.set('Cp_fluid', '4186[J/(kg*K)]');
parameters.set('rho_fluid', '1000[kg/m^3]');
parameters.set('Q_fluid', '0.6[L/s]');
parameters.set('v_outer', 'Q_fluid/A_outer');
parameters.set('v_inner', 'Q_fluid/A_inner');

% -------------------------------------------------------------------------
% Sets up vector parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('vector_parameters');
parameters.label('Vector Parameters');

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('theta%d',i), sprintf('%.6f[deg]', borehole_tilt(i)));
end

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('nx%d',i), sprintf('cos(theta%d)', i));
    parameters.set(sprintf('nz%d',i), sprintf('sin(theta%d)', i));
end

% -------------------------------------------------------------------------
% Sets up tensor parameters
% -------------------------------------------------------------------------

parameters = model.param.group.create('tensor_parameters');
parameters.label('Tensor Parameters');

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('alpha%d', i), sprintf('-theta%d-90[deg]', i));
end

for i = 1:length(borehole_tilt)
    parameters.set(sprintf('kxx_%d', i), sprintf('k_fluid*sin(alpha%d)^2+k_large*cos(alpha%d)^2', i, i));
    parameters.set(sprintf('kxy_%d', i), '0');
    parameters.set(sprintf('kxz_%d', i), sprintf('(k_fluid-k_large)*sin(2*alpha%d)/2', i));
    parameters.set(sprintf('kyx_%d', i), '0');
    parameters.set(sprintf('kyy_%d', i), 'k_large');
    parameters.set(sprintf('kyz_%d', i), '0');
    parameters.set(sprintf('kzx_%d', i), sprintf('(k_fluid-k_large)*sin(2*alpha%d)/2', i));
    parameters.set(sprintf('kzy_%d', i), '0');
    parameters.set(sprintf('kzz_%d', i), sprintf('k_fluid*cos(alpha%d)^2+k_large*sin(alpha%d)^2', i, i));
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates functions
% =========================================================================

fprintf(1, 'init_model: Creating functions... ');

% -------------------------------------------------------------------------
% Creates inlet temperature function
% -------------------------------------------------------------------------

if length(T_inlet) == 12
    
    pieces = cell(12, 3);

    for i = 1:12
        pieces{i, 1} = sprintf('%d/12', i-1);
        pieces{i, 2} = sprintf('%d/12', i);
        pieces{i, 3} = sprintf('%f', T_inlet(i));
    end
    
    func = model.func.create('inlet_temperature_function', 'Piecewise');
    func.label('Inlet Temperature Function');
    func.set('funcname', 'T_inlet');
    func.set('arg', 't');
    func.set('extrap', 'periodic');
    func.set('pieces', pieces);
    func.set('argunit', 'a');
    func.set('fununit', 'degC');

end

% -------------------------------------------------------------------------
% Creates initial temperature function
% -------------------------------------------------------------------------

func = model.func.create('initial_temperature_function', 'Analytic');
func.label('Initial Temperature Function');
func.set('funcname', 'T_initial');
func.set('expr', 'T_surface-q_geothermal/k_rock*z');
func.set('args', {'z'});
func.set('argunit', 'm');
func.set('fununit', 'K');

% -------------------------------------------------------------------------
% Creates step function
% -------------------------------------------------------------------------

func = model.func.create('step_function', 'Step');
func.label('Step Function');
func.set('funcname', 'step');
func.set('location', '1/24');
func.set('smooth', '1/12');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates geometry
% =========================================================================

fprintf(1, 'init_model: Creating geometry... ');

% -------------------------------------------------------------------------
% Creates work planes and extrusions for borehole structures
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    
    work_plane = geometry.create(sprintf('work_plane%d', i), 'WorkPlane');
    work_plane.set('planetype', 'normalvector');
    work_plane.set('normalvector', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    work_plane.set('normalcoord', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    work_plane.set('unite', true);
    
    if borehole_tilt(i) == -90
        
        circle = work_plane.geom.create('buffer_circle', 'Circle');
        circle.set('rot', '180-0.5*sector_angle');
        circle.set('r', 'r_buffer');
        circle.set('angle', '0.5*sector_angle');
        
        circle = work_plane.geom.create('borehole_circle', 'Circle');
        circle.set('rot', '180-0.5*sector_angle');
        circle.set('r', 'r_borehole');
        circle.set('angle', '0.5*sector_angle');
        
        circle = work_plane.geom.create('outer_circle', 'Circle');
        circle.set('rot', '180-0.5*sector_angle');
        circle.set('r', 'r_outer');
        circle.set('angle', '0.5*sector_angle');
        
        circle = work_plane.geom.create('inner_circle', 'Circle');
        circle.set('rot', '180-0.5*sector_angle');
        circle.set('r', 'r_inner');
        circle.set('angle', '0.5*sector_angle');
        
    else
        
        circle = work_plane.geom.create('buffer_circle', 'Circle');
        circle.set('r', 'r_buffer');
        circle.set('angle', 180);
        
        circle = work_plane.geom.create('borehole_circle', 'Circle');
        circle.set('r', 'r_borehole');
        circle.set('angle', 180);
        
        circle = work_plane.geom.create('outer_circle', 'Circle');
        circle.set('r', 'r_outer');
        circle.set('angle', 180);
        
        circle = work_plane.geom.create('inner_circle', 'Circle');
        circle.set('r', 'r_inner');
        circle.set('angle', 180);
        
    end
    
    extrusion = geometry.create(sprintf('extrusion%d', i), 'Extrude');
    extrusion.setIndex('distance', 'L_borehole', 0);
    extrusion.selection('input').set(char(work_plane.tag));
    
end

% -------------------------------------------------------------------------
% Creates work planes and extrusions for upper buffer cylinders
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    
    work_plane = geometry.create(sprintf('work_plane%d', i+length(borehole_tilt)), 'WorkPlane');
    work_plane.set('planetype', 'normalvector');
    work_plane.set('normalvector', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    work_plane.set('normalcoord', {sprintf('nx%d*(borehole_offset-r_buffer)',i) '0' sprintf('nz%d*(borehole_offset-r_buffer)',i)});
    work_plane.set('unite', true);
    
    if borehole_tilt(i) == -90
        
        circle = work_plane.geom.create('buffer_circle', 'Circle');
        circle.set('rot', '180-0.5*sector_angle');
        circle.set('r', 'r_buffer');
        circle.set('angle', '0.5*sector_angle');
        
    else
        
        circle = work_plane.geom.create('buffer_circle', 'Circle');
        circle.set('r', 'r_buffer');
        circle.set('angle', 180);
        
    end
    
    extrusion = geometry.create(sprintf('extrusion%d', i+length(borehole_tilt)), 'Extrude');
    extrusion.setIndex('distance', 'r_buffer', 0);
    extrusion.selection('input').set(char(work_plane.tag));
    
end

% -------------------------------------------------------------------------
% Creates work planes and extrusions for lower buffer cylinders
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    
    work_plane = geometry.create(sprintf('work_plane%d', i+2*length(borehole_tilt)), 'WorkPlane');
    work_plane.set('planetype', 'normalvector');
    work_plane.set('normalvector', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    work_plane.set('normalcoord', {sprintf('nx%d*(borehole_offset+L_borehole)',i) '0' sprintf('nz%d*(borehole_offset+L_borehole)',i)});
    work_plane.set('unite', true);
    
    if borehole_tilt(i) == -90
        
        circle = work_plane.geom.create('buffer_circle', 'Circle');
        circle.set('rot', '180-0.5*sector_angle');
        circle.set('r', 'r_buffer');
        circle.set('angle', '0.5*sector_angle');
        
    else
        
        circle = work_plane.geom.create('buffer_circle', 'Circle');
        circle.set('r', 'r_buffer');
        circle.set('angle', 180);
        
    end
    
    extrusion = geometry.create(sprintf('extrusion%d', i+2*length(borehole_tilt)), 'Extrude');
    extrusion.setIndex('distance', 'r_buffer', 0);
    extrusion.selection('input').set(char(work_plane.tag));
    
end

% -------------------------------------------------------------------------
% Creates work plane and extrusion for bedrock domain
% -------------------------------------------------------------------------

work_plane = geometry.create(sprintf('work_plane%d', 1+3*length(borehole_tilt)), 'WorkPlane');
work_plane.set('unite', true);
work_plane.set('quickz', '-L_borehole-buffer_width');

circle = work_plane.geom.create('sector_circle', 'Circle');
circle.set('angle', '0.5*sector_angle');
circle.set('r', 'L_borehole+buffer_width');

extrusion = geometry.feature.create(sprintf('extrusion%d', 1+3*length(borehole_tilt)), 'Extrude');
extrusion.set('workplane', work_plane.tag);
extrusion.selection('input').set(char(work_plane.tag));
extrusion.setIndex('distance', 'L_borehole+2*buffer_width', 0);

% -------------------------------------------------------------------------
% Generates geometry
% -------------------------------------------------------------------------

geometry.run('fin');

% =========================================================================
% Creates selections
% =========================================================================

% -------------------------------------------------------------------------
% Creates selections for borehole structures
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('buffer_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Buffer Domain Selection', i));
    selection.set('r', 'r_buffer+1[mm]');
    selection.set('rin', 'r_borehole-1[mm]');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('outer_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Outer Fluid Domain Selection', i));
    selection.set('r', 'r_borehole+1[mm]');
    selection.set('rin', 'r_outer-1[mm]');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('pipe_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Pipe Domain Selection', i));
    selection.set('r', 'r_outer+1[mm]');
    selection.set('rin', 'r_inner-1[mm]');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('inner_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Inner Fluid Domain Selection', i));
    selection.set('r', 'r_inner+1[mm]');
    selection.set('rin', '0');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates borehole wall selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('borehole_wall_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Wall Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_borehole+1[mm]');
    selection.set('rin', 'r_borehole-1[mm]');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates upper buffer cylinder selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('upper_cylinder_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Upper Buffer Cylinder Domain Selection', i));
    selection.set('r', 'r_buffer+1[mm]');
    selection.set('rin', '0');
    selection.set('top', 'r_buffer+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*(borehole_offset-r_buffer)',i) '0' sprintf('nz%d*(borehole_offset-r_buffer)',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates lower buffer cylinder selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('lower_cylinder_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Lower Buffer Cylinder Domain Selection', i));
    selection.set('r', 'r_buffer+1[mm]');
    selection.set('rin', '0');
    selection.set('top', 'r_buffer+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)',i) '0' sprintf('nz%d*(borehole_offset+L_borehole)',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates outer cap selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('outer_cap_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Outer Cap Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_buffer+1[mm]');
    selection.set('rin', 'r_borehole-1[mm]');
    selection.set('top', '+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates inner cap selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('inner_cap_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Inner Cap Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_borehole+1[mm]');
    selection.set('rin', '0');
    selection.set('top', '+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates top inlet selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('top_inlet_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Top Inlet Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_borehole+1[mm]');
    selection.set('rin', 'r_outer-1[mm]');
    selection.set('top', '+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates top outlet selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('top_outlet_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Top Outlet Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_inner+1[mm]');
    selection.set('rin', '0');
    selection.set('top', '+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*borehole_offset',i) '0' sprintf('nz%d*borehole_offset',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates bottom outlet selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('bottom_outlet_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Bottom Outlet Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_borehole+1[mm]');
    selection.set('rin', 'r_outer-1[mm]');
    selection.set('top', '+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)',i) '0' sprintf('nz%d*(borehole_offset+L_borehole)',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates bottom inlet selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('bottom_inlet_selection%d', i), 'CylinderSelection');
    selection.label(sprintf('Borehole #%d Bottom Inlet Selection', i));
    selection.set('entitydim', 2);
    selection.set('r', 'r_inner+1[mm]');
    selection.set('rin', '0');
    selection.set('top', '+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('angle1', '0');
    selection.set('angle2', '360');
    selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)',i) '0' sprintf('nz%d*(borehole_offset+L_borehole)',i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates edge selections
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('inner_edge_selection%d',i), 'CylinderSelection');
    selection.set('entitydim', 1);
    selection.label(sprintf('Borehole #%d Inner Fluid Edge Selection', i));
    selection.set('r', '1[mm]');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_inner',i,i) '0' sprintf('nz%d*borehole_offset+nx%d*r_inner',i,i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

for i = 1:length(borehole_tilt)
    selection = geometry.create(sprintf('outer_edge_selection%d',i), 'CylinderSelection');
    selection.set('entitydim', 1);
    selection.label(sprintf('Borehole #%d Outer Fluid Edge Selection', i));
    selection.set('r', '1[mm]');
    selection.set('top', 'L_borehole+1[mm]');
    selection.set('bottom', '-1[mm]');
    selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_outer',i,i) '0' sprintf('nz%d*borehole_offset+nx%d*r_outer',i,i)});
    selection.set('axis', {sprintf('nx%d',i) '0' sprintf('nz%d',i)});
    selection.set('condition', 'allvertices');
end

% -------------------------------------------------------------------------
% Creates selection for borehole domains
% -------------------------------------------------------------------------

selection = geometry.create('borehole_domains_selection', 'UnionSelection');
selection.label('Borehole Domains Selection');
selection.set('entitydim', 3);
selection.set('input', [compose('buffer_selection%d', 1:length(borehole_tilt)), compose('outer_selection%d', 1:length(borehole_tilt)), compose('pipe_selection%d', 1:length(borehole_tilt)), compose('inner_selection%d', 1:length(borehole_tilt))]);

% -------------------------------------------------------------------------
% Creates selection for cap cylinders
% -------------------------------------------------------------------------

selection = geometry.create('cap_cylinders_selection', 'UnionSelection');
selection.label('Cap Cylinders Selection');
selection.set('entitydim', 3);
selection.set('input', [compose('upper_cylinder_selection%d', 1:length(borehole_tilt)), compose('lower_cylinder_selection%d', 1:length(borehole_tilt))]);

% -------------------------------------------------------------------------
% Creates selection for top surface boundary
% -------------------------------------------------------------------------

selection = geometry.create('surface_selection', 'CylinderSelection');
selection.label('Surface Selection');
selection.set('entitydim', 2);
selection.set('r', 'L_borehole+buffer_width+1[mm]');
selection.set('top', '+1[mm]');
selection.set('bottom', '-1[mm]');
selection.set('pos', {'0' '0' 'buffer_width'});
selection.set('condition', 'allvertices');

% -------------------------------------------------------------------------
% Creates selection for bottom surface boundary
% -------------------------------------------------------------------------

selection = geometry.create('bottom_selection', 'CylinderSelection');
selection.label('Bottom Selection');
selection.set('entitydim', 2);
selection.set('r', 'L_borehole+buffer_width+1[mm]');
selection.set('top', '+1[mm]');
selection.set('bottom', '-1[mm]');
selection.set('pos', {'0' '0' '-L_borehole-buffer_width'});
selection.set('condition', 'allvertices');

% -------------------------------------------------------------------------
% Rebuilds geometry
% -------------------------------------------------------------------------

geometry.run('fin');

fprintf(1, 'Done.\n');

% =========================================================================
% Creates mesh
% =========================================================================

fprintf(1, 'init_model: Creating mesh... ');

% -------------------------------------------------------------------------
% Crates inner triangle mesh for sweeping
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    
    triangular_mesh = mesh.create(sprintf('inner_cap_mesh%d', i), 'FreeTri');
    triangular_mesh.label(sprintf('Borehole #%d Inner Cap Mesh', i));
    triangular_mesh.selection.named(sprintf('geometry_inner_cap_selection%d', i));
    
    size = triangular_mesh.create('size', 'Size');
    size.set('hauto', 1);
    size.set('custom', true);
    size.set('hmaxactive', true);
    if borehole_tilt(i) == -90
        size.set('hmax', '2[mm]');
    else
        size.set('hmax', '5[mm]');
    end
    
end

% -------------------------------------------------------------------------
% Crates outer triangle mesh for sweeping
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    
    triangular_mesh = model.component('component').mesh('mesh').create(sprintf('outer_cap_mesh%d', i), 'FreeTri');
    triangular_mesh.label(sprintf('Borehole #%d Outer Cap Mesh', i));
    triangular_mesh.selection.named(sprintf('geometry_outer_cap_selection%d', i));
    
    size = triangular_mesh.create('size', 'Size');
    size.set('hauto', 1);
    size.set('custom', 'on');
    if borehole_tilt(i) == -90
        size.set('hmax', '20[mm]');
        size.set('hmaxactive', true);
    end
    size.set('hgrad', 1.2);
    size.set('hgradactive', true);
    
end

% -------------------------------------------------------------------------
% Crates swept mesh
% -------------------------------------------------------------------------

swept_mesh = mesh.create('swept_mesh', 'Sweep');
swept_mesh.label(sprintf('Borehole #%d Swept Mesh', i));
swept_mesh.selection.geom('geometry', 3);
swept_mesh.selection.named('geometry_borehole_domains_selection');

distribution = swept_mesh.create('distribution', 'Distribution');
distribution.set('type', 'predefined');
distribution.set('elemcount', 300);
distribution.set('elemratio', 100);
distribution.set('symmetric', true);

% -------------------------------------------------------------------------
% Crates tetrahedral cap cylinder mesh
% -------------------------------------------------------------------------

tetrahedral_mesh = mesh.create('cap_cylinders_mesh', 'FreeTet');
tetrahedral_mesh.label('Cap Cylinder Meshes');
tetrahedral_mesh.selection.geom('geometry', 3);
tetrahedral_mesh.selection.named('geometry_cap_cylinders_selection');

size = tetrahedral_mesh.create('size', 'Size');
size.set('hauto', 3);

% -------------------------------------------------------------------------
% Crates tetrahedral bedrock mesh
% -------------------------------------------------------------------------

tetrahedral_mesh = mesh.create('bedrock_mesh', 'FreeTet');
tetrahedral_mesh.label('Bedrock Mesh');

size = tetrahedral_mesh.create('size', 'Size');
size.set('hauto', 2);

% hauto 9 = extremenly coarse
% hauto 8 = extra coarse
% hauto 7 = coarser
% hauto 6 = coarse
% hauto 5 = normal
% hauto 4 = fine
% hauto 3 = finer
% hauto 2 = extra fine
% hauto 1 = extremenly fine

%mesh.run('cap_cylinders_mesh');
%mesh.run('bedrock_mesh');

% mesh.run();

fprintf(1, 'Done.\n');

% =========================================================================
% Creates operators
% =========================================================================

fprintf(1, 'init_model: Creating operators... ');

% -------------------------------------------------------------------------
% Creates borehole wall integration operators
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    operator = component.cpl.create(sprintf('wall_intop%d', i), 'Integration');
    operator.label(sprintf('Borehole #%d Wall Integration Operator', i));
    operator.selection.named(sprintf('geometry_borehole_wall_selection%d', i));
end

% -------------------------------------------------------------------------
% Creates bottom outlet average operators
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    operator = component.cpl.create(sprintf('bottom_outlet_aveop%d', i), 'Average');
    operator.label(sprintf('Borehole #%d Bottom Outlet Average Operator', i));
    operator.selection.named(sprintf('geometry_bottom_outlet_selection%d', i));
end

% -------------------------------------------------------------------------
% Creates top outlet average operators
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    operator = component.cpl.create(sprintf('top_outlet_aveop%d', i), 'Average');
    operator.label(sprintf('Borehole #%d Top Outlet Average Operator', i));
    operator.selection.named(sprintf('geometry_top_outlet_selection%d', i));
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates component variables
% =========================================================================

fprintf(1, 'init_model: Creating component variables... ');

variables = component.variable.create('component_variables');
variables.label('Component Variables');

for i = 1:length(borehole_tilt)

    if borehole_tilt(i) == -90
        variables.set(sprintf('Q_wall%d', i), sprintf('num_sectors*2*wall_intop%d(physics.ndflux)', i));
    else
        variables.set(sprintf('Q_wall%d', i), sprintf('2*wall_intop%d(physics.ndflux)', i));
    end
    
    if i == 1
        if borehole_tilt(i) == -90
            summation_expression = sprintf('Q_wall%d', i);
            counter_expression = sprintf('1');
        else
            summation_expression = sprintf('num_sectors*Q_wall%d', i);
            counter_expression = sprintf('num_sectors');
        end
    else
        if borehole_tilt(i) == -90
            summation_expression = sprintf('%s+Q_wall%d', summation_expression, i);
            counter_expression = sprintf('%s+1', counter_expression);
        else
            summation_expression = sprintf('%s+num_sectors*Q_wall%d', summation_expression, i);
            counter_expression = sprintf('%s+num_sectors', counter_expression);
        end
    end
    
end

for i = 1:length(borehole_tilt)
    variables.set(sprintf('T_bottom%d', i), sprintf('bottom_outlet_aveop%d(T)', i));
end

for i = 1:length(borehole_tilt)
    variables.set(sprintf('T_outlet%d', i), sprintf('top_outlet_aveop%d(T)', i));
end

variables.set('Q_walls', summation_expression);
variables.set('num_boreholes', counter_expression);

fprintf(1, 'Done.\n');

% =========================================================================
% Creates physics
% =========================================================================

fprintf(1, 'init_model: Creating physics... ');

% -------------------------------------------------------------------------
% Crates bedrock physics
% -------------------------------------------------------------------------

physics = component.physics.create('physics', 'HeatTransfer', geometry.tag);
physics.prop('ShapeProperty').set('order_temperature', 1);
physics.field('temperature').field('T');
physics.identifier('physics');
physics.name('physics');
physics.label('Heat Transfer');

physics.feature('init1').set('Tinit', 'T_initial(z-tunnel_depth)');
physics.feature('init1').label('Initial Values');

physics.feature('solid1').set('k_mat', 'userdef');
physics.feature('solid1').set('k', {'k_rock'; '0'; '0'; '0'; 'k_rock'; '0'; '0'; '0'; 'k_rock'});
physics.feature('solid1').label('Bedrock Solid');

physics.feature('solid1').set('rho_mat', 'userdef');
physics.feature('solid1').set('rho', 'rho_rock');

physics.feature('solid1').set('Cp_mat', 'userdef');
physics.feature('solid1').set('Cp', 'Cp_rock');

physics.create('hf1', 'HeatFluxBoundary', 2);
physics.feature('hf1').selection.named('geometry_surface_selection');
physics.feature('hf1').set('q0', '-q_geothermal');
physics.feature('hf1').label('Ground Surface Heat Flux BC');

physics.create('hf2', 'HeatFluxBoundary', 2);
physics.feature('hf2').selection.named('geometry_bottom_selection');
physics.feature('hf2').set('q0', '+q_geothermal');
physics.feature('hf2').label('Geothermal Heat Flux BC');

% -------------------------------------------------------------------------
% Crates outer fluid
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    fluid = physics.create(sprintf('outer_fluid%d', i), 'FluidHeatTransferModel', 3);
    fluid.label(sprintf('Borehole #%d Outer Fluid', i));
    fluid.selection.named(sprintf('geometry_outer_selection%d', i));
    % fluid.set('u', {sprintf('+nx%d*v_outer*step(t[1/a])',i) '0' sprintf('+nz%d*v_outer*step(t[1/a])',i)});
    fluid.set('u', {sprintf('+nx%d*v_outer',i) '0' sprintf('+nz%d*v_outer',i)});
    fluid.set('k_mat', 'userdef');
    fluid.set('k', {sprintf('kxx_%d',i); sprintf('kyx_%d',i); sprintf('kzx_%d',i); sprintf('kxy_%d',i); sprintf('kyy_%d',i); sprintf('kzy_%d',i); sprintf('kxz_%d',i); sprintf('kyz_%d',i); sprintf('kzz_%d',i)});
    fluid.set('rho_mat', 'userdef');
    fluid.set('rho', 'rho_fluid');
    fluid.set('Cp_mat', 'userdef');
    fluid.set('Cp', 'Cp_fluid');
    fluid.set('gamma_mat', 'userdef');
    fluid.set('gamma', '1');
end

% -------------------------------------------------------------------------
% Crates pipe wall solid
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    solid = physics.create(sprintf('pipe_solid%d',i), 'SolidHeatTransferModel', 3);
    solid.label(sprintf('Borehole #%d Pipe Solid', i));
    solid.selection.named(sprintf('geometry_pipe_selection%d', i));
    solid.set('k_mat', 'userdef');
    solid.set('k', {'k_pipe' '0' '0' '0' 'k_pipe' '0' '0' '0' 'k_pipe'});
    solid.set('rho_mat', 'userdef');
    solid.set('rho', 'rho_pipe');
    solid.set('Cp_mat', 'userdef');
    solid.set('Cp', 'Cp_pipe');
end

% -------------------------------------------------------------------------
% Crates inner fluid
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    fluid = physics.create(sprintf('inner_fluid%d', i), 'FluidHeatTransferModel', 3);
    fluid.label(sprintf('Borehole #%d Inner Fluid', i));
    fluid.selection.named(sprintf('geometry_inner_selection%d', i));
    % fluid.set('u', {sprintf('-nx%d*v_inner*step(t[1/a])',i) '0' sprintf('-nz%d*v_inner*step(t[1/a])',i)});
    fluid.set('u', {sprintf('-nx%d*v_inner',i) '0' sprintf('-nz%d*v_inner',i)});
    fluid.set('k_mat', 'userdef');
    fluid.set('k', {sprintf('kxx_%d',i); sprintf('kyx_%d',i); sprintf('kzx_%d',i); sprintf('kxy_%d',i); sprintf('kyy_%d',i); sprintf('kzy_%d',i); sprintf('kxz_%d',i); sprintf('kyz_%d',i); sprintf('kzz_%d',i)});
    fluid.set('rho_mat', 'userdef');
    fluid.set('rho', 'rho_fluid');
    fluid.set('Cp_mat', 'userdef');
    fluid.set('Cp', 'Cp_fluid');
    fluid.set('gamma_mat', 'userdef');
    fluid.set('gamma', '1');
end

% -------------------------------------------------------------------------
% Crates top inlet boundary conditions
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    temperature_bc = physics.create(sprintf('top_inlet_temperature_bc%d', i), 'TemperatureBoundary', 2);
    temperature_bc.label(sprintf('Borehole #%d Top Inlet Temperature BC', i));
    temperature_bc.selection.named(sprintf('geometry_top_inlet_selection%d', i));
    if length(T_inlet) == 1
        % temperature_bc.set('T0', '(1-step(t[1/a]))*T_initial(z-tunnel_depth)+step(t[1/a])*T_inlet');
        temperature_bc.set('T0', 'T_inlet');
    else
        % temperature_bc.set('T0', '(1-step(t[1/a]))*T_initial(z-tunnel_depth)+step(t[1/a])*T_inlet(t)');
        temperature_bc.set('T0', 'T_inlet(t)');
    end
end

% -------------------------------------------------------------------------
% Crates bottom inlet boundary conditions
% -------------------------------------------------------------------------

for i = 1:length(borehole_tilt)
    temperature_bc = physics.create(sprintf('bottom_inlet_temperature_bc%d', i), 'TemperatureBoundary', 2);
    temperature_bc.label(sprintf('Borehole #%d Bottom Inlet Temperature BC', i));
    temperature_bc.selection.named(sprintf('geometry_bottom_inlet_selection%d', i));
    temperature_bc.set('T0', sprintf('T_bottom%d', i));
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates events (if inlet temperature is not scalar)
% =========================================================================

fprintf(1, 'init_model: Creating events... ');

month_names = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August','September', 'October', 'November', 'December'};

if length(T_inlet) == 12

    events = component.physics.create('ev', 'Events', 'geometry');
    
    for i = 1:12
    
        event = events.create(sprintf('explicit_event%d',i), 'ExplicitEvent', -1);
        event.set('start', sprintf('(%d/12)[a]', i-1));
        event.set('period', '1[a]');
        event.label(sprintf('%s Event', month_names{i}));
        
    end
    
end

fprintf(1, 'Done.\n');

% =========================================================================
% Creates study and solution
% =========================================================================

fprintf(1, 'init_model: Creating study and solution... ');

model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').feature('t1').feature.remove('dDef');

model.study('std1').setGenPlots(false);
model.study('std1').feature('time').set('tunit', 'a');
model.study('std1').feature('time').set('tlist', '0 100');
model.study('std1').feature('time').set('usertol', true);
model.study('std1').feature('time').set('rtol', '1e-2');

if length(T_inlet) == 12
    model.study('std1').feature('time').activate('ev', true);
end

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clist', {'0 100' '1e-6[a]'});
model.sol('sol1').feature('t1').set('tunit', 'a');
model.sol('sol1').feature('t1').set('tlist', '0 100');
model.sol('sol1').feature('t1').set('rtol', '1e-2');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').set('plot', true);
model.sol('sol1').feature('t1').set('tout', 'tsteps');
model.sol('sol1').feature('t1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol1').feature('t1').feature('fc1').set('damp', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
model.sol('sol1').feature('t1').feature('fc1').set('aaccdim', 5);
model.sol('sol1').feature('t1').feature('fc1').set('aaccmix', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('aaccdelay', 1);
model.sol('sol1').feature('t1').feature('d1').label('Direct, Heat Transfer Variables (physics)');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tout', 'tsteps');
model.sol('sol1').feature('t1').set('initialstepbdfactive', true);
model.sol('sol1').feature('t1').set('initialstepbdf', '1e-6');

% model.sol('sol1').runAll;

fprintf(1, 'Done.\n');

% =========================================================================
% Creates results
% =========================================================================

fprintf(1, 'init_model: Creating results... ');

% -------------------------------------------------------------------------
% Individual heat rates
% -------------------------------------------------------------------------

plot_group = model.result.create('plot_group1', 'PlotGroup1D');
plot_group.label('Individual heat rates');
plot_group.set('xlabel', 'Time [a]');
plot_group.set('xlabelactive', false);
plot_group.set('ylabel', 'Heat rate through single borehole wall [W]');
plot_group.set('ylabelactive', false);
plot_group.set('titletype', 'manual');
plot_group.set('title', 'Individual heat rates');

global_plot = plot_group.create(sprintf('global_plot%d',i), 'Global');
global_plot.set('expr', compose('Q_wall%d', 1:length(borehole_tilt)));
global_plot.set('unit', repelem({'kW'},1,length(borehole_tilt)));
global_plot.set('descr', compose('Borehole #%d', 1:length(borehole_tilt)));

% -------------------------------------------------------------------------
% Total heat rate
% -------------------------------------------------------------------------

plot_group = model.result.create('plot_group2', 'PlotGroup1D');
plot_group.label('Total heat rate');
plot_group.set('xlabel', 'Time [a]');
plot_group.set('xlabelactive', false);
plot_group.set('ylabel', 'Total heat rate through all borehole walls [W]');
plot_group.set('ylabelactive', false);
plot_group.set('titletype', 'manual');
plot_group.set('title', 'Total heat rate');

global_plot = plot_group.create(sprintf('global_plot%d',i), 'Global');
global_plot.set('expr', 'Q_walls');
global_plot.set('unit', 'kW');
global_plot.set('descr', 'Total heat rate');

% -------------------------------------------------------------------------
% Fluid temperatures
% -------------------------------------------------------------------------

line_colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'gray'};

plot_group = model.result.create('plot_group3', 'PlotGroup1D');
plot_group.label('Fluid temperatures');
plot_group.set('titletype', 'manual');
plot_group.set('title', 'Fluid temperatures');

for i = 1:length(borehole_tilt)

    line_graph = plot_group.create(sprintf('inner_line%d',i), 'LineGraph');
    line_graph.selection.named(sprintf('geometry_inner_edge_selection%d', i));
    line_graph.set('expr', sprintf('-sqrt((x-nx%d*borehole_offset)^2+(z-nz%d*borehole_offset)^2)', i, i));
    line_graph.set('xdata', 'expr');
    line_graph.set('xdataunit', 'degC');
    line_graph.set('linecolor', line_colors{mod(i,length(line_colors))+1});
    line_graph.set('resolution', 'normal');

    line_graph = plot_group.create(sprintf('outer_line%d',i), 'LineGraph');
    line_graph.selection.named(sprintf('geometry_outer_edge_selection%d', i));
    line_graph.set('expr', sprintf('-sqrt((x-nx%d*borehole_offset)^2+(z-nz%d*borehole_offset)^2)', i, i));
    line_graph.set('xdata', 'expr');
    line_graph.set('xdataunit', 'degC');
    line_graph.set('linecolor', line_colors{mod(i,length(line_colors))+1});
    line_graph.set('resolution', 'normal');

end

% plot_group.set('looplevelinput', {'last'});
plot_group.set('xlabel', 'Temperature [degC]');
plot_group.set('ylabel', 'Distance along borehole axis [m]');
plot_group.set('showlegends', false);
plot_group.set('xlabelactive', false);
plot_group.set('ylabelactive', false);

% -------------------------------------------------------------------------
% Inlet and outlet temperatures
% -------------------------------------------------------------------------

plot_group = model.result.create('plot_group4', 'PlotGroup1D');
plot_group.label('Inlet and outlet temperatures');
plot_group.set('xlabel', 'Time [a]');
plot_group.set('ylabel', 'Temperature [degC]');
plot_group.set('xlabelactive', false);
plot_group.set('ylabelactive', false);

global_plot1 = plot_group.create('global_plot1', 'Global');
global_plot2 = plot_group.create('global_plot2', 'Global');

if length(T_inlet) == 1
    global_plot1.set('expr', {'T_inlet'});
else
    global_plot1.set('expr', {'T_inlet(t)'});
end

global_plot1.set('descr', {'Inlet Temperature'});
global_plot1.set('unit', {'degC'});
global_plot1.set('linemarker', 'point');
global_plot1.set('markerpos', 'datapoints');

global_plot2.set('expr', compose('T_outlet%d', 1:length(borehole_tilt)));
global_plot2.set('unit', repelem({'degC'},1,length(borehole_tilt)));
global_plot2.set('descr', compose('Borehole #%d', 1:length(borehole_tilt)));
global_plot2.set('linemarker', 'point');
global_plot2.set('markerpos', 'datapoints');

% -------------------------------------------------------------------------
% Cut plane
% -------------------------------------------------------------------------

cut_plane = model.result.dataset.create('cut_plane', 'CutPlane');
cut_plane.set('quickplane', 'xz');

plot_group = model.result.create('plot_group5', 'PlotGroup2D');

surface = plot_group.create('surface', 'Surface');
surface.set('unit', 'degC');
surface.set('resolution', 'normal');

contour = plot_group.create('contour', 'Contour');
contour.set('expr', 'T-T_initial(z-tunnel_depth)');
contour.set('levelmethod', 'levels');
contour.set('levels', '-0.1 -0.01 -0.001');
contour.set('coloring', 'uniform');
contour.set('color', 'black');
contour.set('resolution', 'normal');

fprintf(1, 'Done.\n');

% =========================================================================
% Makes tensor models
% =========================================================================

% make_tensor_models(model);

fprintf(1, 'init_model: Completed.\n');
