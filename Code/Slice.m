classdef Slice
    
    properties
        y1, y2, slice_width
        borehole_tilts, borehole_length, borehole_offset
        buffer_radius, borehole_radius, outer_radius, inner_radius
        borehole_array
    end
    
    methods
        
        function obj = Slice(y1, y2, slice_width, borehole_tilts, borehole_length, borehole_offset, buffer_radius, borehole_radius, outer_radius, inner_radius)
            
            obj.y1 = y1;
            obj.y2 = y2;
            obj.slice_width = slice_width;
            
            obj.borehole_tilts = sort(unique(borehole_tilts), 'ascend');
            obj.borehole_length = borehole_length;
            obj.borehole_offset = borehole_offset;
            
            obj.buffer_radius = buffer_radius;
            obj.borehole_radius = borehole_radius;
            obj.outer_radius = outer_radius;
            obj.inner_radius = inner_radius;
            
            obj.borehole_array = cell(1, length(borehole_tilts));
            
            for i = 1:length(obj.borehole_tilts)
                if y2 - y1 == slice_width
                    borehole_location = [0, 0, 0];
                else
                    borehole_location = [0, 0.5*(y1+y2), 0];
                end
                obj.borehole_array{i} = Borehole(borehole_location, obj.borehole_tilts(i), 0, obj.borehole_offset, obj.borehole_length, obj.buffer_radius, obj.borehole_radius, obj.outer_radius, obj.inner_radius);
            end
            
        end
        
        function createGeometry(obj, geometry)
            for i = 1:length(obj.borehole_array)
                obj.borehole_array{i}.createGeometry(geometry);
            end
        end
        
        function createSelections(obj, geometry)
            for i = 1:length(obj.borehole_array)
                obj.borehole_array{i}.createSelections(geometry);
            end
        end
        
    end
    
end
