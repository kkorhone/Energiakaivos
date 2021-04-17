from pylab import *

data = [
    [ 0/12.0,  1/12.0, 0.175],
    [ 1/12.0,  2/12.0, 0.107],
    [ 2/12.0,  3/12.0, 0.112],
    [ 3/12.0,  4/12.0, 0.083],
    [ 4/12.0,  5/12.0, 0.045],
    [ 5/12.0,  6/12.0, 0.037],
    [ 6/12.0,  7/12.0, 0.032],
    [ 7/12.0,  8/12.0, 0.035],
    [ 8/12.0,  9/12.0, 0.045],
    [ 9/12.0, 10/12.0, 0.087],
    [10/12.0, 11/12.0, 0.119],
    [11/12.0, 12/12.0, 0.123]
]

figure(figsize=(8, 5))

for i in range(len(data)):
    params = data[i]
    if i == 0:
        plot([params[0], params[0], params[1]], [0, 100*params[2], 100*params[2]], "r-")
    elif i == len(data)-1:
        _params = data[i-1]
        plot([params[0], params[0], params[1], params[1]], [100*_params[2], 100*params[2], 100*params[2], 0], "r-")
    else:
        _params = data[i-1]
        plot([params[0], params[0], params[1]], [100*_params[2], 100*params[2], 100*params[2]], "r-")

month = ["Tammikuu", "Helmikuu", "Maaliskuu", "Huhtikuu", "Toukokuu", u"Kes\xe4kuu", u"Hein\xe4kuu", "Elokuu", "Syyskuu", "Lokakuu", "Marraskuu", "Joulukuu"]

for i in range(12):
    text((i+0.5)/12.0, 0.5, month[i], va="bottom", ha="center", rotation=90)

gca().set_xlim([-0.125/12.0, 1+0.125/12.0])
gca().set_ylim([0, 20])
gca().set_xticks(arange(0, 1+1/12.0, 1/12.0))

grid(ls="--")

xlabel("Aika [a]")
ylabel("Energiankulutus vuosittaisesta kulutuksesta [%]")

tight_layout()

savefig("test.png")

show()
