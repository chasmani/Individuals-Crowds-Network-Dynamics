import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import (
	get_asymptotic_change_in_crowd_error_standardised,
	get_asymptotic_change_in_individual_error_standardised
)

zs = [0, 1, 2]

fig = plt.figure(figsize=(10,6))

min_cv = 0
max_cv = 5
min_cor = -1
max_cor = 1

cbar_range = 10
divnorm = mcolors.SymLogNorm(linthresh=0.01, vmin=-cbar_range, vmax=cbar_range)

cmap = mpl.colormaps.get_cmap('coolwarm')  # viridis is the default colormap for imshow
	
for k, z in enumerate(zs):
	
	cvs = np.linspace(min_cv,max_cv,100)
	cor_ves = np.linspace(min_cor,max_cor,200)
	delta_error_crowd = np.zeros((len(cor_ves), len(cvs)))
	delta_error_indy = np.zeros((len(cor_ves), len(cvs)))

	for i, cv in enumerate(cvs):
		for j, cor_ve in enumerate(cor_ves):
			delta_error_crowd[j, i] = get_asymptotic_change_in_crowd_error_standardised(cv, cor_ve, z)    
			delta_error_indy[j, i] = get_asymptotic_change_in_individual_error_standardised(cv, cor_ve, z)



	plt.subplot(2, 3, k+1)
	plt.imshow(delta_error_crowd, norm=divnorm, cmap=cmap, 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_cv, max_cv, min_cor, max_cor])
	
	"""
	if cv > 0:
		cor_boundary_1 = 0 * zs
		cor_boundary_2 = -2 * zs / cv
		plt.plot(zs, cor_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
		plt.plot(zs, cor_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
	
	"""
	if z > 0:
		for alpha in np.arange(-20, 20, 1):
			cor_alpha_iso = alpha/(cvs * z)
			plt.plot(cvs, cor_alpha_iso, color='white', linewidth=1, linestyle="dashed", alpha=0.5)


	plt.xlim(min_cv, max_cv)
	plt.ylim(min_cor, max_cor)

	
	if k == 0:
		plt.ylabel(r"r(v,e)")

	if k == 1:
		plt.title("z = {}\nChange in Crowd Error".format(z))
	else:
		plt.title("z = {}\n".format(z))

	plt.subplot(2, 3, k+4)
	plt.imshow(delta_error_indy, norm=divnorm, cmap=cmap, 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_cv, max_cv, min_cor, max_cor])
	
	"""
	if cv > 0:
		cor_boundary_1 = np.array([-z + np.sqrt(z**2 + 1) for z in zs])/cv
		cor_boundary_2 = np.array([-z - np.sqrt(z**2 + 1) for z in zs])/cv
		plt.plot(zs, cor_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
		plt.plot(zs, cor_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
	"""

	if z > 0:
		for alpha in np.arange(-20, 20, 1):
			cor_alpha_iso = alpha/(cvs * z)
			plt.plot(cvs, cor_alpha_iso, color='white', linewidth=1, linestyle="dashed", alpha=0.5)


		
	plt.xlim(min_cv, max_cv)
	plt.ylim(min_cor, max_cor)
	

	if k == 0:
		plt.ylabel(r"r(v,e)")

	
	plt.xlabel(r"$c_v$")

	if k == 1:
		plt.title("Change in Individual Error")





plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
sm = plt.cm.ScalarMappable(cmap=cmap, norm=divnorm)
sm.set_array([])
cbar = fig.colorbar(sm, cax=cbar_ax)
from matplotlib.ticker import ScalarFormatter
cbar.ax.yaxis.set_major_formatter(ScalarFormatter())


plt.savefig("images/robust_benefits_by_z.png", dpi=300)


plt.show()
