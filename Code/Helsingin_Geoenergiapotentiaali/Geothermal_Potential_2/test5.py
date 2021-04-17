from statsmodels.sandbox.regression.predstd import wls_prediction_std
import statsmodels.api as sm
from pylab import *

rock_type = ["Amfiboliitti", "Gabro", "Graniitti", "Grano- ja kvartsidioriitti", "Kiillegneissi", u"Kvartsi-maas\xe4lp\xe4gneissi"]

rho_rock = array([2906.0, 2804.0, 2640.0, 2675.0, 2707.0, 2794.0])
Cp_rock = array([731.0, 712.0, 721.0, 731.0, 725.0, 723.0])
k_rock = array([2.66, 3.25, 3.20, 3.17, 2.87, 3.10])

E_field = array([11.858, 11.495, 11.126, 11.330, 11.269, 11.558])
E_single = array([38.223, 43.103, 42.448, 42.287, 39.541, 41.641])

def plot_ols_analysis(x, y):
    i = argsort(x)
    x, y = x[i], y[i]
    model = sm.OLS(y, sm.add_constant(x))
    results = model.fit()
    print results.summary()
    y_pred = results.predict()
    pred, lo, hi = wls_prediction_std(results)
    plot(x, y, "bo", label="Datapisteet")
    plot(x, y_pred, "r-", label=u"Korrelaatiosuora (R\xb2 = %.3f)"%results.rsquared)
    plot(x, y, "bo")
    plot(x, lo, "r--", label=u"95 % luottamusv\xe4li")
    plot(x, hi, "r--")

figure()
plot_ols_analysis(k_rock, E_field)
legend(loc=1)
xlabel(u"Kallion l\xe4mm\xf6njohtavuus [W/m\xb7K]")
ylabel(u"Yhdest\xe4 kent\xe4n kaivosta saatava energia [MWh/a]")
tight_layout()

# figure()
# plot_ols_analysis(rho_rock*Cp_rock*1e-6, E_field)
# legend(loc=2)
# xlabel(u"Tilavuusl\xe4mp\xf6kapasiteetti [J/m\xb3\xB7K]")
# ylabel(u"Yhdest\xe4 kent\xe4n kaivosta saatava energia [MWh/a]")
# tight_layout()

# figure()
# plot_ols_analysis(k_rock, E_single)
# legend(loc=2)
# xlabel(u"Kallion l\xe4mm\xf6njohtavuus [W/m\xb7K]")
# ylabel(u"Yhdest\xe4 yksin\xe4isest\xe4 kaivosta saatava energia [MWh/a]")
# tight_layout()

show()
