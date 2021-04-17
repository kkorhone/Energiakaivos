import scipy.interpolate
from pylab import *

r, z, T, qr, qz = loadtxt("hellstrom_gehlin.txt", skiprows=9).T

i = where((z >= -182) & (r <= 30))

r, z, T, qr, qz = r[i], z[i], T[i], qr[i], qz[i]

num_rows = 500
num_cols = 400

step_size = 20

z_thershold = 0.001

ri = linspace(0, 30, num_cols)
zi = linspace(-182, 0, num_rows)

ri, zi = meshgrid(ri, zi)

ri = reshape(ri, (1, num_rows*num_cols))
zi = reshape(zi, (1, num_rows*num_cols))

Ti = scipy.interpolate.griddata(vstack((r, z)).T, T, vstack((ri, zi)).T)

ri = reshape(ri, (num_rows, num_cols))
zi = reshape(zi, (num_rows, num_cols))
Ti = reshape(Ti, (num_rows, num_cols))

figure(figsize=(6.5, 7.9))

cs = contour(ri, zi, Ti, levels=[6.5, 7, 7.5, 8.25], colors="r", lw=3)

for i in range(len(cs.collections)):
    for j in range(len(cs.collections[i].get_paths())):
        points = cs.collections[i].get_paths()[j].vertices
        _r, _z = points[:, 0], points[:, 1]
        _qr = scipy.interpolate.griddata(vstack((r, z)).T, qr, points)
        _qz = scipy.interpolate.griddata(vstack((r, z)).T, qz, points)
        _qt = sqrt(_qr**2+_qz**2)
        _r, _z, _qr, _qz, _qt = _r[::step_size], _z[::step_size], _qr[::step_size], _qz[::step_size], _qt[::step_size]
        _r, _z, _qr, _qz, _qt = _r[_z<-z_thershold], _z[_z<-z_thershold], _qr[_z<-z_thershold], _qz[_z<-z_thershold], _qt[_z<-z_thershold]
        h = quiver(_r, _z, _qr/_qt, _qz/_qt, lw=3, color="b")
        setp(h, 'clip_on', False)

gca().set_xticks([0, 10, 20, 30])
gca().set_yticks([0, -50, -100, -150])

grid()

show()
