import scipy.spatial.distance
import numpy

def calculate(x, y, z, lags):

    points = numpy.vstack((x, y)).T

    d = scipy.spatial.distance.pdist(points, metric="euclidean")
    g = 0.5 * scipy.spatial.distance.pdist(z[:, None], metric="sqeuclidean")

    h = numpy.zeros(len(lags)-1)
    semivariance = numpy.zeros(len(lags)-1)

    for n in range(len(lags)-1):
        if d[(d >= lags[n]) & (d <= lags[n + 1])].size > 0:
            h[n] = 0.5 * (lags[n] + lags[n + 1])
            semivariance[n] = numpy.mean(g[(d >= lags[n]) & (d < lags[n + 1])])
        else:
            h[n] = numpy.nan
            semivariance[n] = numpy.nan

    return h[~numpy.isnan(h)], semivariance[~numpy.isnan(semivariance)]
