function [xi, yi, pi] = evaluate_cut_plane(model, expr, unit, x, y, z, time)

fprintf(1, 'Searching for dataset ''cut_plane''... ');

tags = cell(model.result.dataset.tags);

has_cut_plane = 0;

for i = 1:length(tags)
    if strcmp(char(tags(i)), 'cut_plane')
        has_cut_plane = 1;
    end
end

if has_cut_plane
    fprintf(1, 'Found.\n');
elseif ~has_cut_plane
    fprintf(1, 'Did not find.\n');
    fprintf(1, 'Creating dataset ''cut_plane''... ');
    model.result.dataset.create('cut_plane', 'CutPlane');
    fprintf(1, 'Done.\n');
end

fprintf(1, 'Setting up dataset ''cut_plane'' for interpolation at depth of %.0f m... ', z);

model.result.dataset('cut_plane').set('quickplane', 'xy');
%model.result.dataset('cut_plane').set('quickz', '-0.5*L_borehole');
model.result.dataset('cut_plane').set('quickz', sprintf('%.3f[m]', z));

fprintf(1, 'Done.\n');

%si = mphsolinfo(model);

%t = si.solvals / (365.2425 * 24 * 3600);

fprintf(1, 'Interpolating ''%s'' in units of ''%s'' at %.3f a... ', expr, unit, time);

[xi, yi] = meshgrid(x, y);

[n, m] = size(xi);

xi = reshape(xi, 1, n*m);
yi = reshape(yi, 1, n*m);
zi = z * ones(1, n*m);

%x = mphinterp(model, 'x', 'unit', 'm', 'dataset', 'cut_plane', 'solnum', solnum);
%y = mphinterp(model, 'y', 'unit', 'm', 'dataset', 'cut_plane', 'solnum', solnum);
%p = mphinterp(model, expr, 'unit', unit, 'dataset', 'cut_plane', 'solnum', solnum);

coord = [xi; yi; zi];

%x = mphinterp(model, 'x', 'unit', 'm', 'dataset', 'cut_plane', 'coord', coord, 't', time);
%y = mphinterp(model, 'y', 'unit', 'm', 'dataset', 'cut_plane', 'coord', coord, 't', time);
pi = mphinterp(model, expr, 'unit', unit, 'dataset', 'cut_plane', 'coord', coord, 't', time);

fprintf(1, 'Done.\n');
fprintf(1, 'Generating field of ''%s'' in units of ''%s''... ', expr, unit);

xi = reshape(xi, n, m);
yi = reshape(yi, n, m);
pi = reshape(pi, n, m);

xi = [xi, fliplr(-xi)];
xi = [xi; xi];

yi = [yi, yi];
yi = [flipud(-yi); yi];

pi = [pi, fliplr(pi)];
pi = [flipud(pi); pi];

fprintf(1, 'Done.\n');
