function nodes = uv_sphere(num_points_per_circle, num_circles)

    function range = numpy_linspace(start, stop, num, end_point)
        delta = (stop - start) / num;
        if end_point
            range = start:delta:stop;
        else
            range = start:delta:(stop-delta);
        end
    end

    % Mesh parameters
    n_phi = num_points_per_circle;
    n_theta = num_circles;

    % Generate suitable ranges for parametrization
    phi_range = numpy_linspace(0, 2*pi, n_phi, false);
    theta_range = numpy_linspace(-pi/2+pi/(n_theta-1), pi/2-pi/(n_theta-1), n_theta-2, true);

    num_nodes = length(theta_range) * length(phi_range) + 2;
    nodes = zeros(num_nodes, 3);
    % south pole
    k = 1;
    nodes(k, :) = [0.0, 0.0, -1.0];
    k = k + 1;
    % nodes in the circles of latitude (except poles)
    for theta = theta_range
        for phi = phi_range
            nodes(k, :) = [cos(theta)*sin(phi), cos(theta)*cos(phi), sin(theta)];
            k = k + 1;
        end
    end
    % north pole
    nodes(k, :) = [0.0, 0.0, 1.0];

end
