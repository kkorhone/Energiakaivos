classdef HemisphericalBoreholeField
    
    properties
        inletTemperature
        bheArray, xLimits, yLimits
    end
    
    methods
        
        function obj = HemisphericalBoreholeField(inletTemperature)
            
            obj.bheArray = {};
            
        end
        
        function addBoreholeHeatExchanger(bhe)
            obj.bheArray{end+1} = bhe;
        end
        
    end
    
    methods (Static)
        
        function boreholeField = readFromFile(fileName, inletTemperature)
            
            boreholeField = HemisphericalBoreholeField(inletTemperature);

            boreholeFieldConfiguration = load(fileName);

            bheCollars = boreholeFieldConfiguration(:, 1:3);
            bheFooters = boreholeFieldConfiguration(:, 4:6);
            bheFactors = boreholeFieldConfiguration(:, 7);

            x_max = max(max(bhe_collars(:,1)), max(bhe_footers(:,1)));
            y_max = max(max(bhe_collars(:,2)), max(bhe_footers(:,2)));

            z_min = min(min(bhe_collars(:,3)), min(bhe_footers(:,3)));
            z_max = max(max(bhe_collars(:,3)), max(bhe_footers(:,3)));
        end
        
    end
    
end
