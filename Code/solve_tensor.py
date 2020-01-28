from sympy.matrices import *
from sympy import *

k_large = Symbol("k_large", positive=True)
k_fluid = Symbol("k_fluid", positive=True)

theta = Symbol("theta", positive=True)
phi = Symbol("phi", positive=True)

Ry = Matrix([[cos(theta), 0, -sin(theta)], [0, 1, 0], [sin(theta), 0, cos(theta)]])
Rz = Matrix([[cos(phi), -sin(phi), 0], [sin(phi), cos(phi), 0], [0, 0, 1]])

R = Ry * Rz

#print("{}".format(str(R[0,:])))
#print("{}".format(str(R[1,:])))
#print("{}".format(str(R[2,:])))
#raise SystemExit

T = Matrix([[k_large, 0, 0], [0, k_large, 0], [0, 0, k_fluid]])

R_inv = simplify(R.inv())

T_trans = R_inv * T * R
T_trans = simplify(T_trans)

print("T11 = {}".format(str(T_trans[0,0])))
print("T12 = {}".format(str(T_trans[0,1])))
print("T13 = {}".format(str(T_trans[0,2])))
print()
print("T21 = {}".format(str(T_trans[1,0])))
print("T22 = {}".format(str(T_trans[1,1])))
print("T23 = {}".format(str(T_trans[1,2])))
print()
print("T31 = {}".format(str(T_trans[2,0])))
print("T32 = {}".format(str(T_trans[2,1])))
print("T33 = {}".format(str(T_trans[2,2])))
