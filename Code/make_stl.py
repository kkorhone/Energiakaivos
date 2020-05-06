from pylab import *
import meshzoo

vertices, faces = meshzoo.icosa_sphere(5)

face_bag = []
vertex_bag = []

for i in range(faces.shape[0]):
    x1, y1, z1 = vertices[faces[i][0]].T
    x2, y2, z2 = vertices[faces[i][1]].T
    x3, y3, z3 = vertices[faces[i][2]].T
    if z1 <= 1e-3 and z2 <= 1e-3 and z3 <= 1e-3:
        face_bag.append(i)
        vertex_bag.append(vertices[faces[i][0]])
        vertex_bag.append(vertices[faces[i][1]])
        vertex_bag.append(vertices[faces[i][2]])

stl_file = open("tessellation.stl", "w")

for i in face_bag:
    x1, y1, z1 = vertices[faces[i][0]].T
    x2, y2, z2 = vertices[faces[i][1]].T
    x3, y3, z3 = vertices[faces[i][2]].T
    v12 = array([x2-x1, y2-y1, z2-z1])
    v13 = array([x3-x1, y3-y1, z3-z1])
    n1 = cross(v12, v13)
    n1 /= sqrt(dot(n1, n1))
    stl_file.write("solid triangle%d\n"%i)
    stl_file.write("    facet normal %f %f %f\n" % tuple(n1))
    stl_file.write("        outer loop\n")
    stl_file.write("            vertex %f %f %f\n" % (x1, y1, z1))
    stl_file.write("            vertex %f %f %f\n" % (x2, y2, z2))
    stl_file.write("            vertex %f %f %f\n" % (x3, y3, z3))
    stl_file.write("        endloop\n")
    stl_file.write("    endfacet\n")
    stl_file.write("endsolid triangle%d\n"%i)

stl_file.close()

vertex_bag = array(vertex_bag)

print(vertex_bag)

savetxt("stl_points.txt", vertex_bag.T)
