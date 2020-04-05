% model1 = mphload('stress_300m_solved.mph');
% solin1 = mphsolinfo(model1);
% t1 = solin1.solvals / (365.2425 * 24 * 3600);
% Q_total1 = mphglobal(model1, 'Q_total', 'unit', 'W');
% Q_above1 = mphglobal(model1, 'Q_above', 'unit', 'W');
% Q_below1 = mphglobal(model1, 'Q_below', 'unit', 'W');
% T_field1 = mphglobal(model1, 'T_field', 'unit', 'degC');
% 
% model2 = mphload('stress_400m_solved.mph');
% solin2 = mphsolinfo(model2);
% t2 = solin2.solvals / (365.2425 * 24 * 3600);
% Q_total2 = mphglobal(model2, 'Q_total', 'unit', 'W');
% Q_above2 = mphglobal(model2, 'Q_above', 'unit', 'W');
% Q_below2 = mphglobal(model2, 'Q_below', 'unit', 'W');
% T_field2 = mphglobal(model2, 'T_field', 'unit', 'degC');
% 
% model3 = mphload('stress_500m_solved.mph');
% solin3 = mphsolinfo(model3);
% t3 = solin3.solvals / (365.2425 * 24 * 3600);
% Q_total3 = mphglobal(model3, 'Q_total', 'unit', 'W');
% Q_above3 = mphglobal(model3, 'Q_above', 'unit', 'W');
% Q_below3 = mphglobal(model3, 'Q_below', 'unit', 'W');
% T_field3 = mphglobal(model3, 'T_field', 'unit', 'degC');
% 
% model4 = mphload('stress_600m_solved.mph');
% solin4 = mphsolinfo(model4);
% t4 = solin4.solvals / (365.2425 * 24 * 3600);
% Q_total4 = mphglobal(model4, 'Q_total', 'unit', 'W');
% Q_above4 = mphglobal(model4, 'Q_above', 'unit', 'W');
% Q_below4 = mphglobal(model4, 'Q_below', 'unit', 'W');
% T_field4 = mphglobal(model4, 'T_field', 'unit', 'degC');
% 
% save('stress.mat',...
%     't1','Q_total1','Q_above1','Q_below1','T_field1',...
%     't2','Q_total2','Q_above2','Q_below2','T_field2',...
%     't3','Q_total3','Q_above3','Q_below3','T_field3',...
%     't4','Q_total4','Q_above4','Q_below4','T_field4');

clc

clear all
close all

load('stress.mat')

s1 = 2.78;
s2 = 12.59;
s3 = 45.45;
s4 = 100;

E1 = trapz(t1*365.2425*24, Q_total1*1e-9);
E2 = trapz(t2*365.2425*24, Q_total2*1e-9);
E3 = trapz(t3*365.2425*24, Q_total3*1e-9);
E4 = trapz(t4*365.2425*24, Q_total4*1e-9);

close all

figure
plot(t1,Q_total1*1e-6,'linewidth',2)
hold on
plot(t2,Q_total2*1e-6,'linewidth',2)
plot(t3,Q_total3*1e-6,'linewidth',2)
plot(t4,Q_total4*1e-6,'linewidth',2)
hold off
xlabel('Time [a]')
ylabel('Heat rate [MW]')
legend('300m 2.8a 0.8TWh','400m 12.6a 1.3TWh','500m 45.5a 1.6TWh','600m 100a 1.8TWh')
grid

close all
figure
plot(t1,T_field1,'linewidth',2)
hold on
plot(t2,T_field2,'linewidth',2)
plot(t3,T_field3,'linewidth',2)
plot(t4,T_field4,'linewidth',2)
hold off
set(gca,'ytick',11:25,'ylim',[11,25])
xlabel('Time [a]')
ylabel('Average temperature in borehole field [MW]')
legend('300m','400m','500m','600m')
grid

close all
figure
plot(t1,Q_total1,t1,Q_below1+Q_above1)
hold on
plot(t2,Q_total2,t2,Q_below2+Q_above2)
plot(t3,Q_total3,t3,Q_below3+Q_above3)
plot(t4,Q_total4,t4,Q_below4+Q_above4)
hold off

T1 = table(t1,Q_total1,Q_above1,Q_below1,T_field1);
T2 = table(t2,Q_total2,Q_above2,Q_below2,T_field2);
T3 = table(t3,Q_total3,Q_above3,Q_below3,T_field3);
T4 = table(t4,Q_total4,Q_above4,Q_below4,T_field4);
writetable(T1,'test.xlsx','sheet','300m')
writetable(T2,'test.xlsx','sheet','400m')
writetable(T3,'test.xlsx','sheet','500m')
writetable(T4,'test.xlsx','sheet','600m')

E1 = trapz(t1*365.2425*24, Q_total1*1e-9)
E2 = trapz(t2*365.2425*24, Q_total2*1e-9)
E3 = trapz(t3*365.2425*24, Q_total3*1e-9)
E4 = trapz(t4*365.2425*24, Q_total4*1e-9)

% load test.txt; t=test(:,1); Q=test(:,2); trapz(t*365.2425*24,Q*1e-9)
