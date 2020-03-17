classdef HeatCarrierFluid
    
    properties (Constant)
        FREEZING_POINT_COEFFCIENTS = [-1.94103659e+01 -3.66754096e-04 -4.00464920e-05 1.52423209e-06 -9.54035821e-01 -1.20902976e-05 2.87684144e-06 -4.39363659e-08 -2.64757704e-03 -3.17274135e-07 8.65209109e-09 -3.71745259e-10 3.85076505e-04 1.34003263e-08 -2.09095140e-09 -2.85752110e-07 9.31244062e-10 -1.67020224e-07]
        DENSITY_COEFFICIENTS = [9.61924849e+02 -5.22151285e-01 -3.28069117e-03 1.56936508e-05 -1.43254244e+00 -1.98879633e-02 1.87036507e-04 -9.15384203e-07 -2.25978904e-02 2.28144880e-04 -8.58097116e-08 4.05619182e-09 -1.69017036e-04 8.59424821e-06 -9.60656690e-08 1.29070343e-05 -1.58966503e-07 -8.31754837e-08]
        SPECIFIC_HEAT_CAPACITY_COEFFICIENTS = [4.20132098e+03 2.62675858e+00 -2.57055716e-02 2.84132278e-04 -1.97679323e+01 4.32350412e-01 -3.93252353e-03 -7.44090972e-06 -4.22525681e-01 -1.20835008e-03 3.84242651e-05 -4.49608433e-07 1.56612096e-02 -2.13637444e-04 7.64794596e-07 -1.57413559e-06 3.19907361e-06 -7.96665378e-06]
        THERMAL_CONDUCTIVITY_COEFFICIENTS = [4.06729711e-01 6.77537741e-04 3.10521982e-07 -2.00010175e-08 -5.00795678e-03 -2.37692917e-05 -3.21588225e-08 8.36229442e-11 2.80105552e-05 2.66915870e-07 -3.60553984e-09 1.55248419e-11 -2.00858394e-08 -6.81345696e-09 1.42867359e-10 -1.50600023e-09 1.16714123e-10 -1.65296123e-11]
        DYNAMIC_VISCOSITY_COEFFOCIENTS = [1.47439832e+00 -4.74457689e-02 4.31422587e-04 -3.02278830e-06 1.56522183e-02 -4.10634142e-05 -5.13476074e-06 7.00405865e-08 -8.43523165e-04 1.64018694e-05 -1.09093764e-07 -1.96722915e-09 7.55226351e-06 -1.11756101e-07 1.89892686e-09 1.52855850e-07 -9.48109784e-10 -4.12963938e-09]
        MEAN_ETHANOL_CONCENTRATION = 29.23611111111111
        MEAN_FLUID_TEMPERATURE = 8.157777777777776
        DATA_POLYGON_ETHANOL_CONCENTRATION = [0, 0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 60, 0];
        DATA_POLYGON_FLUID_TEMPERATURE = [40, 0, -2.09, -4.47, -7.36, -10.9, -15.45, -20.47, -29.3, -37.7, -44.9, 40, 40];
    end
    
    properties
        ethanolConcentration, fluidTemperature
        freezingPoint, density, specificHeatCapacity, thermalConductivity, dynamicViscosity
    end
    
    methods
        
        function obj = HeatCarrierFluid(ethanolConcentration, fluidTemperature)
            
            if ~inpolygon(ethanolConcentration, fluidTemperature, HeatCarrierFluid.DATA_POLYGON_ETHANOL_CONCENTRATION, HeatCarrierFluid.DATA_POLYGON_FLUID_TEMPERATURE)
                error('Invalid ethanol concentration and fluid temperature.');
            end
            
            obj.ethanolConcentration = ethanolConcentration;
            obj.fluidTemperature = fluidTemperature;
            
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
            
            obj.freezingPoint = dot(g, HeatCarrierFluid.FREEZING_POINT_COEFFCIENTS);
            obj.density = dot(g, HeatCarrierFluid.DENSITY_COEFFICIENTS);
            obj.specificHeatCapacity = dot(g, HeatCarrierFluid.SPECIFIC_HEAT_CAPACITY_COEFFICIENTS);
            obj.thermalConductivity = dot(g, HeatCarrierFluid.THERMAL_CONDUCTIVITY_COEFFICIENTS);
            obj.dynamicViscosity = exp(dot(g, HeatCarrierFluid.DYNAMIC_VISCOSITY_COEFFOCIENTS));
            
            fprintf(1, 'HeatCarrierFluid(k=%.3f Cp=%.1f rho=%.1f)\n', obj.thermalConductivity, obj.specificHeatCapacity, obj.density);
            
        end
        
    end
    
end
