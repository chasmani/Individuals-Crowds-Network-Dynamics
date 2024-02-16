import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

from degroot import (
	get_change_in_crowd_error_asymptotic_standardised,
	get_change_in_indy_error_asymptotic_standardised
)

"""
Functions are in this form:
def get_change_in_crowd_error_asymptotic_standardised(coeff_variation_v, correlation_eigenweights_errors, mean_error_standardised):
get_change_in_indy_error_asymptotic_standardised(coeff_variation_v, correlation_v_e, mean_error_standardised)
"""

def plot_heatmap_standardised_crowd_asymptotic(z=0.1):

	cors = np.linspace(-1,1,100)
	CCV_e = np.linspace(0,1,100)

	delta_error_squared = np.zeros((len(cors), len(CCV_e)))

	for i, cor in enumerate(cors):
		for j, cv in enumerate(CCV_e):
			delta_error_squared[i, j] = get_change_in_crowd_error_asymptotic_standardised(cv, cor, z)

	print(delta_error_squared.max(), delta_error_squared.min())

	if delta_error_squared.max() <= 0:
		vmax = 1
	else:
		vmax = delta_error_squared.max()
	if delta_error_squared.min() >= 0:
		vmin = -1
	else:
		vmin = delta_error_squared.min()

	divnorm = mcolors.TwoSlopeNorm(vmin=vmin, vcenter=0, vmax=vmax)

	plt.imshow(delta_error_squared, cmap='seismic', norm=divnorm, interpolation='nearest', aspect='auto', extent=[CCV_e.min(), CCV_e.max(), cors.min(), cors.max()], origin='lower')

	plt.title("z={}".format(z))
	

def plot_heatmap_standardised_indy_asymptotic(z=0.1):

	cors = np.linspace(-1,1,100)
	CCV_e = np.linspace(0,1,200)

	delta_error_squared = np.zeros((len(cors), len(CCV_e)))

	for i, cor in enumerate(cors):
		for j, cv in enumerate(CCV_e):
			delta_error_squared[i, j] = get_change_in_indy_error_asymptotic_standardised(cv, cor, z)
			

	print(delta_error_squared.max(), delta_error_squared.min())

	if delta_error_squared.max() <= 0:
		vmax = 1
	else:
		vmax = delta_error_squared.max()
	if delta_error_squared.min() >= 0:
		vmin = -1
	else:
		vmin = delta_error_squared.min()

	divnorm = mcolors.TwoSlopeNorm(vmin=vmin, vcenter=0, vmax=vmax)

	plt.imshow(delta_error_squared, cmap='seismic', norm=divnorm, interpolation='nearest', aspect='auto',  extent=[CCV_e.min(), CCV_e.max(), cors.min(), cors.max()], origin='lower')
	plt.title("z={}".format(z))

def heatmaps_standardised():

	fig = plt.figure(figsize=(10,5))

	n_rows = 2

	zs = [0, 0.3, 1]
	n_cols = len(zs)

	plt.suptitle(r"Change in Asymptotic Standardised Error Squared, $\frac{\Delta e^2}{s_e^2}$. Blue regions are reductions, red regions are increases.")
	for i, z in enumerate(zs):

		plt.subplot(n_rows, n_cols, i+1)
		plot_heatmap_standardised_crowd_asymptotic(z=z)
		if i == 0:
			plt.ylabel('Cor(Influence, Error)')

		if i == 1:
			plt.xlabel(r"Centralisation, Coefficient of Variation in Influence, $CCV_v = \frac{s_v}{\bar{v}}$")
			plt.title("Change in Crowd Error\nz={}".format(z))	

	for i, z in enumerate(zs):

		plt.subplot(n_rows, n_cols, i+1+n_cols)
		plot_heatmap_standardised_indy_asymptotic(z=z)
		if i == 0:
			plt.ylabel('Cor(Influence, Error)')

		if i == 1:
			plt.xlabel(r"Centralisation, Coefficient of Variation in Influence, $CCV_v = \frac{s_v}{\bar{v}}$")
			plt.title("Mean Change in Individual Error\nz={}".format(z))	


	plt.tight_layout()

	plt.savefig("images/heatmaps_standardised_asymptotic.png", dpi=600)
	plt.show()


def plot_heatmap_standardised_crowd_asymptotic(z=0.1):

	cors = np.linspace(-1,1,100)
	CCV_e = np.linspace(0,1,100)

	delta_error_squared = np.zeros((len(cors), len(CCV_e)))

	for i, cor in enumerate(cors):
		for j, cv in enumerate(CCV_e):
			delta_error_squared[i, j] = get_change_in_crowd_error_asymptotic_standardised(cv, cor, z)

	print(delta_error_squared.max(), delta_error_squared.min())

	if delta_error_squared.max() <= 0:
		vmax = 1
	else:
		vmax = delta_error_squared.max()
	if delta_error_squared.min() >= 0:
		vmin = -1
	else:
		vmin = delta_error_squared.min()

	divnorm = mcolors.TwoSlopeNorm(vmin=vmin, vcenter=0, vmax=vmax)

	plt.imshow(delta_error_squared, cmap='seismic', norm=divnorm, interpolation='nearest', aspect='auto', extent=[CCV_e.min(), CCV_e.max(), cors.min(), cors.max()], origin='lower')

	plt.title("z={}".format(z))



if __name__=="__main__":
	heatmaps_standardised()