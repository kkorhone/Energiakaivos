from sympy.matrices import *
from sympy import *

theta = Symbol("theta")
phi = Symbol("phi")
x = Symbol("x")

r = Matrix([x, 0, 0])

Ry = Matrix([[cos(theta), 0, -sin(theta)], [0, 1, 0], [sin(theta), 0, cos(theta)]])
Rz = Matrix([[cos(phi), -sin(phi), 0], [sin(phi), cos(phi), 0], [0, 0, 1]])

R = Rz * Ry

print("Rotation matrix")
print(R[0,:])
print(R[1,:])
print(R[2,:])

r_ = R * x

print("Rotated point")
print(r_[0])
print(r_[1])
print(r_[2])
