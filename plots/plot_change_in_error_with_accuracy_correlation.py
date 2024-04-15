
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

import sys
sys.path.append("..")
from robust_benefits import get_asymptotic_change_in_crowd_error_expanded

cv= 0.5
mean_e = 1

cor_v_e2s = np.linspace(-1.5,1.5,200)
cor_v_d2s = np.linspace(-1.5,1.5,100)

std_e2 = 1
std_d2 = 1

delta_error_squared = np.zeros((len(cor_v_e2s), len(cor_v_d2s)))

divnorm = mcolors.TwoSlopeNorm(vmin=-2, vcenter=0, vmax=2)

for i, cor_ve2 in enumerate(cor_v_e2s):
	for j, cor_vd2 in enumerate(cor_v_d2s):
		
		delta_error_squared[i, j] = get_asymptotic_change_in_crowd_error_expanded(cv, cor_ve2, cor_vd2, mean_e, std_e2, std_d2)

fig = plt.figure(figsize=(10,4))

plt.subplot(1, 2, 1)		
plt.imshow(delta_error_squared, norm=divnorm, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower',  extent=[-1.5, 1.5, -1.5, 1.5])
plt.title("Crowd")
plt.xlabel(r"Herding --- Heterdoxy / $s(d^2) cor(v, d^2)$")
plt.ylabel(r"Wisdom --- Foolishness / $s(e^2) cor(v, e^2)$")

plt.subplot(1, 2, 2)		
plt.imshow(delta_error_squared - 1, norm=divnorm, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower',  extent=[-1.5, 1.5, -1.5, 1.5])
plt.title("Individual")
plt.xlabel(r"Herding --- Heterdoxy / $s(d^2) cor(v, d^2)$")

plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
sm = plt.cm.ScalarMappable(cmap='seismic', norm=divnorm)
sm.set_array([])
fig.colorbar(sm, cax=cbar_ax)

plt.savefig("images/herding_vs_wisdom.png", dpi=300)

plt.show()