import pandas
import numpy
import pylab

# ----------------------------------------------------------------------------
# Sets up constants.
# ----------------------------------------------------------------------------

MWh_per_a = 1.0 / (3600.0 * 1.0e+6) / 50.0

A_pixel = 100.0 * 100.0

# ----------------------------------------------------------------------------
# Calculates the potentials.
# ----------------------------------------------------------------------------

data_frame = pandas.read_excel("map_point_samples.xlsx")

maximum_potential = numpy.zeros((data_frame.shape[0], 3))

for i in range(data_frame.shape[0]):
    # ------------------------------------------------------------------------
    # Fetches the parameter values.
    # ------------------------------------------------------------------------
    k_rock = data_frame["k_rock"][i]
    Cp_rock = data_frame["Cp_rock"][i]
    rho_rock = data_frame["rho_rock"][i]
    T_surface = data_frame["T_surface"][i]
    q_geothermal = 0.001 * data_frame["q_geothermal"][i]
    # ------------------------------------------------------------------------
    # Calculates the maximum potential of the first 150 meters.
    # ------------------------------------------------------------------------
    delta_T = T_surface + q_geothermal / k_rock * (0.5 * 150.0)
    maximum_potential[i, 0] = rho_rock * (A_pixel * 150.0) * Cp_rock * delta_T * MWh_per_a
    # ------------------------------------------------------------------------
    # Calculates the maximum potential of the first 300 meters.
    # ------------------------------------------------------------------------
    delta_T = T_surface + q_geothermal / k_rock * (0.5 * 300.0)
    maximum_potential[i, 1] = rho_rock * (A_pixel * 300.0) * Cp_rock * delta_T * MWh_per_a
    # ------------------------------------------------------------------------
    # Calculates the maximum potential of the first 1000 meters.
    # ------------------------------------------------------------------------
    delta_T = T_surface + q_geothermal / k_rock * (0.5 * 1000.0)
    maximum_potential[i, 2] = rho_rock * (A_pixel * 1000.0) * Cp_rock * delta_T * MWh_per_a

data_frame.insert(loc=9, column="max_pot_150", value=maximum_potential[:,0])
data_frame.insert(loc=10, column="max_pot_300", value=maximum_potential[:,1])
data_frame.insert(loc=11, column="max_pot_1000", value=maximum_potential[:,2])

excel_writer = pandas.ExcelWriter("maximum_potentials.xlsx")

data_frame.to_excel(excel_writer, "Maximum potentials")

excel_writer.save()

pylab.figure()
pylab.scatter(data_frame["x"], data_frame["y"], c=maximum_potential[:,0], s=0.1, cmap="RdYlGn_r")
pylab.colorbar()
pylab.axis("equal")
pylab.tight_layout()
pylab.title("The total potential of the uppermost 300 m is %.3f TWh/a" % (sum(maximum_potential[:,0])*1e-6))

pylab.figure()
pylab.scatter(data_frame["x"], data_frame["y"], c=maximum_potential[:,1], s=0.1, cmap="RdYlGn_r")
pylab.colorbar()
pylab.axis("equal")
pylab.tight_layout()
pylab.title("The total potential of the uppermost 300 m is %.3f TWh/a" % (sum(maximum_potential[:,1])*1e-6))

pylab.figure()
pylab.scatter(data_frame["x"], data_frame["y"], c=maximum_potential[:,2], s=0.1, cmap="RdYlGn_r")
pylab.colorbar()
pylab.axis("equal")
pylab.tight_layout()
pylab.title("The total potential of the uppermost 300 m is %.3f TWh/a" % (sum(maximum_potential[:,2])*1e-6))

pylab.show()
