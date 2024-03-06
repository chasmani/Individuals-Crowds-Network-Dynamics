
import numpy as np
import matplotlib.pyplot as plt

from degroot import get_change_in_crowd_error_asymptotic_standardised_analytic_expanded

cv= 0.5
z = 1

cor_v_e2s = np.linspace(-1,1,200)
cor_v_d2s = np.linspace(-1,1,100)

def get_change_in_error_squared(cor_ve2, cor_vd2, CV, mean_e):

	A = CV**2/(4*mean_e**2)
	B = cor_ve2 - cor_vd2
	C = CV * cor_ve2 - CV * cor_vd2
	
	return A*(B**2) + C - 1




delta_error_squared = np.zeros((len(cor_v_e2s), len(cor_v_d2s)))

for i, cor_ve2 in enumerate(cor_v_e2s):
	for j, cor_vd2 in enumerate(cor_v_d2s):
		
		delta_error_squared[i, j] = get_change_in_error_squared(cor_ve2, cor_vd2, cv, z)
		
plt.imshow(delta_error_squared, cmap='seismic', interpolation='nearest', aspect='auto', origin='lower')
plt.xlabel("Herding --- Heterdoxy (correlation(v, d2)")
plt.ylabel("Accuracy --- Inaccuracy (correlation(v, e2)")

plt.show()