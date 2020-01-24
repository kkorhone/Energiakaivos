classdef Borehole
    
    properties
        borehole_id
        borehole_location, borehole_tilt, borehole_azimuth, borehole_offset, borehole_length, buffer_radius, borehole_radius, outer_radius, inner_radius
        borehole_axis
    end
    
    methods (Static)

        function result = vectorToCell(vector)
            result = {Borehole.numberToString(vector(1)), Borehole.numberToString(vector(2)), Borehole.numberToString(vector(3))};
        end
        
        function result = numberToString(number)
            result = sprintf('%.6f', number);
        end
        
        function result = nextBoreholeId()
            persistent borehole_id
            if isempty(borehole_id)
                borehole_id = 1;
            else
                borehole_id = borehole_id + 1;
            end
            result = borehole_id;
        end
        
    end
    
    methods
        
        function obj = Borehole(borehole_location, borehole_tilt, borehole_azimuth, borehole_offset, borehole_length, buffer_radius, borehole_radius, outer_radius, inner_radius)
            
            obj.borehole_id = Borehole.nextBoreholeId();
            
            obj.borehole_location = borehole_location;
            obj.borehole_tilt = borehole_tilt;
            obj.borehole_azimuth = borehole_azimuth;
            obj.borehole_offset = borehole_offset;
            obj.borehole_length = borehole_length;
            obj.buffer_radius = buffer_radius;
            obj.borehole_radius = borehole_radius;
            obj.outer_radius = outer_radius;
            obj.inner_radius = inner_radius;
            
            theta = pi * borehole_tilt / 180;
            phi = pi * borehole_azimuth / 180;
            
            rotation_matrix = [cos(phi)*cos(theta) -sin(phi) -sin(theta)*cos(phi); sin(phi)*cos(theta) cos(phi) -sin(phi)*sin(theta); sin(theta) 0 cos(theta)];
            
            obj.borehole_axis = transpose(rotation_matrix * transpose([1 0 0]));
            
        end
        
        function createGeometry(obj, geometry)
            
            % Creates the borehole heat exchanger structure.

            borehole_collar = obj.borehole_location + obj.borehole_offset * obj.borehole_axis;

            work_plane_tag = sprintf('work_plane%d_borehole_structure', obj.borehole_id);
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalcoord', Borehole.vectorToCell(borehole_collar));
            work_plane.set('normalvector', Borehole.vectorToCell(obj.borehole_axis));
            
            work_plane.set('unite', true);
            
            buffer_circle = work_plane.geom.create('buffer_circle', 'Circle');
            buffer_circle.set('r', obj.buffer_radius');

            borehole_circle = work_plane.geom.create('borehole_circle', 'Circle');
            borehole_circle.set('r', obj.borehole_radius);

            outer_circle = work_plane.geom.create('outer_circle', 'Circle');
            outer_circle.set('r', obj.outer_radius);

            inner_circle = work_plane.geom.create('inner_circle', 'Circle');
            inner_circle.set('r', obj.inner_radius);
            
            extrusion_tag = sprintf('extrude%d_borehole_structure', obj.borehole_id);
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            
            extrusion.setIndex('distance', obj.borehole_length, 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            % Creates the upper cylinder above the borehole heat exchanger.
            
            buffer_collar = obj.borehole_location + (obj.borehole_offset - obj.buffer_radius) * obj.borehole_axis;
            
            work_plane_tag = sprintf('work_plane%d_upper_cylinder', obj.borehole_id);
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalcoord', Borehole.vectorToCell(buffer_collar));
            work_plane.set('normalvector', Borehole.vectorToCell(obj.borehole_axis));
            
            work_plane.set('unite', true);
            
            buffer_circle = work_plane.geom.create('buffer_circle', 'Circle');
            buffer_circle.set('r', obj.buffer_radius');
            
            extrusion_tag = sprintf('extrude%d_upper_cylinder', obj.borehole_id);
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            
            extrusion.setIndex('distance', obj.buffer_radius, 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            % Creates the lower cylinder below the borehole heat exchanger.
            
            borehole_footer = obj.borehole_location + (obj.borehole_offset + obj.borehole_length) * obj.borehole_axis;
            
            work_plane_tag = sprintf('work_plane%d_lower_cylinder', obj.borehole_id);
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalcoord', Borehole.vectorToCell(borehole_footer));
            work_plane.set('normalvector', Borehole.vectorToCell(obj.borehole_axis));
            
            work_plane.set('unite', true);
            
            buffer_circle = work_plane.geom.create('buffer_circle', 'Circle');
            buffer_circle.set('r', obj.buffer_radius');
            
            extrusion_tag = sprintf('extrude%d_lower_cylinder', obj.borehole_id);
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            
            extrusion.setIndex('distance', obj.buffer_radius, 0);
            extrusion.selection('input').set(char(work_plane_tag));

        end
        
        function createSelections(obj, geometry)
            
            borehole_collar = obj.borehole_location + obj.borehole_offset * obj.borehole_axis;
            borehole_footer = obj.borehole_location + (obj.borehole_offset + obj.borehole_length) * obj.borehole_axis;
            buffer_collar = obj.borehole_location + (obj.borehole_offset - obj.buffer_radius) * obj.borehole_axis;
            
            % Creates a selection containing the buffer zone.
            
            buffer_zone_selection_tag = sprintf('buffer_zone_selection%d', obj.borehole_id);
            
            buffer_zone_selection = geometry.create(buffer_zone_selection_tag, 'CylinderSelection');
            buffer_zone_selection.label(sprintf('Buffer Zone Selection %d', obj.borehole_id));
            
            buffer_zone_selection.set('r', obj.buffer_radius+0.001);
            buffer_zone_selection.set('rin', obj.borehole_radius-0.001);
            buffer_zone_selection.set('top', obj.borehole_length+0.001);
            buffer_zone_selection.set('bottom', -0.001);
            buffer_zone_selection.set('pos', Borehole.vectorToCell(borehole_collar));
            buffer_zone_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            buffer_zone_selection.set('condition', 'allvertices');
            
            % Creates a selection containing the outer fluid.
            
            outer_fluid_selection_tag = sprintf('outer_fluid_selection%d', obj.borehole_id);
            
            outer_fluid_selection = geometry.create(outer_fluid_selection_tag, 'CylinderSelection');
            outer_fluid_selection.label(sprintf('Outer Fluid Selection %d', obj.borehole_id));
            
            outer_fluid_selection.set('r', obj.borehole_radius+0.001);
            outer_fluid_selection.set('rin', obj.outer_radius-0.001);
            outer_fluid_selection.set('top', obj.borehole_length+0.001);
            outer_fluid_selection.set('bottom', -0.001);
            outer_fluid_selection.set('pos', Borehole.vectorToCell(borehole_collar));
            outer_fluid_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            outer_fluid_selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the pipe wall domain.
            % -------------------------------------------------------------
            
            pipe_wall_selection_tag = sprintf('pipe_wall_selection%d', obj.borehole_id);
            
            pipe_wall_selection = geometry.create(pipe_wall_selection_tag, 'CylinderSelection');
            pipe_wall_selection.label(sprintf('Pipe Wall Selection %d', obj.borehole_id));
            
            pipe_wall_selection.set('r', obj.outer_radius+0.001);
            %pipe_wall_selection.set('rin', obj.inner_radius-0.001);
            pipe_wall_selection.set('rin', +0.001); %%% HACK %%%
            pipe_wall_selection.set('top', obj.borehole_length+0.001);
            pipe_wall_selection.set('bottom', -0.001);
            pipe_wall_selection.set('pos', Borehole.vectorToCell(borehole_collar));
            pipe_wall_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            %pipe_wall_selection.set('condition', 'allvertices');
            pipe_wall_selection.set('condition', 'inside'); %%% HACK %%%
            
            % -------------------------------------------------------------
            % Creates a selection containing the inner fluid domain.
            % -------------------------------------------------------------
            
            inner_fluid_selection_tag = sprintf('inner_fluid_selection%d', obj.borehole_id);
            
            inner_fluid_selection = geometry.create(inner_fluid_selection_tag, 'CylinderSelection');
            inner_fluid_selection.label(sprintf('Inner Fluid Selection %d', obj.borehole_id));
            
            inner_fluid_selection.set('r', obj.inner_radius+0.001);
            inner_fluid_selection.set('rin', '0');
            inner_fluid_selection.set('top', obj.borehole_length+0.001);
            inner_fluid_selection.set('bottom', -0.001);
            inner_fluid_selection.set('pos', Borehole.vectorToCell(borehole_collar));
            inner_fluid_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            inner_fluid_selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the borehole wall.
            % -------------------------------------------------------------
            
            borehole_wall_selection_tag = sprintf('borehole_wall_selection%d', obj.borehole_id);
            
            borehole_wall_selection = geometry.create(borehole_wall_selection_tag, 'CylinderSelection');
            borehole_wall_selection.label(sprintf('Borehole Wall Selection %d', obj.borehole_id));
            
            borehole_wall_selection.set('entitydim', 2);
            borehole_wall_selection.set('r', obj.borehole_radius+0.001);
            borehole_wall_selection.set('rin', obj.borehole_radius-0.001);
            borehole_wall_selection.set('top', obj.borehole_length+0.001);
            borehole_wall_selection.set('bottom', -0.001);
            borehole_wall_selection.set('pos', Borehole.vectorToCell(borehole_collar));
            borehole_wall_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            borehole_wall_selection.set('condition', 'allvertices');

            % -------------------------------------------------------------
            % Creates a selection containing the upper helper cylinder.
            % -------------------------------------------------------------
            
            upper_cylinder_selection_tag = sprintf('upper_cylinder_selection%d', obj.borehole_id);
            
            upper_cylinder_selection = geometry.create(upper_cylinder_selection_tag, 'CylinderSelection');
            upper_cylinder_selection.label(sprintf('Upper Cylinder Selection %d', obj.borehole_id));
            
            upper_cylinder_selection.set('r', obj.buffer_radius+0.001);
            upper_cylinder_selection.set('rin', '0');
            upper_cylinder_selection.set('top', obj.buffer_radius+0.001);
            upper_cylinder_selection.set('bottom', -0.001);
            upper_cylinder_selection.set('pos', Borehole.vectorToCell(buffer_collar));
            upper_cylinder_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            upper_cylinder_selection.set('condition', 'allvertices');

            % -------------------------------------------------------------
            % Creates a selection containing the lower helper cylinder.
            % -------------------------------------------------------------
            
            lower_cylinder_selection_tag = sprintf('lower_cylinder_selection%d', obj.borehole_id);
            
            lower_cylinder_selection = geometry.create(lower_cylinder_selection_tag, 'CylinderSelection');
            lower_cylinder_selection.label(sprintf('Lower Cylinder Selection %d', obj.borehole_id));
            
            lower_cylinder_selection.set('r', obj.buffer_radius+0.001);
            lower_cylinder_selection.set('rin', '0');
            lower_cylinder_selection.set('top', obj.buffer_radius+0.001);
            lower_cylinder_selection.set('bottom', -0.001);
            lower_cylinder_selection.set('pos', Borehole.vectorToCell(borehole_footer));
            lower_cylinder_selection.set('axis', Borehole.vectorToCell(obj.borehole_axis));
            lower_cylinder_selection.set('condition', 'allvertices');
return            
            % -------------------------------------------------------------
            % Creates a helper selection containing the upper cap of the
            % buffer zone.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('outer_cap_helper_selection');
            
            selection = geometry.create(sprintf('outer_cap_helper_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Outer Cap Helper Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', obj.buffer_radius+0.001);
            selection.set('rin', obj.borehole_radius-0.001);
            selection.set('top', +0.001);
            selection.set('bottom', -0.001);
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a helper selection containing the upper cap of the
            % borehole structure.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('inner_cap_helper_selection');
            
            selection = geometry.create(sprintf('inner_cap_helper_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Inner Cap Helper Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', obj.borehole_radius+0.001);
            selection.set('rin', '0');
            selection.set('top', +0.001);
            selection.set('bottom', -0.001);
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the top inlet.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('top_inlet_selection');
            
            selection = geometry.create(sprintf('top_inlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Top Inlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', obj.borehole_radius+0.001);
            selection.set('rin', obj.outer_radius-0.001);
            selection.set('top', +0.001);
            selection.set('bottom', -0.001);
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the top outlet.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('top_outlet_selection');
            
            selection = geometry.create(sprintf('top_outlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Top Outlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', obj.inner_radius+0.001);
            selection.set('rin', '0');
            selection.set('top', +0.001);
            selection.set('bottom', -0.001);
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the bottom outlet.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('bottom_outlet_selection');
            
            selection = geometry.create(sprintf('bottom_outlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Bottom Outlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', obj.borehole_radius+0.001);
            selection.set('rin', obj.outer_radius-0.001);
            selection.set('top', +0.001);
            selection.set('bottom', -0.001);
            selection.set('angle1', '0');
            selection.set('angle2', '360');
            selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset+L_borehole)', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the bottom inlet.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('bottom_inlet_selection');
            
            selection = geometry.create(sprintf('bottom_inlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Bottom Inlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', obj.inner_radius+0.001);
            selection.set('rin', '0');
            selection.set('top', +0.001);
            selection.set('bottom', -0.001);
            selection.set('angle1', '0');
            selection.set('angle2', '360');
            selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset+L_borehole)', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing an edge in the inner fluid.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('inner_fluid_edge_selection');
            
            selection = geometry.create(sprintf('inner_fluid_edge_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Inner Fluid Edge Selection %d', counter));
            
            selection.set('entitydim', 1);
            selection.set('r', +0.001);
            selection.set('top', obj.borehole_length+0.001);
            selection.set('bottom', -0.001);
            selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_inner', obj.borehole_index, obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset+nx%d*r_inner', obj.borehole_index, obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing an edge in the outer fluid.
            % -------------------------------------------------------------
            
            counter = BoreholeHeatExchanger.getCount('outer_fluid_edge_selection');
            
            selection = geometry.create(sprintf('outer_fluid_edge_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Outer Fluid Edge Selection %d', counter));
            
            selection.set('entitydim', 1);
            selection.set('r', +0.001);
            selection.set('top', obj.borehole_length+0.001);
            selection.set('bottom', -0.001);
            selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_outer', obj.borehole_index, obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset+nx%d*r_outer', obj.borehole_index, obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
        end
        
    end
    
end
