classdef CoaxialPipe
    
    properties
        outerWallDiameter, innerWallDiameter
        thermalConductivity, specificHeatCapacity, density
        outerWallRadius, innerWallRadius
    end
    
    methods
        
        function obj = CoaxialPipe(outerWallDiameter, innerWallDiameter, thermalConductivity, specificHeatCapacity, density)
            
            if innerWallDiameter <= 1e-6
                error('Inner wall diameter must be positive.');
            end
            
            if outerWallDiameter <= 1e-6
                error('Outer wall diameter must be positive.');
            end
            
            if innerWallDiameter >= outerWallDiameter
                error('Outer wall diameter must be larger than inner wall diameter.');
            end
            
            if thermalConductivity <= 0
                error('Thermal conductivity must be positive.');
            end
            
            if specificHeatCapacity <= 0
                error('Specific heat capacity must be positive.');
            end
            
            if density <= 0
                error('Density must be positive.');
            end
            
            obj.outerWallDiameter = outerWallDiameter;
            obj.innerWallDiameter = innerWallDiameter;
            
            obj.outerWallRadius= 0.5 * outerWallDiameter;
            obj.innerWallRadius= 0.5 * innerWallDiameter;
            
            obj.thermalConductivity = thermalConductivity;
            obj.specificHeatCapacity = specificHeatCapacity;
            obj.density = density;
            
        end
        
    end
    
end
