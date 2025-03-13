

import numpy as np
import matplotlib.pyplot as plt


import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import (
	get_asymptotic_change_in_crowd_error_w_h,
	get_asymptotic_change_in_indy_error_w_h
)

COLOR_GOOD = "#2980b9"
COLOR_BAD = "#c0392b"

CROWD_ZERO_COLOR = "#404040"
CROWD_ZERO_STYLE = "dashed"
CROWD_ZERO_WIDTH = 2

INDY_ZERO_COLOR = "#404040"
INDY_ZERO_STYLE = "dotted"
INDY_ZERO_WIDTH = 2


COLOR_SCHEME = "color"

if COLOR_SCHEME == "grey":
	COLOR_BOTH_IMPROVE = 'grey'
	COLOR_BOTH_WORSE = 'lightgrey'
	COLOR_INDY_IMPROVE_CROWD_WORSE =  'white'

	HATCH_BOTH_IMPROVE = 'xxx'
	HATCH_BOTH_WORSE = '...'
	HATCH_INDY_IMPROVE_CROWD_WORSE = 'xxx'

else:
	COLOR_BOTH_IMPROVE = '#2ecc71'
	COLOR_INDY_IMPROVE_CROWD_WORSE =  '#f1c40f'
	COLOR_BOTH_WORSE = '#9b59b6'

	HATCH_BOTH_IMPROVE = ''
	HATCH_BOTH_WORSE = ''
	HATCH_INDY_IMPROVE_CROWD_WORSE = ''



def get_indy_zero_beta_plus(e2, cv):
	return -2/cv * (np.sqrt(e2**2 + e2) - e2)

def get_indy_zero_beta_minus(e2, cv):
	return -2/cv * (-np.sqrt(e2**2 + e2) - e2)

def get_max_abs_c_minus_h(e2, s_e):
	"""
	The maximum possible absolute value of the difference between calibration and herding (i.e. when r(v,e) = 1 or -1)
	Assumes s(e2) = 1 and s(d2) = 1
	"""
	e_abs = np.sqrt(e2)
	return min(2*e_abs*s_e, 2)

def plot_error_beta_areas(cv=1, std_e=1):

	n = 1000
	es = np.linspace(0, 1.3, n)
	e2s = es**2

	crowd_zero_beta_1 = np.zeros(n)

	crowd_zero_beta_minus_1 = 4/cv * e2s

	to_truth_beta_zero = 2/cv * e2s

	indy_zero_beta_plus = [get_indy_zero_beta_plus(e2, cv) for e2 in e2s]
	indy_zero_beta_minus = [get_indy_zero_beta_minus(e2, cv) for e2 in e2s]

	max_abs_c_minus_h = np.array([get_max_abs_c_minus_h(e2, std_e) for e2 in e2s])

	# Area filling
	# 1. Crowd Improvement
	crowd_improvement_top_boundary = np.minimum(max_abs_c_minus_h, crowd_zero_beta_minus_1)
	crowd_improvement_bottom_boundary = crowd_zero_beta_1
	ax = plt.gca()
	ax.fill_between(e2s, crowd_improvement_top_boundary, crowd_improvement_bottom_boundary, color=COLOR_BOTH_IMPROVE, alpha=0.8,
				  hatch=HATCH_BOTH_IMPROVE)

	# 2. Indy improvement but crowd worse top
	indy_plus_crowd_minus_bottom_boundary = np.minimum(max_abs_c_minus_h, crowd_zero_beta_minus_1)
	indy_plus_crowd_minus_top_bounday = np.minimum(max_abs_c_minus_h, indy_zero_beta_minus)
	plt.fill_between(e2s, indy_plus_crowd_minus_top_bounday, indy_plus_crowd_minus_bottom_boundary, color=COLOR_INDY_IMPROVE_CROWD_WORSE, alpha=1, hatch=HATCH_INDY_IMPROVE_CROWD_WORSE)

	# 3. Crowd and worse top
	both_worse_bottom_boundary = np.minimum(max_abs_c_minus_h, indy_zero_beta_minus)
	both_worse_top_boundary = max_abs_c_minus_h
	plt.fill_between(e2s, both_worse_top_boundary, both_worse_bottom_boundary, color=COLOR_BOTH_WORSE, alpha=0.8, hatch=HATCH_BOTH_WORSE)

	# 4. Indy improvement but crowd worse bottom
	below_indy_plus_crowd_minus_top_bounday = crowd_zero_beta_1
	below_indy_plus_crowd_minus_bottom_boundary = np.maximum(-max_abs_c_minus_h, indy_zero_beta_plus)
	plt.fill_between(e2s, below_indy_plus_crowd_minus_top_bounday, below_indy_plus_crowd_minus_bottom_boundary, color=COLOR_INDY_IMPROVE_CROWD_WORSE, alpha=1, hatch=HATCH_INDY_IMPROVE_CROWD_WORSE)

	# 5. Crowd and worse bottom
	bottom_both_worse_top_boundary = np.maximum(-max_abs_c_minus_h, indy_zero_beta_plus)
	bottom_both_worse_bottom_boundary = -max_abs_c_minus_h
	plt.fill_between(e2s, bottom_both_worse_top_boundary, bottom_both_worse_bottom_boundary, color=COLOR_BOTH_WORSE, alpha=0.8, hatch=HATCH_BOTH_WORSE)

	# Set crowd_zeros to nan if greater than max_abs
	crowd_zero_beta_minus_1 = np.where(crowd_zero_beta_minus_1 > max_abs_c_minus_h, np.nan, crowd_zero_beta_minus_1)
	crowd_zero_beta_1 = np.where(crowd_zero_beta_1 > max_abs_c_minus_h, np.nan, crowd_zero_beta_1)
	to_truth_beta_zero = np.where(to_truth_beta_zero > max_abs_c_minus_h, np.nan, to_truth_beta_zero)

	plt.plot(e2s, crowd_zero_beta_1, label="Crowd Zero Beta 1", color=CROWD_ZERO_COLOR, linestyle=CROWD_ZERO_STYLE, linewidth=CROWD_ZERO_WIDTH)
	plt.plot(e2s, crowd_zero_beta_minus_1, label="Crowd Zero Beta -1", color=CROWD_ZERO_COLOR, linestyle=CROWD_ZERO_STYLE, linewidth=CROWD_ZERO_WIDTH)

	indy_zero_beta_minus = np.where(indy_zero_beta_minus > max_abs_c_minus_h, np.nan, indy_zero_beta_minus)
	indy_zero_beta_plus = np.where(indy_zero_beta_plus < -max_abs_c_minus_h, np.nan, indy_zero_beta_plus)

	plt.plot(e2s, indy_zero_beta_minus, label="Indy Zero Beta -", color=INDY_ZERO_COLOR, linestyle=INDY_ZERO_STYLE, linewidth=INDY_ZERO_WIDTH)
	plt.plot(e2s, indy_zero_beta_plus, label="Indy Zero Beta +", color=INDY_ZERO_COLOR, linestyle=INDY_ZERO_STYLE, linewidth=INDY_ZERO_WIDTH)

	plt.plot(e2s, max_abs_c_minus_h, color=CROWD_ZERO_COLOR)
	plt.plot(e2s, -max_abs_c_minus_h, color=CROWD_ZERO_COLOR)

	plt.ylim(-2.5, 2.5)

	plt.xlabel(r"Initial Crowd Error, $\bar{e}^2$")

	plt.ylabel(r"Calibration Minus Herding")



	# Add some text

	text_x_index = len(e2s)-20

	"""
	plt.text(
		e2s[text_x_index],
		crowd_improvement_bottom_boundary[text_x_index] +0.2,
		r'Improved Crowd and Individual Accuracy', ha='right', va='center', fontsize=10, color='white'
	)

	plt.text(
		e2s[text_x_index],
		below_indy_plus_crowd_minus_top_bounday[text_x_index] - 0.01,
		r'Reduced Crowd, Improved Individual Accuracy', ha='right', va='top', fontsize=10, color='white'
	)


	plt.text(
		e2s[text_x_index],
		bottom_both_worse_top_boundary[text_x_index] -0.3,
		r'Reduced Crowd and Individual Accuracy', ha='right', va='top', fontsize=10, color='white'
	)
	"""
	

def plot_heatmaps(cvs=[0.5, 3], e2=0.5, std_e=1, std_e2=1, std_d2=1):

	e = np.sqrt(e2)
	z = e/std_e
	
	min_h = -1
	max_h = 1
	min_cal = -1
	max_cal = 1

	n  = 100

	for k,cv in enumerate(cvs):

		hs = np.linspace(min_h,max_h,n)
		cals = np.linspace(min_cal,max_cal,n)
		delta_error_crowd = np.zeros((len(cals), len(hs)))
		delta_error_indy = np.zeros((len(cals), len(hs)))

	
		for i, h in enumerate(hs):
			for j, cal in enumerate(cals):

				cal_minus_h = cal-h

				abs_max_cal_minus_h = np.abs(2 * e * std_e)

				if np.abs(cal_minus_h) < abs_max_cal_minus_h:		

					delta_error_crowd[j, i] = get_asymptotic_change_in_crowd_error_w_h(cv, cal, h, z, std_e2, std_d2, std_e)   
					delta_error_indy[j, i] = get_asymptotic_change_in_indy_error_w_h(cv, cal, h, z, std_e2, std_d2, std_e) 

				else:
					
					delta_error_crowd[j, i] = np.nan 
					delta_error_indy[j, i] = np.nan

		plt.subplot(2, 3, (3*k)+1)

		divnorm = mcolors.TwoSlopeNorm(vmin=np.nanmin(delta_error_indy), vcenter=0, vmax=np.nanmax(delta_error_crowd))
		
		cmap = mcolors.LinearSegmentedColormap.from_list('custom_seismic', 
										["#2980b9", "#3498db", 'white', "#e74c3c", "#c0392b"], 
										N=256)

		plt.imshow(delta_error_crowd, norm=divnorm, cmap=cmap, 
				interpolation='nearest', aspect='auto', origin='lower', 
					extent=[min_h, max_h, min_cal, max_cal])

		beta_crowd_1 = 0
		beta_crowd_2 = -4*z**2

		cal_boundary_1 = 1/std_e2 *(std_d2 * hs - beta_crowd_1*std_e**2/cv)
		plt.plot(hs, cal_boundary_1, color=CROWD_ZERO_COLOR, linewidth=CROWD_ZERO_WIDTH, linestyle=CROWD_ZERO_STYLE)  # Use a contrasting color

		cal_boundary_2 = 1/std_e2 *(std_d2 * hs - beta_crowd_2*std_e**2/cv)
		plt.plot(hs, cal_boundary_2, color=CROWD_ZERO_COLOR, linewidth=CROWD_ZERO_WIDTH, linestyle=CROWD_ZERO_STYLE)  # Use a contrasting color
			
		plt.xlim(min_h, max_h)
		plt.ylim(min_cal, max_cal)


		plt.ylabel(r"Calibration, $- r(v, e^2)$")

		plt.xlabel(r"Herding, $- r(v, d^2)$")

		if k == 0:
			plt.title(r"$\Delta$ Group Error, $\bar{e}^2 = $" + str(e2))

		plt.subplot(2, 3, (3*k)+2)
		plt.imshow(delta_error_indy, norm=divnorm, cmap=cmap, 
				interpolation='nearest', aspect='auto', origin='lower', 
					extent=[min_h, max_h, min_cal, max_cal])

		beta_indy_1 = -2*z**2 - 2 * z**2 * np.sqrt(1 + 1/(z**2))
		beta_indy_2 = -2*z**2 + 2 * z**2 * np.sqrt(1 + 1/(z**2))

		cal_boundary_1 = 1/std_e2 *(std_d2 * hs - beta_indy_1*std_e**2/cv)
		plt.plot(hs, cal_boundary_1, color=INDY_ZERO_COLOR, linewidth=INDY_ZERO_WIDTH, linestyle=INDY_ZERO_STYLE)  # Use a contrasting color

		cal_boundary_2 = 1/std_e2 *(std_d2 * hs - beta_indy_2*std_e**2/cv)
		plt.plot(hs, cal_boundary_2, color=INDY_ZERO_COLOR, linewidth=INDY_ZERO_WIDTH, linestyle=INDY_ZERO_STYLE)  # Use a contrasting color

		plt.xlim(min_h, max_h)
		plt.ylim(min_cal, max_cal)

		plt.ylabel(r"Calibration, $- r(v, e^2)$")

		plt.xlabel(r"Herding, $- r(v, d^2)$")

		if k == 0:
			plt.title(r"$\Delta$ Individual Error, $\bar{e}^2 = $" + str(e2))


	return cmap, divnorm

	



def plot_figure_1():

	fig = plt.figure(figsize=(12,8))

	cvs = [0.5, 1.5]
	std_e = 1
	e2 = 0.5
	
	cmap, divnorm = plot_heatmaps(cvs=cvs, std_e=std_e, e2=e2)

	plt.subplot(2,3,3)

	plot_error_beta_areas(cv=cvs[0], std_e=std_e)

	
	plt.subplot(2,3,6)
	
	plot_error_beta_areas(cv=cvs[1], std_e=std_e)


	axs = fig.get_axes()

	axs[0].set_aspect('equal')
	axs[1].set_aspect('equal')
	axs[2].set_aspect('equal')
	
	axs[2].set_aspect('equal')
	axs[3].set_aspect('equal')



	

	plt.tight_layout()
	plt.subplots_adjust(top=0.8, left=0.15)  # Make space at the top

	# Create a new axes for the colorbar at the top
	cbar_ax = fig.add_axes([0.15, 0.9, 0.4, 0.03])  # [left, bottom, width, height]

	# Create the colorbar using the same normalization as the plots
	sm = plt.cm.ScalarMappable(cmap=cmap, norm=divnorm)
	sm.set_array([])

	# Add the colorbar to the new axes
	cbar = fig.colorbar(sm, cax=cbar_ax, orientation='horizontal')
	
	fig.text(0.02, 0.65, f"Low Centralisation, c$_v$ = {cvs[0]}", rotation=90, va='center', ha='center', fontweight='bold')
	
	# For the second row (cv = 2)
	fig.text(0.02, 0.25, f"HIgh Centralisation, c$_v$ = {cvs[1]}", rotation=90, va='center', ha='center', fontweight='bold')
	


	plt.savefig("images/fig_1_colors_{}.png".format(COLOR_SCHEME), dpi=600)

	plt.show()
	
if __name__ == "__main__":
	plot_figure_1()


	

