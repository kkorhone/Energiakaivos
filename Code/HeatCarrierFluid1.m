classdef HeatCarrierFluid
    
    properties (Constant)
        DENSITY_COEFFICIENTS = [9.61924849e+02 -5.22151285e-01 -3.28069117e-03 1.56936508e-05 -1.43254244e+00 -1.98879633e-02 1.87036507e-04 -9.15384203e-07 -2.25978904e-02 2.28144880e-04 -8.58097116e-08 4.05619182e-09 -1.69017036e-04 8.59424821e-06 -9.60656690e-08 1.29070343e-05 -1.58966503e-07 -8.31754837e-08]
        SPECIFIC_HEAT_CAPACITY_COEFFICIENTS = [4.20132098e+03 2.62675858e+00 -2.57055716e-02 2.84132278e-04 -1.97679323e+01 4.32350412e-01 -3.93252353e-03 -7.44090972e-06 -4.22525681e-01 -1.20835008e-03 3.84242651e-05 -4.49608433e-07 1.56612096e-02 -2.13637444e-04 7.64794596e-07 -1.57413559e-06 3.19907361e-06 -7.96665378e-06]
        THERMAL_CONDUCTIVITY_COEFFICIENTS = [4.06729711e-01 6.77537741e-04 3.10521982e-07 -2.00010175e-08 -5.00795678e-03 -2.37692917e-05 -3.21588225e-08 8.36229442e-11 2.80105552e-05 2.66915870e-07 -3.60553984e-09 1.55248419e-11 -2.00858394e-08 -6.81345696e-09 1.42867359e-10 -1.50600023e-09 1.16714123e-10 -1.65296123e-11]
        MEAN_ETHANOL_CONCENTRATION = 29.23611111111111
        MEAN_FLUID_TEMPERATURE = 8.157777777777776
    end
    
    properties
        flowRate, density, specificHeatCapacity, thermalConductivity
    end
    
    methods
        
        function obj = HeatCarrierFluid(ethanolConcentration, fluidTemperature, flowRate)
            
            g = [];
            for i = 0:5
                for j = 0:3
                    if i+j > 5
                        continue;
                    else
                        g(end+1) = (ethanolConcentration - HeatCarrierFluid.MEAN_ETHANOL_CONCENTRATION)^i * (fluidTemperature - HeatCarrierFluid.MEAN_FLUID_TEMPERATURE)^j;
                    end
                end
            end
            
            obj.flowRate = ScalarParameter('Q_fluid', flowRate, 'm^3/s');
            
            obj.density = ScalarParameter('rho_fluid', dot(g, HeatCarrierFluid.DENSITY_COEFFICIENTS), 'kg/m^3');
            obj.specificHeatCapacity = ScalarParameter('Cp_fluid', dot(g, HeatCarrierFluid.SPECIFIC_HEAT_CAPACITY_COEFFICIENTS), 'J/(kg*K)');
            obj.thermalConductivity = ScalarParameter('k_fluid', dot(g, HeatCarrierFluid.THERMAL_CONDUCTIVITY_COEFFICIENTS), 'W/(m*K)');
            
        end
        
        function parameterGroup = createParameterGroup(obj, model)
            
            parameterGroupName = 'Heat Carrier Fluid';
            parameterGroupTag = replace(lower(parameterGroupName), ' ', '_');
            
            parameterGroup = model.param.group.create(parameterGroupTag);
            parameterGroup.label(parameterGroupName);
            
            obj.flowRate.setParameter(parameterGroup);
            obj.density.setParameter(parameterGroup);
            obj.specificHeatCapacity.setParameter(parameterGroup);
            obj.thermalConductivity.setParameter(parameterGroup);
            
        end
        
    end
    
end
