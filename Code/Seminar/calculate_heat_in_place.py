from mpl_toolkits.mplot3d import Axes3D
from pylab import *

T_surface = 3.0
q_geothermal = 0.038

rho_rock = 2794.0
Cp_rock = 682.0
k_rock = 2.92

tunnel_depth = 1440.0
field_radius = 320.0

def T_ground(z):
    return T_surface - q_geothermal / k_rock * z

class Voxel:

    def __init__(self, xlim, ylim, zlim):
        self.xlim = xlim
        self.ylim = ylim
        self.zlim = zlim
        self.x_center = mean(xlim)
        self.y_center = mean(ylim)
        self.z_center = mean(zlim)
        self.T_mean = T_ground(self.z_center)

    def energy_release(self, T_ref):
        delta_T = self.T_mean - T_ref
        volume = (xlim[1] - xlim[0]) * (ylim[1] - ylim[0]) * (zlim[1] - zlim[0])
        # J = W * s ==> GW / 1e9 * h / 3600
        E = rho_rock * Cp_rock * volume * delta_T / (3600.0 * 1e9)
        return E

def create_voxel(xlim, ylim, zlim):
    z = mean(zlim)
    if z <= -tunnel_depth:
        dx = mean(xlim)
        dy = mean(ylim)
        dz = z + tunnel_depth
        distance = sqrt(dx**2 + dy**2 + dz**2)
        if distance <= field_radius:
            return Voxel(xlim, ylim, zlim)
    return None

T_ref = 2.0

dx, dy, dz = 10, 10, 10

voxels = []

x_range = arange(-500, 500, dz)
y_range = arange(-500, 500, dy)
z_range = arange(-2000, -1000, dz)

x, y, z, T, E = [], [], [], [], []

for i in range(len(z_range)):
    zlim = [z_range[i], z_range[i]+dz]
    for j in range(len(y_range)):
        ylim = [y_range[j], y_range[j]+dy]
        for k in range(len(x_range)):
            xlim = [x_range[k], x_range[k]+dx]
            voxel = create_voxel(xlim, ylim, zlim)
            if voxel:
                voxels.append(voxel)
                x.append(voxel.x_center)
                y.append(voxel.y_center)
                z.append(voxel.z_center)
                T.append(voxel.T_mean)
                E.append(voxel.energy_release(T_ref))
    print("%.3f %%"% ((i+1)*100.0/len(z_range)))

print("N=%d"%len(voxels))
print("E=%f"%sum(E))
print("min(E)=%f, max(E)=%f"%(min(E),max(E)))
print("mean(T)=%f"%(sum(T)/len(T)))
print("min(T)=%f max(T)=%f"%(min(T),max(T)))

delta_T = (sum(T)/len(T)) - T_ref
volume = 0.5 * 4.0 / 3.0 * pi * field_radius**3
E = rho_rock * Cp_rock * volume * delta_T / (3600.0 * 1e9)
print(volume*1e-6)
print("total(E)=%f"%E)

fig = figure()
ax = Axes3D(fig)

ax.scatter(x, y, z, s=T)

show()
