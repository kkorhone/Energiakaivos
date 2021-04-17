function indexes_chosen = choose_from_indexes(indexes_to_choose_from, num_indexes_to_choose, indexes_already_chosen)

indexes_chosen = [];

while length(indexes_chosen) < num_indexes_to_choose
    random_index = indexes_to_choose_from(randi(length(indexes_to_choose_from), 1));
    if ~isempty(find(indexes_already_chosen==random_index, 1))
        continue
    end
    if isempty(indexes_chosen)
        indexes_chosen = [random_index];
    elseif isempty(find(indexes_chosen==random_index,1))
        indexes_chosen = [indexes_chosen, random_index];
    end
end
