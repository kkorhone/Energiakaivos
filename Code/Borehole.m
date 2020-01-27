classdef Borehole
    
    properties
        borehole_id
        borehole_location, borehole_tilt, borehole_azimuth, borehole_offset, borehole_length, buffer_radius, borehole_radius, outer_radius, inner_radius
        borehole_axis
        mirror_planes
    end
    
%     methods (Static)
%         
%         function result = nextBoreholeId()
%             persistent borehole_id
%             if isempty(borehole_id)
%                 borehole_id = 1;
%             else
%                 borehole_id = borehole_id + 1;
%             end
%             result = borehole_id;
%         end
%         
%     end
    
    methods
        
        function obj = Borehole(borehole_location, borehole_tilt, borehole_azimuth, borehole_offset, borehole_length, buffer_radius, borehole_radius, outer_radius, inner_radius, mirror_planes)
            
            persistent borehole_id
            
            if isempty(borehole_id)
                borehole_id = 1;
            else
                borehole_id = borehole_id + 1;
            end
            
            obj.borehole_id = borehole_id; % Borehole.nextBoreholeId();
            
            obj.borehole_location = borehole_location;
            obj.borehole_tilt = borehole_tilt;
            obj.borehole_azimuth = borehole_azimuth;
            obj.borehole_offset = borehole_offset;
            obj.borehole_length = borehole_length;
            obj.buffer_radius = buffer_radius;
            obj.borehole_radius = borehole_radius;
            obj.outer_radius = outer_radius;
            obj.inner_radius = inner_radius;
            
            if nargin == 9
                obj.mirror_planes = [];
            else
                obj.mirror_planes = mirror_planes;
            end
            
            theta = pi * borehole_tilt / 180;
            phi = pi * borehole_azimuth / 180;
            
            rotation_matrix = [cos(phi)*cos(theta) -sin(phi) -sin(theta)*cos(phi); sin(phi)*cos(theta) cos(phi) -sin(phi)*sin(theta); sin(theta) 0 cos(theta)];
            
            obj.borehole_axis = transpose(rotation_matrix * transpose([1 0 0]));
            
            fprintf(1, 'Borehole.Borehole: Created borehole %d.\n', obj.borehole_id);
            
        end
        
        function createWorkPlaneStructure(obj, work_plane, radiuses)
            
            circle_tags = cell(size(radiuses));
            
            for i = 1:length(radiuses)
                
                circle_tags{i} = sprintf('circle%d', i);
                
                circle = work_plane.geom.create(circle_tags{i}, 'Circle');
                circle.label(sprintf('Circle %d', i));
                
                circle.set('r', radiuses(i)');
                
            end
            
            polygon_tags = cell(size(obj.mirror_planes));
            
            for i = 1:length(obj.mirror_planes)
                polygon_tags{i} = obj.mirror_planes{i}.createCutStructure(work_plane, max(radiuses));
            end
            
            if ~isempty(obj.mirror_planes)
                difference = work_plane.geom.create('difference', 'Difference');
                difference.selection('input').set(circle_tags);
                difference.selection('input2').set(polygon_tags);
            end
            
        end
        
        function createGeometry(obj, geometry)
            
            fprintf(1, 'Borehole.createGeometry: Created geometry for borehole %d... ', obj.borehole_id);
            
            % Creates the borehole heat exchanger structure.
            
            borehole_collar = obj.borehole_location + obj.borehole_offset * obj.borehole_axis;
            
            work_plane_tag = sprintf('work_plane%d_borehole_structure', obj.borehole_id);
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            work_plane.label(sprintf('Borehole Structure Work Plane %d', obj.borehole_id));
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalcoord', to_cell_array(borehole_collar));
            work_plane.set('normalvector', to_cell_array(obj.borehole_axis));
            
            work_plane.set('unite', true);
            
            obj.createWorkPlaneStructure(work_plane, [obj.buffer_radius, obj.borehole_radius, obj.outer_radius, obj.inner_radius]);
            
            extrusion_tag = sprintf('extrusion%d_borehole_structure', obj.borehole_id);
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            extrusion.label(sprintf('Borehole Structure Work Plane Extrusion %d', obj.borehole_id));
            
            extrusion.setIndex('distance', obj.borehole_length, 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            % Creates the upper cylinder above the borehole heat exchanger.
            
            buffer_collar = obj.borehole_location + (obj.borehole_offset - obj.buffer_radius) * obj.borehole_axis;
            
            work_plane_tag = sprintf('work_plane%d_upper_cylinder', obj.borehole_id);
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            work_plane.label(sprintf('Upper Cylinder Work Plane %d', obj.borehole_id));
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalcoord', to_cell_array(buffer_collar));
            work_plane.set('normalvector', to_cell_array(obj.borehole_axis));
            
            work_plane.set('unite', true);
            
            obj.createWorkPlaneStructure(work_plane, obj.buffer_radius);
            
            extrusion_tag = sprintf('extrusion%d_upper_cylinder', obj.borehole_id);
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            extrusion.label(sprintf('Upper Cylinder Work Plane Extrusion %d', obj.borehole_id));
            
            extrusion.setIndex('distance', obj.buffer_radius, 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            % Creates the lower cylinder below the borehole heat exchanger.
            
            borehole_footer = obj.borehole_location + (obj.borehole_offset + obj.borehole_length) * obj.borehole_axis;
            
            work_plane_tag = sprintf('work_plane%d_lower_cylinder', obj.borehole_id);
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            work_plane.label(sprintf('Lower Cylinder Work Plane %d', obj.borehole_id));
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalcoord', to_cell_array(borehole_footer));
            work_plane.set('normalvector', to_cell_array(obj.borehole_axis));
            
            work_plane.set('unite', true);
            
            obj.createWorkPlaneStructure(work_plane, obj.buffer_radius);
            
            extrusion_tag = sprintf('extrusion%d_lower_cylinder', obj.borehole_id);
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            extrusion.label(sprintf('Lower Cylinder Work Plane Extrusion %d', obj.borehole_id));
            
            extrusion.setIndex('distance', obj.buffer_radius, 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            fprintf(1, 'Done.\n');
            
        end
        
        function createSelections(obj, geometry)
            
            fprintf(1, 'Borehole.createSelections: Creating selections for borehole %d... ', obj.borehole_id);
            
            borehole_collar = obj.borehole_location + obj.borehole_offset * obj.borehole_axis;
            borehole_footer = obj.borehole_location + (obj.borehole_offset + obj.borehole_length) * obj.borehole_axis;
            buffer_collar = obj.borehole_location + (obj.borehole_offset - obj.buffer_radius) * obj.borehole_axis;
            
            % Creates a selection containing the buffer zone domain.
            
            buffer_zone_selection_tag = sprintf('buffer_zone_selection%d', obj.borehole_id);
            
            buffer_zone_selection = geometry.create(buffer_zone_selection_tag, 'CylinderSelection');
            buffer_zone_selection.label(sprintf('Buffer Zone Selection %d', obj.borehole_id));
            
            buffer_zone_selection.set('r', obj.buffer_radius+0.001);
            buffer_zone_selection.set('rin', obj.borehole_radius-0.001);
            buffer_zone_selection.set('top', obj.borehole_length+0.001);
            buffer_zone_selection.set('bottom', -0.001);
            buffer_zone_selection.set('pos', to_cell_array(borehole_collar));
            buffer_zone_selection.set('axis', to_cell_array(obj.borehole_axis));
            buffer_zone_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the outer fluid domain.
            
            outer_fluid_selection_tag = sprintf('outer_fluid_selection%d', obj.borehole_id);
            
            outer_fluid_selection = geometry.create(outer_fluid_selection_tag, 'CylinderSelection');
            outer_fluid_selection.label(sprintf('Outer Fluid Selection %d', obj.borehole_id));
            
            outer_fluid_selection.set('r', obj.borehole_radius+0.001);
            outer_fluid_selection.set('rin', obj.outer_radius-0.001);
            outer_fluid_selection.set('top', obj.borehole_length+0.001);
            outer_fluid_selection.set('bottom', -0.001);
            outer_fluid_selection.set('pos', to_cell_array(borehole_collar));
            outer_fluid_selection.set('axis', to_cell_array(obj.borehole_axis));
            outer_fluid_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the pipe wall domain.
            
            pipe_wall_selection_tag = sprintf('pipe_wall_selection%d', obj.borehole_id);
            
            pipe_wall_selection = geometry.create(pipe_wall_selection_tag, 'CylinderSelection');
            pipe_wall_selection.label(sprintf('Pipe Wall Selection %d', obj.borehole_id));
            
            pipe_wall_selection.set('r', obj.outer_radius+0.001);
            %pipe_wall_selection.set('rin', obj.inner_radius-0.001);
            pipe_wall_selection.set('rin', +0.001); %%% HACK %%%
            pipe_wall_selection.set('top', obj.borehole_length+0.001);
            pipe_wall_selection.set('bottom', -0.001);
            pipe_wall_selection.set('pos', to_cell_array(borehole_collar));
            pipe_wall_selection.set('axis', to_cell_array(obj.borehole_axis));
            %pipe_wall_selection.set('condition', 'allvertices');
            pipe_wall_selection.set('condition', 'inside'); %%% HACK %%%
            
            % Creates a selection containing the inner fluid domain.
            
            inner_fluid_selection_tag = sprintf('inner_fluid_selection%d', obj.borehole_id);
            
            inner_fluid_selection = geometry.create(inner_fluid_selection_tag, 'CylinderSelection');
            inner_fluid_selection.label(sprintf('Inner Fluid Selection %d', obj.borehole_id));
            
            inner_fluid_selection.set('r', obj.inner_radius+0.001);
            inner_fluid_selection.set('rin', '0');
            inner_fluid_selection.set('top', obj.borehole_length+0.001);
            inner_fluid_selection.set('bottom', -0.001);
            inner_fluid_selection.set('pos', to_cell_array(borehole_collar));
            inner_fluid_selection.set('axis', to_cell_array(obj.borehole_axis));
            inner_fluid_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the parts of the borehole structure.
            
            borehole_structure_selection_tag = sprintf('borehole_structure_selection%d', obj.borehole_id);
            
            borehole_structure_selection = geometry.create(borehole_structure_selection_tag, 'UnionSelection');
            borehole_structure_selection.set('input', {sprintf('buffer_zone_selection%d', obj.borehole_id) sprintf('outer_fluid_selection%d', obj.borehole_id) sprintf('pipe_wall_selection%d', obj.borehole_id) sprintf('inner_fluid_selection%d', obj.borehole_id)});
            
            % Creates a selection containing the borehole wall boundary.
            
            borehole_wall_selection_tag = sprintf('borehole_wall_selection%d', obj.borehole_id);
            
            borehole_wall_selection = geometry.create(borehole_wall_selection_tag, 'CylinderSelection');
            borehole_wall_selection.label(sprintf('Borehole Wall Selection %d', obj.borehole_id));
            
            borehole_wall_selection.set('entitydim', 2);
            borehole_wall_selection.set('r', obj.borehole_radius+0.001);
            borehole_wall_selection.set('rin', obj.borehole_radius-0.001);
            borehole_wall_selection.set('top', obj.borehole_length+0.001);
            borehole_wall_selection.set('bottom', -0.001);
            borehole_wall_selection.set('pos', to_cell_array(borehole_collar));
            borehole_wall_selection.set('axis', to_cell_array(obj.borehole_axis));
            borehole_wall_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the upper cylinder domain.
            
            upper_cylinder_selection_tag = sprintf('upper_cylinder_selection%d', obj.borehole_id);
            
            upper_cylinder_selection = geometry.create(upper_cylinder_selection_tag, 'CylinderSelection');
            upper_cylinder_selection.label(sprintf('Upper Cylinder Selection %d', obj.borehole_id));
            
            upper_cylinder_selection.set('r', obj.buffer_radius+0.001);
            upper_cylinder_selection.set('rin', '0');
            upper_cylinder_selection.set('top', obj.buffer_radius+0.001);
            upper_cylinder_selection.set('bottom', -0.001);
            upper_cylinder_selection.set('pos', to_cell_array(buffer_collar));
            upper_cylinder_selection.set('axis', to_cell_array(obj.borehole_axis));
            upper_cylinder_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the lower cylinder domain.
            
            lower_cylinder_selection_tag = sprintf('lower_cylinder_selection%d', obj.borehole_id);
            
            lower_cylinder_selection = geometry.create(lower_cylinder_selection_tag, 'CylinderSelection');
            lower_cylinder_selection.label(sprintf('Lower Cylinder Selection %d', obj.borehole_id));
            
            lower_cylinder_selection.set('r', obj.buffer_radius+0.001);
            lower_cylinder_selection.set('rin', '0');
            lower_cylinder_selection.set('top', obj.buffer_radius+0.001);
            lower_cylinder_selection.set('bottom', -0.001);
            lower_cylinder_selection.set('pos', to_cell_array(borehole_footer));
            lower_cylinder_selection.set('axis', to_cell_array(obj.borehole_axis));
            lower_cylinder_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the upper and lower cylinders.
            
            cylinders_selection_tag = sprintf('cylinders_selection%d', obj.borehole_id);
            
            cylinders_selection = geometry.create(cylinders_selection_tag, 'UnionSelection');
            cylinders_selection.set('input', {sprintf('upper_cylinder_selection%d', obj.borehole_id) sprintf('lower_cylinder_selection%d', obj.borehole_id)});
            
            % Creates a selection containing the outer cap boundary.
            
            outer_cap_selection_tag = sprintf('outer_cap_selection%d', obj.borehole_id);
            
            outer_cap_selection = geometry.create(outer_cap_selection_tag, 'CylinderSelection');
            outer_cap_selection.label(sprintf('Outer Cap Selection %d', obj.borehole_id));
            
            outer_cap_selection.set('entitydim', 2);
            outer_cap_selection.set('r', obj.buffer_radius+0.001);
            outer_cap_selection.set('rin', obj.borehole_radius-0.001);
            outer_cap_selection.set('top', +0.001);
            outer_cap_selection.set('bottom', -0.001);
            outer_cap_selection.set('pos', to_cell_array(borehole_collar));
            outer_cap_selection.set('axis', to_cell_array(obj.borehole_axis));
            %outer_cap_selection.set('condition', 'allvertices');
            outer_cap_selection.set('condition', 'inside'); %%% HACK %%%
            
            % Creates a selection containing the inner cap boundary.
            
            inner_cap_selection_tag = sprintf('inner_cap_selection%d', obj.borehole_id);
            
            inner_cap_selection = geometry.create(inner_cap_selection_tag, 'CylinderSelection');
            inner_cap_selection.label(sprintf('Inner Cap Selection %d', obj.borehole_id));
            
            inner_cap_selection.set('entitydim', 2);
            inner_cap_selection.set('r', obj.borehole_radius+0.001);
            inner_cap_selection.set('rin', 0);
            inner_cap_selection.set('top', +0.001);
            inner_cap_selection.set('bottom', -0.001);
            inner_cap_selection.set('pos', to_cell_array(borehole_collar));
            inner_cap_selection.set('axis', to_cell_array(obj.borehole_axis));
            inner_cap_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the top inlet boundary.
            
            top_inlet_selection_tag = sprintf('top_inlet_selection%d', obj.borehole_id);
            
            top_inlet_selection = geometry.create(top_inlet_selection_tag, 'CylinderSelection');
            top_inlet_selection.label(sprintf('Top Inlet Selection %d', obj.borehole_id));
            
            top_inlet_selection.set('entitydim', 2);
            top_inlet_selection.set('r', obj.borehole_radius+0.001);
            top_inlet_selection.set('rin', obj.outer_radius-0.001);
            top_inlet_selection.set('top', +0.001);
            top_inlet_selection.set('bottom', -0.001);
            top_inlet_selection.set('pos', to_cell_array(borehole_collar));
            top_inlet_selection.set('axis', to_cell_array(obj.borehole_axis));
            top_inlet_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the top outlet boundary.
            
            top_outlet_selection_tag = sprintf('top_outlet_selection%d', obj.borehole_id);
            
            top_outlet_selection = geometry.create(top_outlet_selection_tag, 'CylinderSelection');
            top_outlet_selection.label(sprintf('Top Outlet Selection %d', obj.borehole_id));
            
            top_outlet_selection.set('entitydim', 2);
            top_outlet_selection.set('r', obj.inner_radius+0.001);
            top_outlet_selection.set('rin', '0');
            top_outlet_selection.set('top', +0.001);
            top_outlet_selection.set('bottom', -0.001);
            top_outlet_selection.set('pos', to_cell_array(borehole_collar));
            top_outlet_selection.set('axis', to_cell_array(obj.borehole_axis));
            top_outlet_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the bottom outlet boundary.
            
            bottom_outlet_selection_tag = sprintf('bottom_outlet_selection%d', obj.borehole_id);
            
            bottom_outlet_selection = geometry.create(bottom_outlet_selection_tag, 'CylinderSelection');
            bottom_outlet_selection.label(sprintf('Bottom Outlet Selection %d', obj.borehole_id));
            
            bottom_outlet_selection.set('entitydim', 2);
            bottom_outlet_selection.set('r', obj.borehole_radius+0.001);
            bottom_outlet_selection.set('rin', obj.outer_radius-0.001);
            bottom_outlet_selection.set('top', +0.001);
            bottom_outlet_selection.set('bottom', -0.001);
            bottom_outlet_selection.set('pos', to_cell_array(borehole_footer));
            bottom_outlet_selection.set('axis', to_cell_array(obj.borehole_axis));
            bottom_outlet_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the bottom inlet boundary.
            
            bottom_inlet_selection_tag = sprintf('bottom_inlet_selection%d', obj.borehole_id);
            
            bottom_inlet_selection = geometry.create(bottom_inlet_selection_tag, 'CylinderSelection');
            bottom_inlet_selection.label(sprintf('Bottom Inlet Selection %d', obj.borehole_id));
            
            bottom_inlet_selection.set('entitydim', 2);
            bottom_inlet_selection.set('r', obj.inner_radius+0.001);
            bottom_inlet_selection.set('rin', '0');
            bottom_inlet_selection.set('top', +0.001);
            bottom_inlet_selection.set('bottom', -0.001);
            bottom_inlet_selection.set('pos', to_cell_array(borehole_footer));
            bottom_inlet_selection.set('axis', to_cell_array(obj.borehole_axis));
            bottom_inlet_selection.set('condition', 'allvertices');
            
            fprintf(1, 'Done.\n');
            
            % Creates a selection containing an edge in the inner fluid.
            
            %             edge_starting_point = obj.borehole_location + obj.borehole_offset * obj.borehole_axis +
            %
            %             inner_fluid_edge_selection_tag = sprintf('inner_fluid_edge_selection%d', obj.borehole_id);
            %
            %             inner_fluid_edge_selection = geometry.create(inner_fluid_edge_selection_tag, 'CylinderSelection');
            %             inner_fluid_edge_selection.label(sprintf('Bottom Inlet Selection %d', obj.borehole_id));
            %
            %             inner_fluid_edge_selection.set('entitydim', 1);
            %             inner_fluid_edge_selection.set('r', +0.001);
            %             inner_fluid_edge_selection.set('top', obj.borehole_length+0.001);
            %             inner_fluid_edge_selection.set('bottom', -0.001);
            %             selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_inner', obj.borehole_index, obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset+nx%d*r_inner', obj.borehole_index, obj.borehole_index)});
            %             bottom_inlet_selection.set('axis', to_cell_array(obj.borehole_axis));
            %             inner_fluid_edge_selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing an edge in the outer fluid.
            % -------------------------------------------------------------
            
            %             counter = BoreholeHeatExchanger.getCount('outer_fluid_edge_selection');
            %
            %             selection = geometry.create(sprintf('outer_fluid_edge_selection%d', counter), 'CylinderSelection');
            %             selection.label(sprintf('Outer Fluid Edge Selection %d', counter));
            %
            %             selection.set('entitydim', 1);
            %             selection.set('r', +0.001);
            %             selection.set('top', obj.borehole_length+0.001);
            %             selection.set('bottom', -0.001);
            %             selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_outer', obj.borehole_index, obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset+nx%d*r_outer', obj.borehole_index, obj.borehole_index)});
            %             selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            %             selection.set('condition', 'allvertices');
            
        end
        
        function createMesh(obj, mesh)
            
            fprintf(1, 'Borehole.createMesh: Creating mesh for borehole %d... ', obj.borehole_id);
            
            % Creates a mesh for the inner cap of the borehole structure.
            
            inner_cap_mesh_tag = sprintf('inner_cap_mesh%d', obj.borehole_id);
            
            inner_cap_mesh = mesh.create(inner_cap_mesh_tag, 'FreeTri');
            inner_cap_mesh.label(sprintf('Inner Cap Mesh %d', obj.borehole_id));
            
            inner_cap_mesh.selection.named(sprintf('geometry_inner_cap_selection%d', obj.borehole_id));
            
            size = inner_cap_mesh.create('size', 'Size');
            size.set('hauto', 1);
            size.set('custom', true);
            size.set('hmax', 0.015);
            size.set('hmaxactive', true);
            
            % Creates a mesh for the outer cap of the borehole structure.
            
            outer_cap_mesh_tag = sprintf('outer_cap_mesh%d', obj.borehole_id);
            
            outer_cap_mesh = mesh.create(outer_cap_mesh_tag, 'FreeTri');
            outer_cap_mesh.label(sprintf('Outer Cap Mesh %d', obj.borehole_id));
            
            outer_cap_mesh.selection.named(sprintf('geometry_outer_cap_selection%d', obj.borehole_id));
            
            size = outer_cap_mesh.create('size', 'Size');
            size.set('hauto', 1);
            size.set('custom', 'on');
            size.set('hgrad', 1.2);
            size.set('hgradactive', true);
            size.set('hmax', 0.1);
            size.set('hmaxactive', true);
            
            % Creates a swept mesh for the borehole structure.
            
            swept_mesh_tag = sprintf('swept_mesh%d', obj.borehole_id);
            
            swept_mesh = mesh.create(swept_mesh_tag, 'Sweep');
            swept_mesh.label(sprintf('Swept Mesh %d', obj.borehole_id));
            
            swept_mesh.selection.geom('geometry', 3);
            swept_mesh.selection.named(sprintf('geometry_borehole_structure_selection%d', obj.borehole_id));
            
            distribution = swept_mesh.create('distribution', 'Distribution');
            distribution.set('type', 'predefined');
            distribution.set('elemcount', 300);
            distribution.set('elemratio', 10);
            distribution.set('symmetric', true);
            
            % Creates meshes for the upper and lower cylinders.
            
            upper_cylinder_mesh_tag = sprintf('cylinders_mesh%d', obj.borehole_id);
            
            upper_cylinder_mesh = mesh.create(upper_cylinder_mesh_tag, 'FreeTet');
            upper_cylinder_mesh.label(sprintf('Cylinders Mesh %d', obj.borehole_id));
            
            upper_cylinder_mesh.selection.geom('geometry', 3);
            upper_cylinder_mesh.selection.named(sprintf('geometry_cylinders_selection%d', obj.borehole_id));
            
            size = upper_cylinder_mesh.create('size', 'Size');
            size.set('hauto', 3);
            
            fprintf(1, 'Done.\n');
            
        end
        
    end
    
end
