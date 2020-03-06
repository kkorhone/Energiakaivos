clc

clear all
close all

files = dir('*_*_bhes_solved.mph');

for i = 1:length(files)
    tokens = strsplit(files(i).name(1:end-4), '_');
    base_name = join(tokens(1:3), '_');
    base_name = base_name{1}
    model = mphload(files(i).name);
    si = mphsolinfo(model);
    t = si.solvals / (365.2425 * 24 * 3600);
    Q = mphglobal(model, 'Q_total', 'unit', 'MW');
    txt_name = sprintf('%s_total_heat_rate.txt', base_name);
    fid = fopen(txt_name, 'w');
    for j = 1:length(t)
        fprintf(fid, '%.20f %.20f\n', t(j), Q(j));
    end
    fclose(fid);
end
