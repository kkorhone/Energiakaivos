classdef TensorParameter
    
    properties
        name, value, unit
    end
    
    methods
        
        function obj = TensorParameter(name, value, unit)
            obj.name = name;
            obj.value = value;
            obj.unit = unit;
        end
        
        function setParameter(obj, parameterGroup)
            
            parameterGroup.set(sprintf('%sxx', obj.name), sprintf('%f[%s]', obj.value(1, 1), obj.unit));
            parameterGroup.set(sprintf('%sxy', obj.name), sprintf('%f[%s]', obj.value(1, 2), obj.unit));
            parameterGroup.set(sprintf('%sxz', obj.name), sprintf('%f[%s]', obj.value(1, 3), obj.unit));
            
            parameterGroup.set(sprintf('%syx', obj.name), sprintf('%f[%s]', obj.value(2, 1), obj.unit));
            parameterGroup.set(sprintf('%syy', obj.name), sprintf('%f[%s]', obj.value(2, 2), obj.unit));
            parameterGroup.set(sprintf('%syz', obj.name), sprintf('%f[%s]', obj.value(2, 3), obj.unit));
            
            parameterGroup.set(sprintf('%szx', obj.name), sprintf('%f[%s]', obj.value(3, 1), obj.unit));
            parameterGroup.set(sprintf('%szy', obj.name), sprintf('%f[%s]', obj.value(3, 2), obj.unit));
            parameterGroup.set(sprintf('%szz', obj.name), sprintf('%f[%s]', obj.value(3, 3), obj.unit));
            
        end
        
    end
    
end
