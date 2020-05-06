mph_names = {'ico_field_8_300m_solved_1Ma.mph', ...
             'ico_field_25_300m_solved_1Ma.mph', ...
             'ico_field_89_300m_solved_1Ma.mph', ...
             'ico_field_136_300m_solved_1Ma.mph', ...
             'ico_field_337_300m_solved_1Ma.mph'};

for i = 1:length(mph_names)
    disp(mph_names{i});
    model = mphload(mph_names{i});
    si = mphsolinfo(model);
    t = si.solvals/(365.2425*24*3600);
    Q_total = mphglobal(model, 'Q_total', 'unit', 'W');
    Q_above = mphglobal(model, 'Q_above', 'unit', 'W');
    Q_below = mphglobal(model, 'Q_below', 'unit', 'W');
    T_field = mphglobal(model, 'T_field', 'unit', 'degC');
    T_outlet = mphglobal(model, 'T_outlet', 'unit', 'degC');
    tokens = strsplit(mph_names{i}, '_');
    txt_name = sprintf('%s_%s_%s_%s_results.txt', tokens{1}, tokens{2}, tokens{3}, tokens{4});
    disp(txt_name);
    fid = fopen(txt_name, 'w');
    for j = 1:length(t)
        fprintf(fid, '%f %f %f %f %f %f\n', t(j), Q_total(j), Q_above(j), Q_below(j), T_field(j), T_outlet(j));
    end
    fclose(fid);
end
