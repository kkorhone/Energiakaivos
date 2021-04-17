function stop = output_hectare(x, optim_values, state)

switch state
    case 'iter'
        fprintf(1, 'iteration=%d energy=%.30f\n', optim_values.iteration, x);
end

stop = false;
