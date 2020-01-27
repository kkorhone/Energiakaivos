function cell_array = vector_to_cell_array(vector)
cell_array = cell(size(vector));
for i = 1:size(vector, 1)
    for j = 1:size(vector, 2)
        cell_array{i, j} = sprintf('%.6f', vector(i, j));
    end
end
if isscalar(cell_array)
    cell_array = cell_array{1, 1};
end
