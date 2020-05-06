files = dir('ico_*_300m_solved.mph');

% if exist('results.xlsx', 'file')
%     delete('results.xlsx');
% end

V_field = [];

for i = 1:length(files)
    
    files(i).name
    
    model = mphload(files(i).name);
    
%     solinfo = mphsolinfo(model);
%     
%     t = solinfo.solvals / (365.2425 * 24 * 3600);
%     
%     Q_total = mphglobal(model, 'Q_total', 'unit', 'W');
%     Q_above = mphglobal(model, 'Q_above', 'unit', 'W');
%     Q_below = mphglobal(model, 'Q_below', 'unit', 'W');
%     
%     T_field = mphglobal(model, 'T_field', 'unit', 'degC');
%     T_outlet = mphglobal(model, 'T_outlet', 'unit', 'degC');
%     
%     T = table(t, Q_total, Q_above, Q_below, T_field, T_outlet);
%     writetable(T, 'results.xlsx', 'sheet', files(i).name);

    model.component('component').cpl.create('intop1', 'Integration');
    model.component('component').cpl('intop1').selection.named('geometry_ball_selection');
    model.component('component').variable('component_variables').set('V_field', '4*intop1(1)');

    model.sol('sol1').updateSolution();
    
    V_field(i) = mphglobal(model, 'V_field', 'solnum', 'end');

    fprintf(1, '%f\n', V_field(i));
    
end
