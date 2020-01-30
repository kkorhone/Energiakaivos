classdef ScalarParameter
    
    properties
        name, value, unit
    end
    
    methods
        
        function obj = ScalarParameter(name, value, unit)
            obj.name = name;
            obj.value = value;
            obj.unit = unit;
        end
        
        function setParameter(obj, parameterGroup)
            
            parameterGroup.set(obj.name, sprintf('%f[%s]', obj.value, obj.unit));
            
        end
        
    end
    
end
