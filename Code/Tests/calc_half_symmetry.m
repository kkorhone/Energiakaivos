function [sx, sy, sz, ex, ey, ez, fac] = calc_half_symmetry(sx, sy, sz, ex, ey, ez)

% =========================================================================
% Centers the BHEs.
% =========================================================================

x_min = min(sx);
x_max = max(sx);

y_min = min(sy);
y_max = max(sy);

delta_x = 0.5 * (x_min + x_max);
delta_y = 0.5 * (y_min + y_max);

sx = sx - delta_x;
sy = sy - delta_y;

ex = ex - delta_x;
ey = ey - delta_y;

% =========================================================================
% Plots the BHEs.
% =========================================================================

figure
hold on
for i = 1:length(sx)
    plot3([sx(i) ex(i)], [sy(i) ey(i)], [sz(i) ez(i)], 'b-')
    plot3(sx(i), sy(i), sz(i), 'b.', 'markersize', 20)
    plot3(ex(i), ey(i), ez(i), 'b.', 'markersize', 25)
end

% =========================================================================
% Test symmetry against y axis.
% =========================================================================

sym = [];
fac = [];

for i = 1:size(sx, 1)
    if abs(sx(i)) < 1e-6
        % BHE is located on the x axis.
        sym(end+1) = i;
        fac(end+1) = 1;
    elseif sx(i) >= 0
        % BHE is located on the half space x > 0.
        sym(end+1) = i;
        fac(end+1) = 2;
    end
end

% Reflected BHEs.
rsx = []; rsy = []; rsz = [];
rex = []; rey = []; rez = [];

% Reflection plane.
n = [1 0 0];

for i = sym
    % Reflects the current BHE.
    s = [sx(i) sy(i) sz(i)];
    e = [ex(i) ey(i) ez(i)];
    rs = s - 2 * dot(s, n) * n;
    re = e - 2 * dot(e, n) * n;
    % Saves the reflected BHE starting point.
    rsx(end+1) = rs(1);
    rsy(end+1) = rs(2);
    rsz(end+1) = rs(3);
    % Saves the reflected BHE ending point.
    rex(end+1) = re(1);
    rey(end+1) = re(2);
    rez(end+1) = re(3);
    % Plots the reflected BHE.
    plot3([rs(1) re(1)], [rs(2) re(2)], [rs(3) re(3)], 'g-')
    plot3(rs(1), rs(2), rs(3), 'g.', 'markersize', 20)
    plot3(re(1), re(2), re(3), 'g.', 'markersize', 25)
    % Plots the original BHE.
    plot3([sx(i) ex(i)], [sy(i) ey(i)], [sz(i), ez(i)], 'r-')
    plot3(sx(i), sy(i), sz(i), 'r.', 'markersize', 20)
    plot3(ex(i), ey(i), ez(i), 'r.', 'markersize', 25)
    % Checks if the reflected BHE is found in the original list of BHEs.
    j = find((abs(rs(1)-sx)<1e-6)&(abs(rs(2)-sy)<1e-6)&(abs(rs(3)-sz)<1e-6)&(abs(re(1)-ex)<1e-6)&(abs(re(2)-ey)<1e-6)&(abs(re(3)-ez)<1e-6));
    if length(j) ~= 1
        fac = [];
    end
end
hold off

if sum(fac) ~= length(sx)
    fac = [];
end

if isempty(sym)
    title('No symmetry')
else
    title(sprintf('Symmetry (%d of %d BHEs)', length(sym), length(sx)))
end

if ~isempty(sym)
    sx = sx(sym);
    sy = sy(sym);
    sz = sz(sym);
    ex = ex(sym);
    ey = ey(sym);
    ez = ez(sym);
end
