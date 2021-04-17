function [train_indexes, test_indexes] = make_train_test_indexes(num_points, num_train_points, num_test_points)

train_indexes = [];

while length(train_indexes) < num_train_points
    train_index = randi(num_points, 1);
    if isempty(train_indexes)
        train_indexes = [train_index];
    elseif isempty(find(train_indexes==train_index, 1))
        train_indexes = [train_indexes, train_index];
    end
end

test_indexes = [];

while length(test_indexes) < num_test_points
    test_index = randi(num_points, 1);
    if isempty(test_indexes) && isempty(find(train_indexes==test_index, 1))
        test_indexes = [test_index];
    elseif isempty(find(test_indexes==test_index, 1)) && isempty(find(train_indexes==test_index, 1))
        test_indexes = [test_indexes, test_index];
    end
end
