classdef VectorParameter
    
    properties
        name, value, unit
    end
    
    methods
        
        function obj = VectorParameter(name, value, unit)
            obj.name = name;
            obj.value = value;
            obj.unit = unit;
        end
        
        function setParameter(obj, parameterGroup)
            
            parameterGroup.set(sprintf('%sx', obj.name), sprintf('%f[%s]', obj.value(1), obj.unit));
            parameterGroup.set(sprintf('%sy', obj.name), sprintf('%f[%s]', obj.value(2), obj.unit));
            parameterGroup.set(sprintf('%sz', obj.name), sprintf('%f[%s]', obj.value(3), obj.unit));
            
        end
        
    end
    
end
