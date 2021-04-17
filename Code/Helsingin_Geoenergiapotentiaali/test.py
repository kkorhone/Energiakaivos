import pylab as plt

cat = plt.rand(6)
dog = plt.rand(6)
activity = ["combing", "drinking", "feeding", "napping", "playing", "washing"]

#fig, ax = plt.subplots()
plt.plot(activity, dog)
plt.plot(activity, cat)

plt.show()
