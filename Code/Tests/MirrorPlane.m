classdef MirrorPlane
    
    properties (Constant)
        Negative_XZ_Plane = MirrorPlane([+1 0], [0 -1]) % The negative side of the XZ plane is mirrored.
        Positive_XZ_Plane = MirrorPlane([+1 0], [0 +1]) % The positive side of the XZ plane is mirrored.
        Negative_YZ_Plane = MirrorPlane([0 +1], [+1 0]) % The negative side of the YZ plane is mirrored.
        Positive_YZ_Plane = MirrorPlane([0 +1], [-1 0]) % The positive side of the YZ plane is mirrored.
    end
    
    properties
        u, v
    end
    
    methods
        
        function obj = MirrorPlane(varargin)
            
            if nargin == 1
                
                azimuth = varargin{1};
                alpha = azimuth * pi / 180;
                
                R = [[cos(alpha) -sin(alpha)]; [sin(alpha) cos(alpha)]];
                
                u = [+1 0];
                v = [0 -1];
                
                obj.u = transpose(R * transpose(u));
                obj.v = transpose(R * transpose(v));
                
            elseif nargin == 2
                
                u = varargin{1};
                v = varargin{2};
                
                obj.u = u / sqrt(dot(u, u));
                obj.v = v / sqrt(dot(v, v));
                
            end
            
            assert(abs(dot(obj.u, obj.v)) < 1e-9);
            
        end
        
        function polygon_tag = createCutStructure(obj, work_plane, radius)
            
            p1 = radius * obj.u;
            p2 = radius * (obj.u + obj.v);
            p3 = radius * (-obj.u + obj.v);
            p4 = radius * -obj.u;
            
            polygon_tag = char(work_plane.geom.feature().uniquetag('polygon'));
            polygon = work_plane.geom.create(polygon_tag, 'Polygon');
            
            polygon.set('source', 'table');
            polygon.set('table', to_cell_array([p1(1) p1(2); p2(1) p2(2); p3(1) p3(2); p4(1) p4(2)]));
            
        end
        
    end
    
end
