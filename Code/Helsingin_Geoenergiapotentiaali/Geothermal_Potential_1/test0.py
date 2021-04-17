from pylab import *

T_surface = 6.762
q_geothermal = 40.666 * 1e-3

L_borehole = 300.0

megawatt_hours = 1.0e-6 / 3600.0

block_size = 20.0

rock_type = ["Amfiboliitti", "Gabro", "Graniitti", "Grano- ja kvartsidioriitti", "Kiillegneissi", "Kvartsi-maasalpagneissi"]

rho_rock = [2906.0, 2804.0, 2640.0, 2675.0, 2707.0, 2794.0]
Cp_rock = [731.0, 712.0, 721.0, 731.0, 725.0, 723.0]
k_rock = [2.66, 3.25, 3.20, 3.17, 2.87, 3.10]

V_rock = block_size**2 * L_borehole

for i in range(len(rock_type)):
    T_ground = [T_surface, T_surface+q_geothermal/k_rock[i]*L_borehole]
    delta_T = mean(T_ground)
    E_stored = rho_rock[i] * Cp_rock[i] * V_rock * delta_T * megawatt_hours
    print "%30s %.3f MWh/a" % (rock_type[i], E_stored/50.0)
