import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import (
	get_asymptotic_change_in_crowd_error_w_h,
	get_asymptotic_change_in_indy_error_w_h
)

zs = [0.25, 0.5, 1]

fig = plt.figure(figsize=(10,6))

min_h = -1
max_h = 1
min_cal = -1
max_cal = 1

cv = 0.5
std_e2 = 1
std_d2 = 1
std_e = 1

divnorm = mcolors.TwoSlopeNorm(vmin=-2, vcenter=0, vmax=2)

for k, z in enumerate(zs):
	
	hs = np.linspace(min_h,max_h,100)
	cals = np.linspace(min_cal,max_cal,200)
	delta_error_crowd = np.zeros((len(cals), len(hs)))
	delta_error_indy = np.zeros((len(cals), len(hs)))

	for i, h in enumerate(hs):
		for j, cal in enumerate(cals):
			delta_error_crowd[j, i] = get_asymptotic_change_in_crowd_error_w_h(cv, cal, h, z, std_e2, std_d2, std_e)   
			delta_error_indy[j, i] = get_asymptotic_change_in_indy_error_w_h(cv, cal, h, z, std_e2, std_d2, std_e) 

	plt.subplot(2, 3, k+1)
	plt.imshow(delta_error_crowd, norm=divnorm, cmap='seismic', 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_h, max_h, min_cal, max_cal])

	beta_crowd_1 = 0
	beta_crowd_2 = -4*z**2

	cal_boundary_1 = 1/std_e2 *(std_d2 * hs - beta_crowd_1*std_e**2/cv)
	plt.plot(hs, cal_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color

	cal_boundary_2 = 1/std_e2 *(std_d2 * hs - beta_crowd_2*std_e**2/cv)
	plt.plot(hs, cal_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color

		
	plt.xlim(min_h, max_h)
	plt.ylim(min_cal, max_cal)

	
	if k == 0:
		plt.ylabel(r"Calibration, $- r(v, e^2)$")

	if k == 1:
		plt.title("z = {}\nChange in Crowd Error".format(z))
	else:
		plt.title("z = {}\n".format(z))

	plt.subplot(2, 3, k+4)
	plt.imshow(delta_error_indy, norm=divnorm, cmap='seismic', 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_h, max_h, min_cal, max_cal])

	beta_indy_1 = -2*z**2 - 2 * z**2 * np.sqrt(1 + 1/(z**2))
	beta_indy_2 = -2*z**2 + 2 * z**2 * np.sqrt(1 + 1/(z**2))

	cal_boundary_1 = 1/std_e2 *(std_d2 * hs - beta_indy_1*std_e**2/cv)
	plt.plot(hs, cal_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color

	cal_boundary_2 = 1/std_e2 *(std_d2 * hs - beta_indy_2*std_e**2/cv)
	plt.plot(hs, cal_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color


	plt.xlim(min_h, max_h)
	plt.ylim(min_cal, max_cal)
	

	if k == 0:
		plt.ylabel(r"Calibration, $- r(v, e^2)$")

	
	plt.xlabel(r"Herding, $- r(v, d^2)$")

	if k == 1:
		plt.title("Change in Individual Error")





plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
sm = plt.cm.ScalarMappable(cmap='seismic', norm=divnorm)
sm.set_array([])
fig.colorbar(sm, cax=cbar_ax)

plt.savefig("images/robust_benefits_w_h.png", dpi=300)


plt.show()
