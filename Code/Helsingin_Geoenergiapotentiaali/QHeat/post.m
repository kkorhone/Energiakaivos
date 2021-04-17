x = -200:0;
y = 0:200;

num_cols = length(x);
num_rows = length(y);

[x, y] = meshgrid(x, y);

z = -1000 * ones(size(x));

x = reshape(x, 1, num_rows*num_cols);
y = reshape(y, 1, num_rows*num_cols);
z = reshape(z, 1, num_rows*num_cols);

si = mphsolinfo(model);
t = si.solvals;
year = si.solvals / (365.2425 * 24 * 3600);

solnum = 90;

fprintf(1, 'solnum=%d year=%.3f\n', solnum, year(solnum));

T = mphinterp(model, 'T-T_initial(z)', 'unit', 'K', 'coord', [x; y; z], 'solnum', solnum);

% NW
% -200   0
%    *---* 200
%    |   |
%    *---* 0

x_nw = reshape(x, num_rows, num_cols);
y_nw = flipud(reshape(y, num_rows, num_cols));
T_nw = flipud(reshape(T, num_rows, num_cols));

% NE
% 0   200
% *---* 200
% |   |
% *---* 0

x_ne = -fliplr(x_nw); % 
y_ne = y_nw;
T_ne = fliplr(T_nw);

%surf([x_nw, x_ne], [y_nw, y_ne], [T_nw, T_ne]); shading interp

% SE
% *---* 0
% |   |
% *---* -200
% 0   200

x_se = flipud(x_ne);
y_se = -flipud(y_ne);
T_se = flipud(T_ne);

% SW
%    *---* 0
%    |   |
%    *---* -200
% -200   0

x_sw = fliplr(flipud(x_nw));
y_sw = fliplr(-flipud(y_nw));
T_sw = fliplr(flipud(T_nw));

x_n = [x_nw, x_ne];
y_n = [y_nw, y_ne];
T_n = [T_nw, T_ne];

x_s = x_n;
y_s = -flipud(y_n);
T_s = flipud(T_n);

x = [x_n; x_s];
y = [y_n; y_s];
T = [T_n; T_s];

surf(x, y, T)
shading interp
