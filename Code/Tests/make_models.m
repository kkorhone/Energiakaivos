files = dir('uv_*_bhes.txt');

for i = 1:length(files)
    base_name = files(i).name(1:end-4)
    model = init_quarter_cylinder_model(files(i).name);
    mphsave(model, sprintf('%s.mph', base_name));
end

files = dir('ico_*_bhes.txt');

for i = 1:length(files)
    base_name = files(i).name(1:end-4)
    model = init_quarter_cylinder_model(files(i).name);
    mphsave(model, sprintf('%s.mph', base_name));
end
