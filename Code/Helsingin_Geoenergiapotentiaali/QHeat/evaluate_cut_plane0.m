function [xi, yi, pi] = evaluate_cut_plane(model, expression, unit, z, dx, dy)

tags = cell(model.result.dataset.tags);

has_cut_plane = 0;

for i = 1:length(tags)
    if strcmp(char(tags(i)), 'cut_plane')
        has_cut_plane = 1;
    end
end

if ~has_cut_plane
    model.result.dataset.create('cut_plane', 'CutPlane');
end

model.result.dataset('cut_plane').set('quickplane', 'xy');
%model.result.dataset('cut_plane').set('quickz', '-0.5*L_borehole');
model.result.dataset('cut_plane').set('quickz', sprintf('%.3f[m]', z));

x = mphinterp(model, 'x', 'unit', 'm', 'dataset', 'cut_plane', 'solnum', 'end');
y = mphinterp(model, 'y', 'unit', 'm', 'dataset', 'cut_plane', 'solnum', 'end');
p = mphinterp(model, expression, 'unit', unit, 'dataset', 'cut_plane', 'solnum', 'end');

xi = floor(min(x)/dx)*dx:dx:ceil(max(x)/dx)*dx;
yi = floor(min(y)/dy)*dy:dy:ceil(max(y)/dy)*dy;

[xi, yi] = meshgrid(xi, yi);

pi = griddata(x, y, p, xi, yi);

xi = [xi, fliplr(-xi)];
xi = [xi; xi];

yi = [yi, yi];
yi = [flipud(-yi); yi];

pi = [pi, fliplr(pi)];
pi = [flipud(pi); pi];
