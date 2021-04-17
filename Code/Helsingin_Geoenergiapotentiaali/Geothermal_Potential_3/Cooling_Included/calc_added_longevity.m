clc

cooling_fraction = [0.5];

num_years1 = 200;
num_years2 = 125;
num_years3 = 125;

com.comsol.model.util.ModelUtil.showProgress(true);

for k = 1:length(cooling_fraction)
    
    fprintf(1, 'cooling_fraction = %.1f\n', cooling_fraction(k));
    
    % -------------------------------------------------------------------------
    % 150-m boreholes
    % -------------------------------------------------------------------------
    
    model = init_150m_model(20,cooling_fraction(k),sprintf('range(0,1/36,%d)', num_years1));
    model.param.set('annual_heating_demand', sprintf('%.30f[MW*h]', 4.883));
    model.sol('sol1').runAll();
    T_wall_min = mphglobal(model, 'T_wall_min', 'unit', 'degC');
    si = mphsolinfo(model);
    t = si.solvals/(365.2425*86400);
    for year = 0:num_years1-1
        i = find((t >= year) & (t < year+1));
        if min(T_wall_min(i)) < 0
            break
        end
    end
    fprintf(1, '150m: %d (%d)\n', year, year-50);
    
    % -------------------------------------------------------------------------
    % 300-m boreholes
    % -------------------------------------------------------------------------
    
%     model = init_300m_model(20,cooling_fraction(k),sprintf('range(0,1/36,%d)', num_years2));
%     model.param.set('annual_heating_demand', sprintf('%.30f[MW*h]', 9.125));
%     model.sol('sol1').runAll();
%     T_wall_min = mphglobal(model, 'T_wall_min', 'unit', 'degC');
%     si = mphsolinfo(model);
%     t = si.solvals/(365.2425*86400);
%     for year = 0:num_years2-1
%         i = find((t >= year) & (t < year+1));
%         if min(T_wall_min(i)) < 0
%             break
%         end
%     end
%     fprintf(1, '300m: %d (%d)\n', year, year-50);
    
    % -------------------------------------------------------------------------
    % 1000-m boreholes
    % -------------------------------------------------------------------------
    
%     model = init_1000m_model(20,cooling_fraction(k),sprintf('range(0,1/36,%d)', num_years3));
%     model.param.set('annual_heating_demand', sprintf('%.30f[MW*h]', 30.482));
%     model.sol('sol1').runAll();
%     T_wall_min = mphglobal(model, 'T_wall_min', 'unit', 'degC');
%     si = mphsolinfo(model);
%     t = si.solvals/(365.2425*86400);
%     for year = 0:num_years3-1
%         i = find((t >= year) & (t < year+1));
%         if min(T_wall_min(i)) < 0
%             break
%         end
%     end
%     fprintf(1, '1000m: %d (%d)\n', year, year-50);
    
end
