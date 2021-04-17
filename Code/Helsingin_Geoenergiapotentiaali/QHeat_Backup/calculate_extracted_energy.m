function [xi, yi, Xi, Yi] = calculate_extracted_energy(model)

si = mphsolinfo(model);

t_sol = si.solvals / (365.2425 * 24 * 60 * 60); % Years
h_sol = t_sol * (365.2425 * 24); % Hours
Q_sol = mphglobal(model, 'borehole_wall_heat_rate', 'unit', 'W'); % Watts

ti = linspace(0, 1000, 12*1000+1); % Years
hi = ti * (365.2425 * 24); % Hours
Qi = interp1(t_sol, Q_sol, ti); % Watts

%semilogx(t_sol, Q_sol, 'ro', ti, Qi, 'b-'); legend('Q_{wall}', 'Q_i')

% xi = time in years
% yi = annual geothermal energy in MWh

xi = [];
yi = [];

for year = 1:999
    k = find((year <= ti) & (ti <= year+1));
    %fprintf(1, 'N=%d t1=%.3f t2=%.3f t2-t1=%.3f\n', length(k), ti(k(1)), ti(k(end)), ti(k(end))-ti(k(1)));
    Ei = trapz(hi(k), Qi(k)) * 1e-6;
    xi = [xi, mean(ti(k))];
    yi = [yi, Ei];
end

Xi = t_sol;
Yi = cumtrapz(h_sol, Q_sol) * 1e-6;

% Xi = time in years
% Yi = cumulative geothermal energy in MWh
