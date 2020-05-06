base_names = {'ico_field_136_300m_solved_1Ma', ...
              'ico_field_136_400m_solved_1Ma', ...
              'ico_field_136_500m_solved_1Ma', ...
              'ico_field_136_600m_solved_1Ma'};

for i = 1:length(base_names)
    mph_name = sprintf('%s_1MW.mph', base_names{i});
    disp(mph_name);
    model = mphload(mph_name);
    si = mphsolinfo(model);
    t = si.solvals/(365.2425*24*3600);
    Q_total = mphglobal(model, 'Q_total', 'unit', 'W');
    Q_above = mphglobal(model, 'Q_above', 'unit', 'W');
    Q_below = mphglobal(model, 'Q_below', 'unit', 'W');
    T_field = mphglobal(model, 'T_field', 'unit', 'degC');
    T_outlet = mphglobal(model, 'T_outlet', 'unit', 'degC');
    txt_name = sprintf('%s_results.txt', base_names{i});
    disp(txt_name);
    fid = fopen(txt_name, 'w');
    for j = 1:length(t)
        fprintf(fid, '%f %f %f %f %f %f\n', t(j), Q_total(j), Q_above(j), Q_below(j), T_field(j), T_outlet(j));
    end
    fclose(fid);
    % --------------------------------
%     mph_name = sprintf('%s_2MW.mph', base_names{i});
%     model = mphload(mph_name);
%     si = mphsolinfo(model);
%     t = si.solvals/(365.2425*24*3600);
%     Q_total = mphglobal(model, 'Q_total', 'unit', 'W');
%     Q_above = mphglobal(model, 'Q_above', 'unit', 'W');
%     Q_below = mphglobal(model, 'Q_below', 'unit', 'W');
%     T_field = mphglobal(model, 'T_field', 'unit', 'degC');
%     T_outlet = mphglobal(model, 'T_outlet', 'unit', 'degC');
%     txt_name = sprintf('%s_results.txt', base_names{i});
%     fid = fopen(txt_name, 'w');
%     for j = 1:length(t)
%         fprintf(fid, '%f %f %f %f %f %f\n', t(j), Q_total(j), Q_above(j), Q_below(j), T_field(j), T_outlet(j));
%     end
%     fclose(fid);
end
