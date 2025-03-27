
import numpy as np
import matplotlib.pyplot as plt

def get_indy_zero_beta_plus(e2, cv):
	return -2/cv * (np.sqrt(e2**2 + e2) - e2)

def get_indy_zero_beta_minus(e2, cv):
	return -2/cv * (-np.sqrt(e2**2 + e2) - e2)

def get_max_abs_c_minus_h(e2, s_e):
	
	e_abs = np.sqrt(e2)
	return min(2*e_abs*s_e, 2)

def plot_areas(cv=1):

	n = 1000
	se = 1
	es = np.linspace(0, 1.3, n)
	e2s = es**2

	crowd_zero_beta_1 = np.zeros(n)

	crowd_zero_beta_minus_1 = 4/cv * e2s

	to_truth_beta_zero = 2/cv * e2s

	indy_zero_beta_plus = [get_indy_zero_beta_plus(e2, cv) for e2 in e2s]
	indy_zero_beta_minus = [get_indy_zero_beta_minus(e2, cv) for e2 in e2s]

	max_abs_c_minus_h = np.array([get_max_abs_c_minus_h(e2, se) for e2 in e2s])

	# Area filling
	# 1. Crowd Improvement
	crowd_improvement_top_boundary = np.minimum(max_abs_c_minus_h, crowd_zero_beta_minus_1)
	crowd_improvement_bottom_boundary = crowd_zero_beta_1
	plt.fill_between(e2s, crowd_improvement_top_boundary, crowd_improvement_bottom_boundary, color="#2ecc71", alpha=0.8)

	# 2. Indy improvement but crowd worse top
	indy_plus_crowd_minus_bottom_boundary = np.minimum(max_abs_c_minus_h, crowd_zero_beta_minus_1)
	indy_plus_crowd_minus_top_bounday = np.minimum(max_abs_c_minus_h, indy_zero_beta_minus)
	plt.fill_between(e2s, indy_plus_crowd_minus_top_bounday, indy_plus_crowd_minus_bottom_boundary, color="#f1c40f", alpha=1)

	# 3. Crowd and worse top
	both_worse_bottom_boundary = np.minimum(max_abs_c_minus_h, indy_zero_beta_minus)
	both_worse_top_boundary = max_abs_c_minus_h
	plt.fill_between(e2s, both_worse_top_boundary, both_worse_bottom_boundary, color="#c0392b", alpha=0.8)

	# 4. Indy improvement but crowd worse bottom
	below_indy_plus_crowd_minus_top_bounday = crowd_zero_beta_1
	below_indy_plus_crowd_minus_bottom_boundary = np.maximum(-max_abs_c_minus_h, indy_zero_beta_plus)
	plt.fill_between(e2s, below_indy_plus_crowd_minus_top_bounday, below_indy_plus_crowd_minus_bottom_boundary, color="#f1c40f", alpha=1)

	# 5. Crowd and worse bottom
	bottom_both_worse_top_boundary = np.maximum(-max_abs_c_minus_h, indy_zero_beta_plus)
	bottom_both_worse_bottom_boundary = -max_abs_c_minus_h
	plt.fill_between(e2s, bottom_both_worse_top_boundary, bottom_both_worse_bottom_boundary, color="#c0392b", alpha=0.8)

	# Set crowd_zeros to nan if greater than max_abs
	crowd_zero_beta_minus_1 = np.where(crowd_zero_beta_minus_1 > max_abs_c_minus_h, np.nan, crowd_zero_beta_minus_1)
	crowd_zero_beta_1 = np.where(crowd_zero_beta_1 > max_abs_c_minus_h, np.nan, crowd_zero_beta_1)
	to_truth_beta_zero = np.where(to_truth_beta_zero > max_abs_c_minus_h, np.nan, to_truth_beta_zero)

	BOUNDARY_COLOR = "grey"

	plt.plot(e2s, crowd_zero_beta_1, label="Crowd Zero Beta 1", color=BOUNDARY_COLOR, linestyle="dashed")
	plt.plot(e2s, crowd_zero_beta_minus_1, label="Crowd Zero Beta -1", color=BOUNDARY_COLOR, linestyle="dashed")
	plt.plot(e2s, to_truth_beta_zero, label="To Truth Beta Zero", color=BOUNDARY_COLOR, linestyle="dashed")
	#plt.plot(e2s, indy_zero_beta_plus, label="Indy Zero Beta +", color="red")
	#plt.plot(e2s, indy_zero_beta_minus, label="Indy Zero Beta -", color="grey", linestyle="dotted")

	plt.text(
		max(e2s)+0.05,
		0,
		r'$\beta=1$', ha='left', va='center', fontsize=10, color=BOUNDARY_COLOR
	)
	
	plt.text(
		1.5,
		2.05,
		r'$\beta=0$', ha='left', va='bottom', fontsize=10, color=BOUNDARY_COLOR
	)

	plt.text(
		0.63,
		1.6,
		r'$\beta=-1$', ha='right', va='bottom', fontsize=10, color=BOUNDARY_COLOR
	)



	plt.ylim(-2.5, 2.5)

	plt.xlabel(r"Initial Crowd Error, $\bar{e}^2$")

	plt.ylabel(r"Calibration Minus Herding, $- r(v, e^2) - [-r(v,d^2)]$")

	plt.plot(e2s, max_abs_c_minus_h, label="Max Abs C - H", color="white")
	plt.plot(e2s, -max_abs_c_minus_h, label="Min Abs C - H", color="white")

	# Add some text

	text_x_index = len(e2s)-20

	plt.text(
		e2s[text_x_index],
		crowd_improvement_bottom_boundary[text_x_index] +0.4,
		r'Improved Crowd and Individual Accuracy', ha='right', va='center', fontsize=10, color='white'
	)

	plt.text(
		e2s[text_x_index],
		below_indy_plus_crowd_minus_top_bounday[text_x_index] - 0.15,
		r'Reduced Crowd, Improved Individual Accuracy', ha='right', va='top', fontsize=10, color='white'
	)



	plt.text(
		e2s[text_x_index],
		bottom_both_worse_top_boundary[text_x_index] -0.3,
		r'Reduced Crowd and Individual Accuracy', ha='right', va='top', fontsize=10, color='white'
	)
	
	# Make axes minimal
	plt.gca().spines['top'].set_visible(False)
	plt.gca().spines['right'].set_visible(False)

	plt.savefig("images/single_plot_c_h_e.png", dpi=300)

	plt.show()

def plot_all():

	
	fig, ax = plt.subplots(1, 2, figsize=(12, 6))

	plt.subplot(1, 2, 1)
	plot_areas(cv=1)

	plt.title(r"Less Centralised, $c_v=1$")

	ax = plt.gca()

	ax.annotate("a", xy=(0.05, 0.95), xycoords="axes fraction",
               fontsize=24, fontweight="bold", va="top")

	plt.subplot(1, 2, 2)
	plot_areas(cv=1.5)

	plt.title(r"More Centralised, $c_v=2$")

	ax = plt.gca()

	ax.annotate("b", xy=(0.05, 0.95), xycoords="axes fraction",
               fontsize=24, fontweight="bold", va="top")


	



if __name__ == "__main__":
	plot_areas(1.5)