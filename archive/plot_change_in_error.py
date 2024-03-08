import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

from degroot import (
	get_change_in_crowd_error_asymptotic_standardised,
	get_change_in_indy_error_asymptotic_standardised
)

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




def heatmap_standarised_general():

	x_name = "CV"
	y_name = "Correlation"
	z_name = "z"

	x_range = np.linspace(0,1,100)
	y_range = np.linspace(-1,1,100)
	z_range = [0, 0.25, 1]

	fig = plt.figure(figsize=(10,5))

	n_rows = 2
	n_cols = len(z_range)

	n_x = len(x_range)
	n_y = len(y_range)
	n_z = len(z_range)

	for k in range(n_z):
		z = z_range[k]
		delta_error_crowd = np.zeros((n_y, n_x))
		delta_error_indy = np.zeros((n_y, n_x))

		for i in range(n_x):
			for j in range(n_y):
				if x_name == "CV":
					cv = x_range[i]
				elif x_name == "Correlation":
					cor = x_range[i]
				elif x_name == "z":
					z = x_range[i]
				else:
					raise ValueError("x_name not recognised")

				if y_name == "CV":
					cv = y_range[j]
				elif y_name == "Correlation":
					cor = y_range[j]
				elif y_name == "z":
					z = y_range[j]
				else:
					raise ValueError("y_name not recognised")

				if z_name == "CV":
					cv = z_range[k]
				elif z_name == "Correlation":
					cor = z_range[k]
				elif z_name == "z":
					z = z_range[k]
				else:
					raise ValueError("z_name not recognised")

				delta_error_crowd[j, i] = get_change_in_crowd_error_asymptotic_standardised(cv, cor, z)
				delta_error_indy[j, i] = get_change_in_indy_error_asymptotic_standardised(cv, cor, z)


		extent=[x_range.min(), x_range.max(), y_range.min(), y_range.max()]



		divnorm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)


		plt.subplot(n_rows, n_cols, k+1)
		plt.imshow(delta_error_crowd, cmap='seismic', norm=divnorm, interpolation='nearest', aspect='auto', origin='lower', extent=extent)
		plt.title("{} = {}".format(z_name, z_range[k]))
		plt.xlabel(x_name)
		if k == 0:
			plt.ylabel(y_name)
		if k == 1:
			plt.title("Change in Crowd Error\n{} = {}".format(z_name, z_range[k]))

		plt.subplot(n_rows, n_cols, k+1+n_cols)
		plt.imshow(delta_error_indy, cmap='seismic', norm=divnorm, interpolation='nearest', aspect='auto', origin='lower', extent=extent)
		plt.title("{} = {}".format(z_name, z_range[k]))
		plt.xlabel(x_name)
		if k == 0:
			plt.ylabel(y_name)
		if k == 1:
			plt.title("Change in Individual Error\n{} = {}".format(z_name, z_range[k]))

	plt.tight_layout()

	# Show color bar
	# Show shared colorbar
	fig.subplots_adjust(right=0.8)
	cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
	sm = plt.cm.ScalarMappable(cmap='seismic', norm=divnorm)
	sm.set_array([])
	fig.colorbar(sm, cax=cbar_ax)
	
	plt.savefig("images/heatmaps_asymptotic_x_{}_y_{}_z_{}.png".format(x_name, y_name, z_name), dpi=600)

	plt.show()

if __name__=="__main__":
	heatmap_standarised_general()