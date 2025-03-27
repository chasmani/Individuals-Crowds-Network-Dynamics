
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import get_asymptotic_change_in_crowd_error_w_h, get_asymptotic_change_in_indy_error_w_h

# get_asymptotic_change_in_crowd_error_w_h(Cv, calibration, herding, mean_z, std_e2, std_d2, std_e)


std_e = 1
z = 0.1
cv = 0.5
std_e2 = 1
std_d2 = 1

calibrations = np.linspace(-1,1,200)
herdings = np.linspace(-1,1,100)

delta_error_squared_crowd = np.zeros((len(calibrations), len(herdings)))
delta_error_squared_indy = np.zeros((len(calibrations), len(herdings)))

divnorm = mcolors.TwoSlopeNorm(vmin=-3, vcenter=0, vmax=5)

for i, calibration in enumerate(calibrations):
	for j, herding in enumerate(herdings):
		
		delta_error_squared_crowd[i, j] = get_asymptotic_change_in_crowd_error_w_h(cv, calibration, herding, z, std_e2, std_d2, std_e)
		delta_error_squared_indy[i, j] = get_asymptotic_change_in_indy_error_w_h(cv, calibration, herding, z, std_e2, std_d2, std_e)

fig = plt.figure(figsize=(10,4))

plt.subplot(1, 2, 1)		
plt.imshow(delta_error_squared_crowd, norm=divnorm, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower', extent=[min(herdings), max(herdings), min(calibrations), max(calibrations)])


calibration_boundary_1 = std_d2 / std_e2 * herdings
plt.plot(herdings, calibration_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color

calibration_boundary_2 = -1/std_e2 * (-4*z**2*std_e**2/cv - std_d2*herdings)

plt.plot(herdings, calibration_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color



plt.xlim(min(herdings), max(herdings))
plt.ylim(min(calibrations), max(calibrations))

plt.title("Crowd")
plt.xlabel(r"Herding, $- r(v, d^2)$")
plt.ylabel(r"Calibration, $- r(v, e^2)$")



plt.subplot(1, 2, 2)		
plt.imshow(delta_error_squared_indy, norm=divnorm, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower', extent=[min(herdings), max(herdings), min(calibrations), max(calibrations)])

beta_1 = -2*z**2 - 2*z*np.sqrt(z**2 + 1)

calibration_boundary_1 = -1/std_e2 * (beta_1**2*std_e**2/cv - std_d2*herdings)
plt.plot(herdings, calibration_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color


"""
wisdom_boundary_1 = herdings + 2 * mean_e**2 + 2*mean_e * np.sqrt(mean_e**2 + std_e**2)
wisdom_boundary_2 = herdings + 2 * mean_e**2 - 2*mean_e * np.sqrt(mean_e**2 + std_e**2)

plt.plot(herdings, wisdom_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
plt.plot(herdings, wisdom_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
"""

plt.xlim(min(herdings), max(herdings))
plt.ylim(min(calibrations), max(calibrations))


plt.title("Individual")
plt.xlabel(r"Herding, $- r(v, d^2)$")

plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
sm = plt.cm.ScalarMappable(cmap='seismic', norm=divnorm)
sm.set_array([])
fig.colorbar(sm, cax=cbar_ax)

plt.savefig("images/calibration_and_herding.png", dpi=300)

plt.show()