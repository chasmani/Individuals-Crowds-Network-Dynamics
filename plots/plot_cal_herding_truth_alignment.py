import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.gridspec as gridspec


import sys
sys.path.append("..")
from robust_benefits import (
	get_asymptotic_change_in_crowd_error_w_h,
	get_asymptotic_change_in_indy_error_w_h
)

crowd_color = "#2c3e50"
indy_color = "#2ecc71"
zero_color = "gray"

z2s = [0.1, 0.25, 1]

fig = plt.figure(figsize=(10,8))
gs = gridspec.GridSpec(3, 3, height_ratios=[2, 3, 3])

min_h = -1
max_h = 1
min_cal = -1
max_cal = 1

cv = 1
std_e2 = 1
std_d2 = 1
std_e = 1

cbar_range = 10

divnorm = mcolors.SymLogNorm(linthresh=0.1, vmin=-cbar_range, vmax=cbar_range)

for k, z2 in enumerate(z2s):
	
	hs = np.linspace(min_h,max_h,100)
	cals = np.linspace(min_cal,max_cal,100)
	delta_error_crowd = np.zeros((len(hs), len(cals)))
	delta_error_indy = np.zeros((len(hs), len(cals)))

	for i, cal in enumerate(cals):
		for j, h in enumerate(hs):
			alpha = cv/(2*std_e**2) * (std_d2 * -h - std_e2 * -cal)
			max_alpha = np.sqrt(z2) * cv
			if np.abs(alpha) < np.abs(max_alpha):			

				delta_error_crowd[j, i] = get_asymptotic_change_in_crowd_error_w_h(cv, cal, h, np.sqrt(z2), std_e2, std_d2, std_e)   
				delta_error_indy[j, i] = get_asymptotic_change_in_indy_error_w_h(cv, cal, h, np.sqrt(z2), std_e2, std_d2, std_e) 
			else:
				delta_error_crowd[j, i] = np.nan 
				delta_error_indy[j, i] = np.nan
			

	import matplotlib.transforms as transforms



	#plt.subplot(3, 3, k+1)
	ax = plt.subplot(gs[k+3])
	
	
	import matplotlib as mpl
	cmap = mpl.colormaps.get_cmap('coolwarm')  # viridis is the default colormap for imshow
	cmap.set_bad(color='white')
	plt.imshow(delta_error_crowd, norm=divnorm, cmap=cmap, 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_cal, max_cal, min_h, max_h])

	hs = np.linspace(min_h,max_h,100)
	cals_alpha_iso_0 = np.linspace(min_cal,max_cal,100)



	beta_crowd_1 = 0
	beta_crowd_2 = 2*z2

	h_boundary_1 = 1/std_d2 *(std_e2 * cals - 2*beta_crowd_1*std_e**2/cv)
	plt.plot(cals, h_boundary_1, color=zero_color, linewidth=2, linestyle="dotted")  # Use a contrasting color

	h_boundary_2 = 1/std_d2 *(std_e2 * cals - 2*beta_crowd_2*std_e**2/cv)
	plt.plot(cals, h_boundary_2, color=zero_color, linewidth=2, linestyle="dotted")  # Use a contrasting color
	
	plt.ylim(min_h, max_h)
	plt.xlim(min_cal, max_cal)

	
	if k == 0:
		plt.ylabel(r"Herding, $- r(v, d^2)$")

	plt.xlabel(r"Calibration, $- r(v, e^2)$")






	if k == 1:
		plt.title("Change in Crowd Error")



	plt.subplot(gs[k+6])
	plt.imshow(delta_error_indy, norm=divnorm, cmap=cmap, 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_cal, max_cal, min_h, max_h])

	
	beta_indy_1 = z2 - z2 * np.sqrt(1 + 1/(z2))
	beta_indy_2 = z2 + z2 * np.sqrt(1 + 1/(z2))

	h_boundary_1 = 1/std_d2 *(std_e2 * cals - 2*beta_indy_1*std_e**2/cv)
	plt.plot(cals, h_boundary_1, color=zero_color, linewidth=2, linestyle="dashed")  # Use a contrasting color

	h_boundary_2 = 1/std_d2 *(std_e2 * cals - 2*beta_indy_2*std_e**2/cv)
	#plt.plot(cals, h_boundary_2, color=zero_color, linewidth=2, linestyle="dashed")  # Use a contrasting color
	

	plt.ylim(min_h, max_h)
	plt.xlim(min_cal, max_cal)
	

	if k == 0:
		plt.ylabel(r"Herding, $- r(v, d^2)$")

	
	plt.xlabel(r"Calibration, $- r(v, e^2)$")

	if k == 1:
		plt.title("Change in Individual Error")

	hs = np.linspace(min_h,max_h,100)
	cals_alpha_iso_0 = np.linspace(min_cal,max_cal,100)
	
	
	







for k,z2 in enumerate(z2s):

	min_alpha = - np.abs(np.sqrt(z2)*cv)
	max_alpha = np.abs(np.sqrt(z2)*cv)

	alphas = np.linspace(min_alpha,max_alpha,100)

	delta_error_crowds = alphas**2 / z2 - 2*alphas
	delta_error_indys = alphas**2 / z2 - 2*alphas - 1

	plt.subplot(gs[k])
	plt.plot(alphas, delta_error_crowds, label="Crowd", color=crowd_color, linewidth=1)
	plt.plot(alphas, delta_error_indys, label="Individual", color=indy_color, linewidth=2)
	plt.xlim(-cv,cv)
	plt.xlabel(r"Truth Alignment, $\alpha$")
	if k == 0:
		plt.ylabel(r"Change in Error")

	if k == 1:
		plt.title("Change in Crowd and Individual Error")

	crowd_zero_1 = 0
	crowd_zero_2 = 2*z2

	plt.axvline(x=crowd_zero_1, color="grey", linestyle="dotted")
	plt.axvline(x=crowd_zero_2, color="grey", linestyle="dotted")

	indy_zero_1 = z2 - z2 * np.sqrt(1 + 1/(z2))
	indy_zero_2 = z2 + z2 * np.sqrt(1 + 1/(z2))

	plt.axvline(x=indy_zero_1, color="grey", linestyle="dashed")
	#plt.axvline(x=indy_zero_2, color="grey", linestyle="dashed")

	ax = plt.gca()
	ax.spines['top'].set_position('zero')
	# Don't draw lines for bottom and right axes.
	ax.spines['bottom'].set_color('none')
	ax.spines['right'].set_color('none')
	# Draw ticks on top x axis, and leave labels on bottom.
	ax.tick_params(axis='x', bottom=False, top=True, direction='inout')

	plt.title(r"$z^2$ = {}".format(z2))



plt.legend()



plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.07, 0.05, 0.6])
sm = plt.cm.ScalarMappable(cmap='coolwarm', norm=divnorm)

sm.set_array([])
cbar = fig.colorbar(sm, cax=cbar_ax)
from matplotlib.ticker import ScalarFormatter
cbar.ax.yaxis.set_major_formatter(ScalarFormatter())


plt.suptitle=r"z^2 = {}, \t, z^2={}, \t, z^2={}".format(z2s[0], z2s[1], z2s[2])



plt.savefig("images/robust_benefits_c_h_and_alpha_isoline.png", dpi=600)


plt.show()
