clc

clear all
close all

rock_type = {'Amfiboliitti', 'Gabro', 'Graniitti', 'Grano- ja kvartsidioriitti', 'Kiillegneissi', 'Kvartsi-maasälpägneissi'};

rho_rock = [2906.0, 2804.0, 2640.0, 2675.0, 2707.0, 2794.0];
Cp_rock = [731.0, 712.0, 721.0, 731.0, 725.0, 723.0];
k_rock = [2.66, 3.25, 3.20, 3.17, 2.87, 3.10];

borehole_spacing = 10:10:200;

T_surface = 6.762;
q_geothermal = 40.666;

for i = 1:length(rock_type)

    fprintf(1, 'rock_type = %s\n', rock_type{i});
    
    [E_single, E_field] = eval_energies(T_surface, q_geothermal, k_rock(i), Cp_rock(i), rho_rock(i), 150.0, borehole_spacing, 30.0);
    
    file_name = sprintf('comsol_results_150_%d.txt', i);
    
    file_id = fopen(file_name, 'w');
    
    fprintf(file_id, 'nan %.3f\n', E_single);
    
    for j = 1:length(borehole_spacing)
        fprintf(file_id, '%.3f %.3f\n', borehole_spacing(j), E_field(j));
    end
    
    fclose(file_id);
end
