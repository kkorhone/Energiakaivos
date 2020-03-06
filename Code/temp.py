def test_for_symmetry(points):
    
    # Finds all points in the first quandrant.
    
    k = []
    
    for i in range(points.shape[0]):
        if abs(points[i, 0]) < 1e-6 and abs(points[i, 1]) < 1e-6:
            k.append(i)
        if abs(points[i, 0]) < 1e-6 and points[i, 1] >= 0:
            k.append(i)
        elif points[i, 0] >= 0 and abs(points[i, 1]) < 1e-6:
            k.append(i)
        elif points[i, 0] >=0 and points[i, 1] >= 0:
            k.append(i)
            
    # Points in the first quadrant.
    
    p1 = points[k, :]
    
    # Mirror against the x axis.
    
    p2 = vstack((-p1[:,0], p1[:,1], p1[:,2])).T
    
    # Mirrored points in the first and second quadrants.
    
    p3 = vstack((p1, p2))
    
    # Mirror against the y axis.
    
    p4 = vstack((p3[:,0], -p3[:,1], p3[:,2])).T
    
    # Mirrored points in all quadrants.
    
    p5 = vstack((p3, p4))
    
    # Tests for the results.
    
    # Plots the results.

    figure()    
    plot(p5[:,0], p5[:,1], "ro", mfc="w")
    plot(points[:,0], points[:,1], "c.")
    
    bag = []
    for i in range(points.shape[0]):
        k = -1
        for j in range(p5.shape[0]):
            if distance_between_points(points[i, :], p5[j, :]) < 1e-6:
                k = j
        if k >= 0:
            bag.append(k)
    
    if len(bag) == points.shape[0]:
        title("Symmetry (%d points)" % points.shape[0])
    else:
        title("Asymmetry (%d points)" % (points.shape[0]-len(bag)))
