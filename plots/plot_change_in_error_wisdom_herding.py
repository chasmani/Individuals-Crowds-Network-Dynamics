
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import get_asymptotic_change_in_crowd_error_w_h, get_asymptotic_change_in_individual_error_w_h

mean_e = 0.5
std_e = 1

wisdoms = np.linspace(-1.5,1.5,200)
herdings = np.linspace(-1.5,1.5,100)

delta_error_squared_crowd = np.zeros((len(wisdoms), len(herdings)))
delta_error_squared_indy = np.zeros((len(wisdoms), len(herdings)))

divnorm = mcolors.TwoSlopeNorm(vmin=-3, vcenter=0, vmax=5)

for i, wisdom in enumerate(wisdoms):
	for j, herding in enumerate(herdings):
		
		delta_error_squared_crowd[i, j] = get_asymptotic_change_in_crowd_error_w_h(wisdom, herding, mean_e)
		delta_error_squared_indy[i, j] = get_asymptotic_change_in_individual_error_w_h(wisdom, herding, mean_e, std_e)

fig = plt.figure(figsize=(10,4))

plt.subplot(1, 2, 1)		
plt.imshow(delta_error_squared_crowd, norm=divnorm, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower', extent=[min(herdings), max(herdings), min(wisdoms), max(wisdoms)])


wisdom_boundary_1 = herdings
wisdom_boundary_2 = herdings + 4*mean_e**2

plt.plot(herdings, wisdom_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
plt.plot(herdings, wisdom_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color

plt.xlim(min(herdings), max(herdings))
plt.ylim(min(wisdoms), max(wisdoms))

plt.title("Crowd")
plt.xlabel(r"Herding, $- n cov(v, d^2)$")
plt.ylabel(r"Wisdom, $- n cov(v, e^2)$")



plt.subplot(1, 2, 2)		
plt.imshow(delta_error_squared_indy, norm=divnorm, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower', extent=[min(herdings), max(herdings), min(wisdoms), max(wisdoms)])

wisdom_boundary_1 = herdings + 2 * mean_e**2 + 2*mean_e * np.sqrt(mean_e**2 + std_e**2)
wisdom_boundary_2 = herdings + 2 * mean_e**2 - 2*mean_e * np.sqrt(mean_e**2 + std_e**2)

plt.plot(herdings, wisdom_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
plt.plot(herdings, wisdom_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color

plt.xlim(min(herdings), max(herdings))
plt.ylim(min(wisdoms), max(wisdoms))


plt.title("Individual")
plt.xlabel(r"Herding, $- n cov(v, d^2)$")

plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
sm = plt.cm.ScalarMappable(cmap='seismic', norm=divnorm)
sm.set_array([])
fig.colorbar(sm, cax=cbar_ax)

plt.savefig("images/herding_vs_wisdom.png", dpi=300)

plt.show()