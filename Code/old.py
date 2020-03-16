def _quarter_symmetry(bhe_axes):
    # Finds the BHEs located in the first quadrant.
    i = where((bhe_axes[:,0]>-1e-6)&(bhe_axes[:,1]>-1e-6))[0]
    quad_axes = bhe_axes[i, :]
    # Mirrors the first quadrant axes with respect to the y axis.
    half_axes = copy(quad_axes)
    half_axes[:, 0] *= -1
    half_axes = vstack((quad_axes, half_axes))
    # Mirrors the first and second quadrant axes with respect to the x axis.
    full_axes = copy(half_axes)
    full_axes[:, 1] *= -1
    full_axes = vstack((half_axes, full_axes))
    # Calculates the number of times the BHEs are found in the fully reflected dataset and plots the results.
    bhe_counts = zeros(bhe_axes.shape[0])
    figure()
    for i in range(bhe_axes.shape[0]):
        for j in range(full_axes.shape[0]):
            if distance_between_points(bhe_axes[i,:], full_axes[j,:]) < 1e-6:
                bhe_counts[i] += 1
        if bhe_counts[i] == 0:
            plot(bhe_axes[i,0], bhe_axes[i,1], "ro")
        elif bhe_counts[i] == 1:
            plot(bhe_axes[i,0], bhe_axes[i,1], "yo")
        elif bhe_counts[i] == 2:
            plot(bhe_axes[i,0], bhe_axes[i,1], "go")
        elif bhe_counts[i] == 4:
            plot(bhe_axes[i,0], bhe_axes[i,1], "mo")
        else:
            raise SystemExit("Invalid BHE count.")
    # Plots the first quadrant.
    plot([0, 0, 1, 1, 0], [0, 1, 1, 0, 0], "k--")
    for i in range(bhe_axes.shape[0]):
        text(bhe_axes[i,0], bhe_axes[i,1], "%.0f"%bhe_counts[i])
    # Checks for symmetry.
    if any(bhe_counts==0):
        title("Asymmetry")
    else:
        title("Symmetry with %d of %d BHEs" % (quad_axes.shape[0], bhe_axes.shape[0]))
    # Determines the BHE factors and the cut planes.
    bhe_factors = ones(quad_axes.shape[0])
    cut_planes = zeros(quad_axes.shape[0])
    for i in range(quad_axes.shape[0]):
        if abs(quad_axes[i,0]) < 1e-6 and abs(quad_axes[i,1]) < 1e-6:
            cut_planes[i] = 101
        elif abs(quad_axes[i,1]) < 1e-6:
            cut_planes[i] = 102
        elif abs(quad_axes[i,0]) < 1e-6:
            cut_planes[i] = 103
        else:
            cut_planes[i] = 104
        for j in range(bhe_axes.shape[0]):
            if distance_between_points(quad_axes[i,:], bhe_axes[j,:]) < 1e-6:
                if bhe_counts[j] == 4:
                    bhe_factors[i] = 1
                elif bhe_counts[j] == 2:
                    bhe_factors[i] = 2
                elif bhe_counts[j] == 1:
                    bhe_factors[i] = 4
                else:
                    raise SystemExit("Invalid BHE count.")
    axis("equal")
    show()
    return quad_axes, bhe_factors, cut_planes
