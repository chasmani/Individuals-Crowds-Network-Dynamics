import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import (
	get_asymptotic_change_in_crowd_error_standardised,
	get_asymptotic_change_in_individual_error_standardised
)

cvs = [0, 0.5, 1]

fig = plt.figure(figsize=(10,6))

min_z = -3
max_z = 3
min_cor = -1
max_cor = 1

divnorm = mcolors.TwoSlopeNorm(vmin=-5, vcenter=0, vmax=5)

for k, cv in enumerate(cvs):
	
	zs = np.linspace(min_z,max_z,100)
	cor_ves = np.linspace(min_cor,max_cor,200)
	delta_error_crowd = np.zeros((len(cor_ves), len(zs)))
	delta_error_indy = np.zeros((len(cor_ves), len(zs)))

	for i, z in enumerate(zs):
		for j, cor_ve in enumerate(cor_ves):
			delta_error_crowd[j, i] = get_asymptotic_change_in_crowd_error_standardised(cv, cor_ve, z)    
			delta_error_indy[j, i] = get_asymptotic_change_in_individual_error_standardised(cv, cor_ve, z)



	plt.subplot(2, 3, k+1)
	plt.imshow(delta_error_crowd, norm=divnorm, cmap='seismic', 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_z, max_z, min_cor, max_cor])
	
	if cv > 0:
		cor_boundary_1 = 0 * zs
		cor_boundary_2 = -2 * zs / cv
		plt.plot(zs, cor_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
		plt.plot(zs, cor_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
	
	plt.xlim(min_z, max_z)
	plt.ylim(min_cor, max_cor)

	
	if k == 0:
		plt.ylabel(r"r(v,e)")

	if k == 1:
		plt.title("Cv = {}\nChange in Crowd Error".format(cv))
	else:
		plt.title("Cv = {}\n".format(cv))

	plt.subplot(2, 3, k+4)
	plt.imshow(delta_error_indy, norm=divnorm, cmap='seismic', 
			   interpolation='nearest', aspect='auto', origin='lower', 
				 extent=[min_z, max_z, min_cor, max_cor])
	
	if cv > 0:
		cor_boundary_1 = np.array([-z + np.sqrt(z**2 + 1) for z in zs])/cv
		cor_boundary_2 = np.array([-z - np.sqrt(z**2 + 1) for z in zs])/cv
		plt.plot(zs, cor_boundary_1, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
		plt.plot(zs, cor_boundary_2, color='#404040', linewidth=2, linestyle="dashed")  # Use a contrasting color
	
	plt.xlim(min_z, max_z)
	plt.ylim(min_cor, max_cor)

	if k == 0:
		plt.ylabel(r"r(v,e)")

	
	plt.xlabel(r"z")

	if k == 1:
		plt.title("Change in Individual Error")





plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
sm = plt.cm.ScalarMappable(cmap='seismic', norm=divnorm)
sm.set_array([])
fig.colorbar(sm, cax=cbar_ax)

plt.savefig("images/robust_benefits.png", dpi=300)


plt.show()
