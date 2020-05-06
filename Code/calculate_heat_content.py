from mpl_toolkits.mplot3d import Axes3D
from pylab import *

T_surface = 3.0
q_geothermal = 0.038

rho_rock = 2794.0
Cp_rock = 682.0
k_rock = 2.92

energy_unit =  1.0 / (3600.0 * 1e9)

class Voxel:

    def __init__(self, xlim, ylim, zlim):
        self.xlim = xlim
        self.ylim = ylim
        self.zlim = zlim
        self.x_center = mean(xlim)
        self.y_center = mean(ylim)
        self.z_center = mean(zlim)
        self.T_mean = T_surface - q_geothermal / k_rock * mean(zlim)

    def calculate_energy_release(self, T_reference):
        delta_T = self.T_mean - T_reference
        volume = (self.xlim[1] - self.xlim[0]) * (self.ylim[1] - self.ylim[0]) * (self.zlim[1] - self.zlim[0])
        return rho_rock * Cp_rock * volume * delta_T * energy_unit

    @staticmethod
    def create_voxel(xlim, ylim, zlim, tunnel_depth, field_radius):
        z = mean(zlim)
        if z <= -tunnel_depth:
            dx = mean(xlim)
            dy = mean(ylim)
            dz = z + tunnel_depth
            distance = sqrt(dx**2 + dy**2 + dz**2)
            if distance <= field_radius:
                return Voxel(xlim, ylim, zlim)
        return None

def calculate_heat_in_place(dx, dy, dz, tunnel_depth, field_radius, T_reference):

    voxels = []

    x_range = arange(-field_radius-dx, field_radius+2*dx, dx)
    y_range = arange(-field_radius-dy, field_radius+2*dy, dy)
    z_range = arange(-tunnel_depth-field_radius-dz, -tunnel_depth+2*dz, dz)

    x, y, z, T, E = [], [], [], [], []

    for i in range(len(z_range)):
        zlim = [z_range[i], z_range[i]+dz]
        for j in range(len(y_range)):
            ylim = [y_range[j], y_range[j]+dy]
            for k in range(len(x_range)):
                xlim = [x_range[k], x_range[k]+dx]
                voxel = Voxel.create_voxel(xlim, ylim, zlim, tunnel_depth, field_radius)
                if voxel:
                    voxels.append(voxel)
                    x.append(voxel.x_center)
                    y.append(voxel.y_center)
                    z.append(voxel.z_center)
                    T.append(voxel.T_mean)
                    E.append(voxel.calculate_energy_release(T_reference))
        print("%3.0f %%\b\b\b\b\b"% ((i+1)*100.0/len(z_range)), end="", flush=True)

    print("Done.")

    voxel_E = sum(E)

    delta_T = sum(T) / len(T) - T_reference

    sphere_V = 0.5 * 4.0 / 3.0 * pi * field_radius**3
    sphere_E = rho_rock * Cp_rock * sphere_V * delta_T * energy_unit

    delta_T = T_surface - q_geothermal / k_rock * mean(-tunnel_depth+10) - T_reference

    ring_V = pi * field_radius**2 * 20.0
    ring_E = rho_rock * Cp_rock * ring_V * delta_T * energy_unit

    return voxel_E, sphere_E+ring_E

T_reference = 2.0

tunnel_depth = 1440.0
field_radius = array([350.0])#, 430.0, 530.0, 630.0])

voxel_E = zeros_like(field_radius)
sphere_E = zeros_like(field_radius)

for i in range(len(field_radius)):
    voxel_E[i], sphere_E[i] = calculate_heat_in_place(10.0, 10.0, 10.0, tunnel_depth, field_radius[i], T_reference)
    print("----------------------------------------")
    print("field_radius=%f" % field_radius[i])
    print("voxel_E=%.3f" % voxel_E[i])
    print("sphere_E=%.3f" % sphere_E[i])

# 300.00	836.85	0.83685
# 400.00	1893.6	1.8936
# 500.00	3625.8	3.6258
# 600.00	6229.4	6.2294
