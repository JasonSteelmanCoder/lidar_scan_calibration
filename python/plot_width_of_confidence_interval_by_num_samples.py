# CAUTION: this script only calculates the curve for one macroplot and one biomass type at a time. 

import matplotlib.pyplot as plt
import numpy as np

Z = 1.96            # 95% confidence interval
sigma = 13          # the standard deviation of the biomass on observed clip plots

n = np.linspace(1, 24, 24)
W = np.sqrt((4 * (Z**2) * (sigma**2)) / (n))
print(W)

plt.plot(n, W)
plt.title("Width of the Confidence Interval \nfor the estimated mean biomass per quarter meter squared".title())
plt.ylim(bottom=0)
plt.ylabel("Width of Confidence Interval")
plt.xlabel("Number of Clip Plots")
plt.show()

# plt.clf()
# distr = np.random.normal(61, 3.5, 5000)
# plt.hist(distr, bins=100)
# plt.xlim(left=0)
# plt.show()