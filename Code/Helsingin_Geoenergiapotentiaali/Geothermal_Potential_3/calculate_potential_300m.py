from pylab import *

# =================================================================================================
# Sets up calculation parameters.
# =================================================================================================

pixel_width = 100.0
pixel_height = 100.0

borehole_length = 300.0
extraction_time = 50.0

ground_volume = pixel_width * pixel_height * borehole_length

megawatt_hours = 1.0 / 3600.0 / 1.0e+6

# =================================================================================================
# Calculates values of stored energy for each pixel using per pixel parameters.
# =================================================================================================

data = loadtxt("sampled_map_points.txt")

num_pixels = data.shape[0]

pixel_id = data[:, 0]
pixel_poly_id = data[:, 1]

x = data[:, 2]
y = data[:, 3]

k_rock = data[:, 4]
Cp_rock = data[:, 5]
rho_rock = data[:, 6]

T_surface = data[:, 7]
q_geothermal = 0.001 * data[:, 8]

delta_T = T_surface + q_geothermal / k_rock * (0.5 * borehole_length)

E_pixel = rho_rock * Cp_rock * ground_volume * delta_T * megawatt_hours / extraction_time

# =================================================================================================
# Calculates values of stored energy for each pixel using per polygon parameters.
# =================================================================================================

data = loadtxt("bedrock_map.txt")

poly_id = data[:, 0]

k_rock = data[:, 1]
Cp_rock = data[:, 2]
rho_rock = data[:, 3]

T_surface = data[:, 4]
q_geothermal = 0.001 * data[:, 5]

delta_T = T_surface + q_geothermal / k_rock * (0.5 * borehole_length)

E_poly = zeros(num_pixels)

for i in range(num_pixels):

    j = where(poly_id == pixel_poly_id[i])

    assert len(j) == 1

    k = j[0]

    E_poly[i] = rho_rock[k] * Cp_rock[k] * ground_volume * delta_T[k] * megawatt_hours / extraction_time

# =================================================================================================
# Provides output.
# =================================================================================================

figure(figsize=(9, 7))
scatter(0.001*x, 0.001*y, c=E_pixel, s=2, cmap="RdYlGn_r")
color_bar = colorbar()
color_bar.set_label("Stored heating energy [MWh/a/ha]")
title("Total heating energy stored in the upper %.0f meters is %.1f TWh/a\non per pixel basis" % (borehole_length, sum(E_pixel)*1e-6))
axis("equal")
xlabel("X [km]")
ylabel("Y [km]")
tight_layout()

figure(figsize=(9, 7))
scatter(0.001*x, 0.001*y, c=E_poly, s=2, cmap="RdYlGn_r")
color_bar = colorbar()
color_bar.set_label("Stored heating energy [MWh/a/ha]")
title("Total heating energy stored in the upper %.0f meters is %.1f TWh/a\non per polygon basis" % (borehole_length, sum(E_poly)*1e-6))
axis("equal")
xlabel("X [km]")
ylabel("Y [km]")
tight_layout()

figure(figsize=(9, 7))
scatter(0.001*x, 0.001*y, c=abs(E_pixel-E_poly)*100.0/E_pixel, s=2, cmap="RdYlGn_r")
color_bar = colorbar()
color_bar.set_label("Difference in stored heating energy [%]")
title("Sum of differences is %.6f TWh/a" % (sum(E_pixel-E_poly)*1e-6))
axis("equal")
xlabel("X [km]")
ylabel("Y [km]")
tight_layout()

show()
