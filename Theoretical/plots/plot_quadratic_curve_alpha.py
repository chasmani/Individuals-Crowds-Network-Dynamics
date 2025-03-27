
import numpy as np
import matplotlib.pyplot as plt

alphas = np.linspace(-1,1,200)

zs = [0.5, 1, 2]

fig, axs = plt.subplots(1, 3, sharey = True, sharex=True, figsize = (8, 4))

for k, z in enumerate(zs):

	# Set x lims
	c_v = 0.5
	
	alphas = np.linspace(-c_v * z, c_v * z,200)

	change_crowd_error = [1/(z**2) * alpha**2 - alpha for alpha in alphas]
	change_indy_error = [1/(z**2) * alpha**2 - alpha - 1 for alpha in alphas]



	axs[k].plot(alphas, change_crowd_error, label="Crowd", linewidth=3, color="#f39c12")
	axs[k].plot(alphas, change_indy_error, label="Individual", linewidth=3, color="#9b59b6")

	# PLot y = 0 line
	
	# Remove plot boundary lines

	axs[k].spines['top'].set_position('zero')
	# Don't draw lines for bottom and right axes.
	axs[k].spines['bottom'].set_color('none')
	axs[k].spines['right'].set_color('none')
	# Draw ticks on top x axis, and leave labels on bottom.
	axs[k].tick_params(axis='x', bottom=False, top=True, direction='inout')

	"""
	boundary_1 = 0
	boundary_2 = -4*z**2

	boundary_3 = -2*z**2 - np.sqrt(4*z_2 + 4*z_2)
	boundary_4 = -2*z**2 + np.sqrt(4*z_2 + 4*z_2)

	boundary_3 = -2*z**2 - 2 * z_2 * np.sqrt(1 + 1/(z_2))
	boundary_4 = -2*z**2 + 2 * z_2 * np.sqrt(1 + 1/(z_2))
	print(boundary_3, boundary_4)
	"""

	"""
	axs[k].axvline(x=boundary_1, color='#f39c12', linestyle='--', alpha=0.3)
	axs[k].axvline(x=boundary_2, color='#f39c12', linestyle='--', alpha=0.3)

	axs[k].axvline(x=boundary_3, color='#9b59b6', linestyle='--', alpha=0.3)
	axs[k].axvline(x=boundary_4, color='#9b59b6', linestyle='--', alpha=0.3)
	"""
	
	plt.legend()

	axs[k].set_title(r"$z = {}$".format(z))

	axs[k].set_xlabel(r"$\alpha$")
	if k == 0:
		axs[k].set_ylabel(r"Asymptotic Change in Error")

	
	axs[k].set_ylim(min(change_indy_error), max(change_crowd_error))

plt.savefig("images/error_curves_alpha.png", dpi=300)

plt.show()