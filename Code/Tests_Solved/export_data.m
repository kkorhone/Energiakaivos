files = dir('quarter_*_*_bhes_solved.mph');

for i = 1:length(files)
    export_total_heat_rates(files(i).name);
end
