clc

clear all
close all

%E_max = [30, 50, 250];
E_max = [250, 50, 30];

%borehole_length = [150.0, 300.0, 1000.0];
borehole_length = [1000.0, 300.0, 150.0];

%borehole_spacing = [10, 20, 30, 40, 50, 60, 80, 100, 120, 140, 160, 180, 200];
borehole_spacing = [220, 240, 260, 280, 300];

for i = 1:length(borehole_length)
    
    tic

    E = eval_energies(borehole_length(i), borehole_spacing, E_max(i));
    
    file_name = sprintf('comsol_average_model_%.0fm_2.txt', borehole_length(i));
    
    file_id = fopen(file_name, 'w');
    
    for j = 1:length(borehole_spacing)
        fprintf(file_id, '%.3f %.3f\n', borehole_spacing(j), E(j));
    end
    
    fclose(file_id);
    
    toc

end
