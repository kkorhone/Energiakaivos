classdef CoaxialPipe
    
    properties
        outerWallDiameter, innerWallDiameter
        thermalConductivity, specificHeatCapacity, density
        outerWallRadius, innerWallRadius
    end
    
    methods
        
        function obj = CoaxialPipe(outerWallDiameter, innerWallDiameter, thermalConductivity, specificHeatCapacity, density)
            
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
