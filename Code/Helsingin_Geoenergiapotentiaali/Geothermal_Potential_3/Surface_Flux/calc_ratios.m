function [year, flux_ratio, energy_ratio] = calc_ratios(model)

solinfo = mphsolinfo(model);

time = solinfo.solvals / (365.2425 * 86400);

Q_wall = mphglobal(model, 'Q_wall', 'unit', 'W');
Q_surface = mphglobal(model, 'Q_surface', 'unit', 'W');

year = 1:time(end);

flux_ratio = zeros(1, length(year));
energy_ratio = zeros(1, length(year));

for i = 1:length(year)
    
    j = find((year(i) - 1 < time) & (time <= year(i)));
    
    flux_ratio(i) = mean(Q_surface(j)) / mean(Q_wall(j));
    
    j = find(time <= year(i));
    
    energy_ratio(i) = trapz(time(j), Q_surface(j)) / trapz(time(j), Q_wall(j));
    
end
