import numpy as np
import matplotlib as mpl
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

z2s = [0.1, 0.5, 1]

fig = plt.figure(figsize=(10,8))
gs = gridspec.GridSpec(3, 3, height_ratios=[3, 3, 3])

min_h = -1
max_h = 1
min_cal = -1
max_cal = 1

cv = 1
std_e2 = 1
std_d2 = 1
std_e = 1

cbar_range = 3

divnorm = mcolors.SymLogNorm(linthresh=0.1, vmin=-cbar_range, vmax=cbar_range)

for k, z2 in enumerate(z2s):
	
	hs = np.linspace(min_h,max_h,100)
	cals = np.linspace(min_cal,max_cal,100)
	delta_error_crowd = np.zeros((len(hs), len(cals)))
	delta_error_indy = np.zeros((len(hs), len(cals)))

	for i, cal in enumerate(cals):
		for j, h in enumerate(hs):

			delta = cv/(2*z2*std_e**2) * (std_d2 * -h - std_e2 * -cal)
			max_delta = cv/np.sqrt(z2) 
			if np.abs(delta) < np.abs(max_delta):			

				delta_error_crowd[j, i] = get_asymptotic_change_in_crowd_error_w_h(cv, cal, h, np.sqrt(z2), std_e2, std_d2, std_e)   
				delta_error_indy[j, i] = get_asymptotic_change_in_indy_error_w_h(cv, cal, h, np.sqrt(z2), std_e2, std_d2, std_e) 
			else:
				delta_error_crowd[j, i] = np.nan 
				delta_error_indy[j, i] = np.nan
			

	import matplotlib.transforms as transforms



	#plt.subplot(3, 3, k+1)
	ax = plt.subplot(gs[k+3])
	
	
	
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

	ax = plt.gca()
	ax.spines['top'].set_visible(False)
	ax.spines['right'].set_visible(False)
	

	ax.set_xlabel(r"$- r(v, e^2)$", rotation=-45)

	# Set the y-axis label with rotated text
	ax.set_ylabel(r"$- r(v, d^2)$", rotation=-45)
	ax.yaxis.labelpad = 20

	ax.set_aspect('equal')

	plt.yticks([-1, 0, 1])
	plt.xticks(rotation=-45)

	# Rotate the y-axis tick labels
	plt.yticks(rotation=-45)

	
	







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
	
	ax = plt.gca()
	# Remove top spines
	ax.spines['top'].set_visible(False)
	ax.spines['right'].set_visible(False)
	
	

	plt.ylim(min_h, max_h)
	plt.xlim(min_cal, max_cal)
	

	
	

	ax.set_xlabel(r"$- r(v, e^2)$", rotation=-45)

	# Set the y-axis label with rotated text
	ax.set_ylabel(r"$- r(v, d^2)$", rotation=-45)
	ax.yaxis.labelpad = 20

	ax.set_aspect('equal')

	plt.yticks([-1, 0, 1])
	plt.xticks(rotation=-45)

	# Rotate the y-axis tick labels
	plt.yticks(rotation=-45)

	if k == 1:
		plt.title("Change in Individual Error")

	hs = np.linspace(min_h,max_h,100)
	cals_alpha_iso_0 = np.linspace(min_cal,max_cal,100)
	





for k,z2 in enumerate(z2s):

	min_delta_scale = -cv/z2
	max_delta_scale = cv/z2

	min_delta = -cv/np.sqrt(z2)
	max_delta = cv/np.sqrt(z2)

	deltas = np.linspace(min_delta,max_delta,1000)

	delta_error_crowds = z2 * (deltas**2 - 2*deltas) 
	delta_error_indys = z2 * (deltas**2 - 2*deltas)  - 1

	plt.subplot(gs[k])
	plt.plot(deltas, delta_error_crowds, label="Crowd", color=crowd_color, linewidth=1)
	plt.plot(deltas, delta_error_indys, label="Individual", color=indy_color, linewidth=2)
	
	plt.xlabel(r"Crowd Opinion Delta, $\delta$")
	if k == 0:
		plt.ylabel(r"Change in Error")

	if k == 1:
		plt.title("Change in Crowd and Individual Error")


	plt.axvline(x=0, color="grey", linestyle="dotted")

	if max_delta >= 2:
		plt.axvline(x=2, color="grey", linestyle="dotted")

	indy_delta_zero = 1 - np.sqrt(1/z2+1)
	plt.axvline(x=indy_delta_zero, color="grey", linestyle="dashed")

	indy_delta_zero_b = 1 + np.sqrt(1/z2+1)
	if max_delta >= indy_delta_zero_b:
		plt.axvline(x=indy_delta_zero_b, color="grey", linestyle="dashed")

	plt.xlim(min_delta_scale, max_delta_scale)

	ax = plt.gca()
	ax.spines['top'].set_position('zero')
	# Don't draw lines for bottom and right axes.
	ax.spines['bottom'].set_color('none')
	ax.spines['right'].set_color('none')

	x_min, x_max = ax.get_xlim()
	ax.set_xticks(np.arange(int(x_min), int(x_max) + 1, 2))
	ax.set_xticklabels(np.arange(int(x_min), int(x_max) + 1, 2))
	
	# Draw ticks on top x axis, and leave labels on bottom.
	ax.tick_params(axis='x', bottom=False, top=True, direction='inout')

	plt.title(r"$z^2$ = {}".format(z2))

	plt.ylim((-3,3))




ax = plt.gca()

ax.legend(loc='center left', bbox_to_anchor=(1.2, 0.5))


# Add some gutters betwene plots

plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.07, 0.05, 0.6])

sm = plt.cm.ScalarMappable(cmap=cmap, norm=divnorm)
sm.set_array([])
cbar = fig.colorbar(sm, cax=cbar_ax)
from matplotlib.ticker import ScalarFormatter
cbar.ax.yaxis.set_major_formatter(ScalarFormatter())



plt.suptitle=r"z^2 = {}, \t, z^2={}, \t, z^2={}".format(z2s[0], z2s[1], z2s[2])



plt.savefig("images/robust_benefits_c_h_and_alpha_rotated.png", dpi=600)


plt.show()
