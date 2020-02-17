ico=load('quarter_ico_25_bhes_total_heat_rate.txt');
uv=load('quarter_uv_25_bhes_total_heat_rate.txt');
t1=ico(:,1);Q1=ico(:,2);
t2=uv(:,1);Q2=uv(:,2);
plot(t1, Q1, t2, Q2)
E1=trapz(t1*365.2425*24,Q1/1000);
E2=trapz(t2*365.2425*24,Q2/1000);
