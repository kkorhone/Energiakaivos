function [year, flux_ratio, energy_ratio] = calc_ratios(model)

si = mphsolinfo(model);

t = si.solvals / (365.2425 * 86400);

Q_wall = mphglobal(model, 'Q_wall', 'unit', 'W');
Q_surf = mphglobal(model, 'Q_surface', 'unit', 'W');

year = 1:t(end);
flux_ratio = zeros(1, length(year));
energy_ratio = zeros(1, length(year));

for i = 1:length(year)
    j = find((year(i)-1<t)&(t<=year(i)));
    flux_ratio(i) = mean(Q_surf(j)./Q_wall(j));
    j = find(t<=year(i));
    energy_ratio(i) = trapz(t(j),Q_surf(j))/trapz(t(j),Q_wall(j));
end
