classdef CoaxialPipe
    
    properties
        outerWallDiameter, innerWallDiameter
        thermalConductivity, specificHeatCapacity, density
        outerWallRadius, innerWallRadius
    end
    
    methods
        
        function obj = CoaxialPipe(outerWallDiameter, innerWallDiameter, thermalConductivity, specificHeatCapacity, density)
            
            obj.outerWallDiameter = ScalarParameter('d_outer', outerWallDiameter, 'm');
            obj.innerWallDiameter = ScalarParameter('d_inner', innerWallDiameter, 'm');
            
            obj.outerWallRadius= ScalarParameter('r_outer', 0.5*outerWallDiameter, 'm');
            obj.innerWallRadius= ScalarParameter('r_inner', 0.5*innerWallDiameter, 'm');
            
            obj.thermalConductivity = ScalarParameter('k_pipe', thermalConductivity, 'W/(m*K)');
            obj.specificHeatCapacity = ScalarParameter('Cp_pipe', specificHeatCapacity, 'J/(kg*K)');
            obj.density = ScalarParameter('rho_pipe', density, 'kg/m^3');
            
        end
        
        function parameterGroup = createParameterGroup(obj, model)
            
            parameterGroupName = 'Coaxial Pipe';
            parameterGroupTag = replace(lower(parameterGroupName), ' ', '_');
            
            parameterGroup = model.param.group.create(parameterGroupTag);
            parameterGroup.label(parameterGroupName);
            
            obj.outerWallDiameter.setParameter(parameterGroup);
            obj.innerWallDiameter.setParameter(parameterGroup);
            
            obj.outerWallRadius.setParameter(parameterGroup);
            obj.innerWallRadius.setParameter(parameterGroup);
            
            obj.thermalConductivity.setParameter(parameterGroup);
            obj.specificHeatCapacity.setParameter(parameterGroup);
            obj.density.setParameter(parameterGroup);

        end
        
    end
    
end
