classdef BoreholeHeatExchanger
    
    properties
        
        borehole_index;     % Index of the borehole in the borehole_tilt array.
        borehole_distance;  % Distance of the borehole from the model center measured in slice widths.
        symmetry_planes;    % Number of symmetry planes along the axis of the borehole.
        
    end
    
    methods (Static)
        
        function result = getCount(counter_name)
            
            persistent counter_map;
            
            if isempty(counter_map)
                counter_map = containers.Map;
            end
            
            if counter_map.isKey(counter_name)
                counter_map(counter_name) = counter_map(counter_name) + 1;
            else
                counter_map(counter_name) = 1;
            end
            
            result = counter_map(counter_name);
            
        end
        
    end
    
    methods
        
        function obj = BoreholeHeatExchanger(borehole_index, borehole_distance, symmetry_planes)
            
            assert(borehole_index > 0)
            assert(borehole_distance >= 0)
            assert((symmetry_planes >= 0) && (symmetry_planes <= 2))
            
            obj.borehole_index = borehole_index;
            obj.borehole_distance = borehole_distance;
            obj.symmetry_planes = symmetry_planes;
            
        end
        
        function createGeometry(obj, geometry)
            
            % -------------------------------------------------------------
            % Creates a work plane, constructs the inner structure of the
            % borehole on the work plane and extrudes the work plane to
            % make it three dimensional.
            % -------------------------------------------------------------
            
            work_plane_tag = geometry.feature().uniquetag("work_plane");
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalvector', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            
            work_plane.set('normalcoord', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            
            work_plane.set('unite', true);
            
            obj.createWorkPlaneStructure(work_plane, 'full');
            
            extrusion_tag = geometry.feature().uniquetag('extrusion');
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            
            extrusion.setIndex('distance', 'L_borehole', 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            % -------------------------------------------------------------
            % Creates a three dimensional helper cylinder above the
            % borehole to make meshing easier.
            % -------------------------------------------------------------
            
            work_plane_tag = geometry.feature().uniquetag("work_plane");
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalvector', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            
            work_plane.set('normalcoord', {sprintf('nx%d*(borehole_offset-r_buffer)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset-r_buffer)', obj.borehole_index)});
            
            work_plane.set('unite', true);
            
            obj.createWorkPlaneStructure(work_plane, 'buffer');
            
            extrusion_tag = geometry.feature().uniquetag('extrusion');
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            extrusion.setIndex('distance', 'r_buffer', 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
            % -------------------------------------------------------------
            % Creates a three dimensional helper cylinder below the
            % borehole to make meshing easier.
            % -------------------------------------------------------------
            
            work_plane_tag = geometry.feature().uniquetag("work_plane");
            
            work_plane = geometry.create(work_plane_tag, 'WorkPlane');
            
            work_plane.set('planetype', 'normalvector');
            work_plane.set('normalvector', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            
            work_plane.set('normalcoord', {sprintf('nx%d*(borehole_offset+L_borehole)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset+L_borehole)', obj.borehole_index)});
            
            work_plane.set('unite', true);
            
            obj.createWorkPlaneStructure(work_plane, 'buffer');
            
            extrusion_tag = geometry.feature().uniquetag('extrusion');
            
            extrusion = geometry.create(extrusion_tag, 'Extrude');
            extrusion.setIndex('distance', 'r_buffer', 0);
            extrusion.selection('input').set(char(work_plane_tag));
            
        end
        
        function createSelections(obj, geometry)
            
            % -------------------------------------------------------------
            % Creates a selection containing the buffer zone around the
            % borehole.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('buffer_zone_selection');
            
            selection = geometry.create(sprintf('buffer_zone_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Buffer Zone Selection %d', counter));
            
            selection.set('r', 'r_buffer+1[mm]');
            selection.set('rin', 'r_borehole-1[mm]');
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the outer fluid domain.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('outer_fluid_selection');
            
            selection = geometry.create(sprintf('outer_fluid_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Outer Fluid Selection %d', counter));
            
            selection.set('r', 'r_borehole+1[mm]');
            selection.set('rin', 'r_outer-1[mm]');
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the pipe wall domain.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('pipe_wall_selection');
            
            selection = geometry.create(sprintf('pipe_wall_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Pipe Wall Selection %d', counter));
            
            selection.set('r', 'r_outer+1[mm]');
            %selection.set('rin', 'r_inner-1[mm]');
            selection.set('rin', '+1[mm]'); %%% HACK %%%
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            %selection.set('condition', 'allvertices');
            selection.set('condition', 'inside'); %%% HACK %%%
            
            % -------------------------------------------------------------
            % Creates a selection containing the inner fluid domain.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('inner_fluid_selection');
            
            selection = geometry.create(sprintf('inner_fluid_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Inner Fluid Selection %d', counter));
            
            selection.set('r', 'r_inner+1[mm]');
            selection.set('rin', '0');
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the borehole wall.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('borehole_wall_selection');
            
            selection = geometry.create(sprintf('borehole_wall_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Borehole Wall Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_borehole+1[mm]');
            selection.set('rin', 'r_borehole-1[mm]');
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the upper helper cylinder.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('upper_helper_cylinder_selection');
            
            selection = geometry.create(sprintf('upper_helper_cylinder_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Upper Helper Cylinder Selection %d', counter));
            
            selection.set('r', 'r_buffer+1[mm]');
            selection.set('rin', '0');
            selection.set('top', 'r_buffer+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*(borehole_offset-r_buffer)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset-r_buffer)', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the lower helper cylinder.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('lower_helper_cylinder_selection');
            
            selection = geometry.create(sprintf('lower_helper_cylinder_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Lower Helper Cylinder Selection %d', counter));
            
            selection.set('r', 'r_buffer+1[mm]');
            selection.set('rin', '0');
            selection.set('top', 'r_buffer+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset+L_borehole)', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a helper selection containing the upper cap of the
            % buffer zone.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('outer_cap_helper_selection');
            
            selection = geometry.create(sprintf('outer_cap_helper_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Outer Cap Helper Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_buffer+1[mm]');
            selection.set('rin', 'r_borehole-1[mm]');
            selection.set('top', '+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a helper selection containing the upper cap of the
            % borehole structure.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('inner_cap_helper_selection');
            
            selection = geometry.create(sprintf('inner_cap_helper_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Inner Cap Helper Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_borehole+1[mm]');
            selection.set('rin', '0');
            selection.set('top', '+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the top inlet.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('top_inlet_selection');
            
            selection = geometry.create(sprintf('top_inlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Top Inlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_borehole+1[mm]');
            selection.set('rin', 'r_outer-1[mm]');
            selection.set('top', '+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the top outlet.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('top_outlet_selection');
            
            selection = geometry.create(sprintf('top_outlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Top Outlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_inner+1[mm]');
            selection.set('rin', '0');
            selection.set('top', '+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the bottom outlet.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('bottom_outlet_selection');
            
            selection = geometry.create(sprintf('bottom_outlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Bottom Outlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_borehole+1[mm]');
            selection.set('rin', 'r_outer-1[mm]');
            selection.set('top', '+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('angle1', '0');
            selection.set('angle2', '360');
            selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset+L_borehole)', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing the bottom inlet.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('bottom_inlet_selection');
            
            selection = geometry.create(sprintf('bottom_inlet_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Bottom Inlet Selection %d', counter));
            
            selection.set('entitydim', 2);
            selection.set('r', 'r_inner+1[mm]');
            selection.set('rin', '0');
            selection.set('top', '+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('angle1', '0');
            selection.set('angle2', '360');
            selection.set('pos', {sprintf('nx%d*(borehole_offset+L_borehole)', obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*(borehole_offset+L_borehole)', obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing an edge in the inner fluid.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('inner_fluid_edge_selection');
            
            selection = geometry.create(sprintf('inner_fluid_edge_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Inner Fluid Edge Selection %d', counter));
            
            selection.set('entitydim', 1);
            selection.set('r', '+1[mm]');
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_inner', obj.borehole_index, obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset+nx%d*r_inner', obj.borehole_index, obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
            % -------------------------------------------------------------
            % Creates a selection containing an edge in the outer fluid.
            % -------------------------------------------------------------
            
            counter = Borehole.getCount('outer_fluid_edge_selection');
            
            selection = geometry.create(sprintf('outer_fluid_edge_selection%d', counter), 'CylinderSelection');
            selection.label(sprintf('Outer Fluid Edge Selection %d', counter));
            
            selection.set('entitydim', 1);
            selection.set('r', '+1[mm]');
            selection.set('top', 'L_borehole+1[mm]');
            selection.set('bottom', '-1[mm]');
            selection.set('pos', {sprintf('nx%d*borehole_offset-nz%d*r_outer', obj.borehole_index, obj.borehole_index) sprintf('%f*slice_width', obj.borehole_distance) sprintf('nz%d*borehole_offset+nx%d*r_outer', obj.borehole_index, obj.borehole_index)});
            selection.set('axis', {sprintf('nx%d', obj.borehole_index) '0' sprintf('nz%d', obj.borehole_index)});
            selection.set('condition', 'allvertices');
            
        end
        
        function createWorkPlaneStructure(obj, work_plane, level_of_detail)
            
            assert(strcmp(level_of_detail, 'buffer') || strcmp(level_of_detail, 'full'));
            
            if obj.borehole_distance == 0
                
                if obj.symmetry_planes == 0
                    
                    circle = work_plane.geom.create('buffer_circle', 'Circle');
                    circle.set('r', 'r_buffer');
                    
                    if strcmp(level_of_detail, 'full')
                        
                        circle = work_plane.geom.create('borehole_circle', 'Circle');
                        circle.set('r', 'r_borehole');
                        
                        circle = work_plane.geom.create('outer_circle', 'Circle');
                        circle.set('r', 'r_outer');
                        
                        circle = work_plane.geom.create('inner_circle', 'Circle');
                        circle.set('r', 'r_inner');
                        
                    end
                    
                elseif obj.symmetry_planes == 1
                    
                    circle = work_plane.geom.create('buffer_circle', 'Circle');
                    circle.set('r', 'r_buffer');
                    circle.set('rot', '0');
                    circle.set('angle', '180');
                    
                    if strcmp(level_of_detail, 'full')
                        
                        circle = work_plane.geom.create('borehole_circle', 'Circle');
                        circle.set('r', 'r_borehole');
                        circle.set('rot', '0');
                        circle.set('angle', '180');
                        
                        circle = work_plane.geom.create('outer_circle', 'Circle');
                        circle.set('r', 'r_outer');
                        circle.set('rot', '0');
                        circle.set('angle', '180');
                        
                        circle = work_plane.geom.create('inner_circle', 'Circle');
                        circle.set('r', 'r_inner');
                        circle.set('rot', '0');
                        circle.set('angle', '180');
                        
                    end
                    
                elseif obj.symmetry_planes == 2
                    
                    circle = work_plane.geom.create('buffer_circle', 'Circle');
                    circle.set('r', 'r_buffer');
                    circle.set('rot', '90');
                    circle.set('angle', '90');
                    
                    if strcmp(level_of_detail, 'full')
                        
                        circle = work_plane.geom.create('borehole_circle', 'Circle');
                        circle.set('r', 'r_borehole');
                        circle.set('rot', '90');
                        circle.set('angle', '90');
                        
                        circle = work_plane.geom.create('outer_circle', 'Circle');
                        circle.set('r', 'r_outer');
                        circle.set('rot', '90');
                        circle.set('angle', '90');
                        
                        circle = work_plane.geom.create('inner_circle', 'Circle');
                        circle.set('r', 'r_inner');
                        circle.set('rot', '90');
                        circle.set('angle', '90');
                        
                    end
                    
                end
                
            else
                
                if obj.symmetry_planes == 0
                    
                    circle = work_plane.geom.create('buffer_circle', 'Circle');
                    circle.set('r', 'r_buffer');
                    
                    if strcmp(level_of_detail, 'full')
                        
                        circle = work_plane.geom.create('borehole_circle', 'Circle');
                        circle.set('r', 'r_borehole');
                        
                        circle = work_plane.geom.create('outer_circle', 'Circle');
                        circle.set('r', 'r_outer');
                        
                        circle = work_plane.geom.create('inner_circle', 'Circle');
                        circle.set('r', 'r_inner');
                        
                    end
                    
                elseif obj.symmetry_planes == 1
                    
                    circle = work_plane.geom.create('buffer_circle', 'Circle');
                    circle.set('r', 'r_buffer');
                    circle.set('rot', '90');
                    circle.set('angle', '180');
                    
                    if strcmp(level_of_detail, 'full')
                        
                        circle = work_plane.geom.create('borehole_circle', 'Circle');
                        circle.set('r', 'r_borehole');
                        circle.set('rot', '90');
                        circle.set('angle', '180');
                        
                        circle = work_plane.geom.create('outer_circle', 'Circle');
                        circle.set('r', 'r_outer');
                        circle.set('rot', '90');
                        circle.set('angle', '180');
                        
                        circle = work_plane.geom.create('inner_circle', 'Circle');
                        circle.set('r', 'r_inner');
                        circle.set('rot', '90');
                        circle.set('angle', '180');
                        
                    end
                    
                elseif obj.symmetry_planes == 2
                    
                    error('Invalid number of symmetry planes.');
                    
                end
                
            end
        end
        
    end
    
end
