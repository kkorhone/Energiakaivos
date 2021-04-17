function value = get_parameter_value(model, parameter_name)
string_value = char(model.param.get(parameter_name));
[left, right] = strsplit(string_value, '[');
value = str2double(left)
