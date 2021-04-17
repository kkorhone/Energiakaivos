com.comsol.model.util.ModelUtil.showProgress(true);

% t = 0:1/12:200;
% 
% model = mphload('axisymmetric_model_150m.mph');
% T1 = mphglobal(model, 'T_wall_ave-T_initial(-0.5*L_borehole)', 'unit', 'K', 't', t);
% 
% model = mphload('axisymmetric_model_300m.mph');
% T2 = mphglobal(model, 'T_wall_ave-T_initial(-0.5*L_borehole)', 'unit', 'K', 't', t);
% 
% model = mphload('axisymmetric_model_1000m.mph');
% T3 = mphglobal(model, 'T_wall_ave-T_initial(-0.5*L_borehole)', 'unit', 'K', 't', t);
% 
% save('T_wall_ave.mat','t','T1','T2','T3');

t = [0:1/12:200, 210:10:1000 1100:100:10000];

model = mphload('borefield_model_150m.mph');
T1 = mphglobal(model, 'T_wall_ave-T_initial(-0.5*L_borehole)', 'unit', 'K', 't', t);

model = mphload('borefield_model_300m.mph');
T2 = mphglobal(model, 'T_wall_ave-T_initial(-0.5*L_borehole)', 'unit', 'K', 't', t);

model = mphload('borefield_model_1000m.mph');
T3 = mphglobal(model, 'T_wall_ave-T_initial(-0.5*L_borehole)', 'unit', 'K', 't', t);

save('T_wall_ave2.mat','t','T1','T2','T3');
