import unittest
import numpy as np

import theoretical_code, sim_code

def get_eigenweights(W):
	eigenvectors = np.linalg.eig(np.transpose(W))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_eigenvector = leading_eigenvector/sum(leading_eigenvector)
	return np.real(normalised_eigenvector)


class TestChangeIndividualError(unittest.TestCase):

	def test_change_individual_error(self):

		for seed in range(10):
			np.random.seed(seed)
			initial_opinions = np.random.rand(100)
			final_opinions = np.random.rand(100)

			truth = np.random.rand()

			initial_empirical_variance = np.var(initial_opinions)
			final_empirical_variance = np.var(final_opinions)
			change_in_empirical_variance = final_empirical_variance - initial_empirical_variance

			initial_individual_error = np.mean((initial_opinions - truth)**2)
			final_individual_error = np.mean((final_opinions - truth)**2)
			change_in_individual_error = final_individual_error - initial_individual_error

			initial_crowd_error = (np.mean(initial_opinions) - truth)**2
			final_crowd_error = (np.mean(final_opinions) - truth)**2
			change_in_crowd_error = final_crowd_error - initial_crowd_error


			# Run the function
			func_change_individual_error = theoretical_code.get_equation_1_change_in_individual_error(
				change_in_crowd_error, change_in_empirical_variance)
			
			# Test
			assert np.isclose(change_in_individual_error, func_change_individual_error)


class TestStandardisedChangeCrowdOpinion(unittest.TestCase):

	def test_standardised_change_crowd_opinion_asymptotic(self):
		for seed in range(10):
			np.random.seed(seed)

			n = 100
			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()
			# Run the simulation
			sim_change_in_crowd_bias = sim_code.sim_change_in_crowd_bias_standardised(opinions, W, truth, steps=1000)
			
			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]

			# Run the function
			func_change_in_crowd_bias = theoretical_code.get_equation_2_standardised_change_in_crowd_opinion(CV_v, cor_v_e)
			# Test
			assert np.isclose(sim_change_in_crowd_bias, func_change_in_crowd_bias)

	def test_standardised_change_crowd_opinion_one_step(self):
		for seed in range(10):
			np.random.seed(seed)

			n = 100
			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()
			# Run the simulation
			sim_change_in_crowd_bias = sim_code.sim_change_in_crowd_bias_standardised(opinions, W, truth, steps=1)
			
			# Get outweights
			v = W.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]

			# Run the function
			func_change_in_crowd_bias = theoretical_code.get_equation_2_standardised_change_in_crowd_opinion(CV_v, cor_v_e)
			# Test
			assert np.isclose(sim_change_in_crowd_bias, func_change_in_crowd_bias)

	def test_standardised_change_crowd_opinion_k_steps(self):
		for seed in range(10):
			np.random.seed(seed)

			k = np.random.randint(1, 100)

			n = 100
			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()
			# Run the simulation
			sim_change_in_crowd_bias = sim_code.sim_change_in_crowd_bias_standardised(opinions, W, truth, steps=k)
			
			# K-step weights
			W_k = np.linalg.matrix_power(W, k)

			# Get outweights
			v = W_k.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]

			# Run the function
			func_change_in_crowd_bias = theoretical_code.get_equation_2_standardised_change_in_crowd_opinion(CV_v, cor_v_e)
			# Test
			assert np.isclose(sim_change_in_crowd_bias, func_change_in_crowd_bias)


class TestCrowdBeta(unittest.TestCase):

	def test_crowd_beta_asymptotic(self):

		for seed in range(10):
			np.random.seed(seed)

			n = 100

			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()

			initial_crowd_bias = np.mean(opinions) - truth

			# Run the simulation
			sim_final_crowd_bias = sim_code.sim_final_crowd_bias(opinions, W, truth, steps=1000)

			sim_beta = sim_final_crowd_bias/initial_crowd_bias

			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e2 = (opinions - truth)**2

			d2 = (opinions - np.mean(opinions))**2

			sd_e2 = np.std(e2)
			sd_d2 = np.std(d2)

			cor_v_e2 = np.corrcoef(v, e2)[0,1]
			cor_v_d2 = np.corrcoef(v, d2)[0,1]

			calibration = - cor_v_e2
			herding = - cor_v_d2

			# Run the function
			func_beta = theoretical_code.get_equation_4_crowd_beta(CV_v, initial_crowd_bias, sd_d2, herding, sd_e2, calibration)
			# Test
			assert np.isclose(sim_beta, func_beta)

	def test_crowd_beta_one_step(self):

		for seed in range(10):
			np.random.seed(seed)

			n = 100

			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()

			initial_crowd_bias = np.mean(opinions) - truth

			# Run the simulation
			sim_final_crowd_bias = sim_code.sim_final_crowd_bias(opinions, W, truth, steps=1)

			sim_beta = sim_final_crowd_bias/initial_crowd_bias

			# Get outweights
			v = W.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e2 = (opinions - truth)**2

			d2 = (opinions - np.mean(opinions))**2

			sd_e2 = np.std(e2)
			sd_d2 = np.std(d2)

			cor_v_e2 = np.corrcoef(v, e2)[0,1]
			cor_v_d2 = np.corrcoef(v, d2)[0,1]

			calibration = - cor_v_e2
			herding = - cor_v_d2

			# Run the function
			func_beta = theoretical_code.get_equation_4_crowd_beta(CV_v, initial_crowd_bias, sd_d2, herding, sd_e2, calibration)
			# Test
			assert np.isclose(sim_beta, func_beta)

	def test_crowd_beta_k_steps(self):

		for seed in range(10):
			np.random.seed(seed)

			n = 100

			k = np.random.randint(1, 100)

			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()

			initial_crowd_bias = np.mean(opinions) - truth

			# Run the simulation
			sim_final_crowd_bias = sim_code.sim_final_crowd_bias(opinions, W, truth, steps=k)

			sim_beta = sim_final_crowd_bias/initial_crowd_bias

			W_k = np.linalg.matrix_power(W, k)

			# Get outweights
			v = W_k.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e2 = (opinions - truth)**2

			d2 = (opinions - np.mean(opinions))**2

			sd_e2 = np.std(e2)
			sd_d2 = np.std(d2)

			cor_v_e2 = np.corrcoef(v, e2)[0,1]
			cor_v_d2 = np.corrcoef(v, d2)[0,1]

			calibration = - cor_v_e2
			herding = - cor_v_d2

			# Run the function
			func_beta = theoretical_code.get_equation_4_crowd_beta(CV_v, initial_crowd_bias, sd_d2, herding, sd_e2, calibration)
			# Test
			assert np.isclose(sim_beta, func_beta)


class TestChangeCrowdBias(unittest.TestCase):

	def test_change_crowd_bias_k_step(self):

		for seed in range(10):
			np.random.seed(seed)

			n = 100

			k = np.random.randint(1, 1000)

			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()

			initial_crowd_bias = np.mean(opinions) - truth

			sd_e = np.std(opinions)

			# Run the simulation
			sim_change_in_crowd_bias = sim_code.sim_change_in_crowd_bias_standardised(opinions, W, truth, steps=k) * sd_e

			W_k = np.linalg.matrix_power(W, k)

			# Get outweights
			v = W_k.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e2 = (opinions - truth)**2

			d2 = (opinions - np.mean(opinions))**2

			sd_e2 = np.std(e2)
			sd_d2 = np.std(d2)

			cor_v_e2 = np.corrcoef(v, e2)[0,1]
			cor_v_d2 = np.corrcoef(v, d2)[0,1]

			calibration = - cor_v_e2
			herding = - cor_v_d2

			# Run the function
			func_change_in_crowd_beta = theoretical_code.get_equation_4_crowd_beta(CV_v, initial_crowd_bias, sd_d2, herding, sd_e2, calibration)
			
			func_change_in_crowd_bias_via_beta = theoretical_code.get_change_in_crowd_bias_via_beta(initial_crowd_bias, func_change_in_crowd_beta)

			
			# Test
			assert np.isclose(sim_change_in_crowd_bias, func_change_in_crowd_bias_via_beta)


class TestChangeCrowdError(unittest.TestCase):

	def test_change_crowd_error_k_step(self):

		for seed in range(10):
			np.random.seed(seed)

			n = 100

			k = np.random.randint(1, 1000)

			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()

			initial_crowd_bias = np.mean(opinions) - truth

			sd_e = np.std(opinions)

			# Run the simulation
			sim_change_in_crowd_error = sim_code.sim_change_in_crowd_error_standardised(opinions, W, truth, steps=k) * sd_e**2

			W_k = np.linalg.matrix_power(W, k)

			# Get outweights
			v = W_k.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e2 = (opinions - truth)**2

			d2 = (opinions - np.mean(opinions))**2

			sd_e2 = np.std(e2)
			sd_d2 = np.std(d2)

			cor_v_e2 = np.corrcoef(v, e2)[0,1]
			cor_v_d2 = np.corrcoef(v, d2)[0,1]

			calibration = - cor_v_e2
			herding = - cor_v_d2

			# Run the function
			func_change_in_crowd_beta = theoretical_code.get_equation_4_crowd_beta(CV_v, initial_crowd_bias, sd_d2, herding, sd_e2, calibration)
			func_change_in_crowd_error_via_beta = theoretical_code.get_change_in_crowd_error_via_beta(initial_crowd_bias, func_change_in_crowd_beta)

			# Test
			assert np.isclose(sim_change_in_crowd_error, func_change_in_crowd_error_via_beta)


class TestChangeIndyError(unittest.TestCase):

	def test_change_indy_error_k_step(self):

		for seed in range(10):
			np.random.seed(seed)

			n = 100

			k = np.random.randint(1, 1000)

			# Random opinions
			opinions = np.random.rand(n)
			# Random influnce network
			W = np.random.rand(n,n)
			# Standardise the influence network
			W = W/W.sum(axis=1)[:,None]
			# Random truth
			truth = np.random.rand()

			initial_crowd_bias = np.mean(opinions) - truth

			sd_e = np.std(opinions)

			# Run the simulation
			sim_change_in_indy_error = sim_code.sim_change_in_individual_error_standardised(opinions, W, truth, steps=k) * sd_e**2

			sim_final_opinions = sim_code.sim_get_final_opinions(opinions, W, steps=k)
			final_sd_e = np.std(sim_final_opinions)
			change_in_opinion_variance = final_sd_e**2 - sd_e**2

			W_k = np.linalg.matrix_power(W, k)

			# Get outweights
			v = W_k.sum(axis=0)
			# Normalise outweights
			v = v/v.sum()

			CV_v = np.std(v)/np.mean(v)

			e2 = (opinions - truth)**2

			d2 = (opinions - np.mean(opinions))**2

			sd_e2 = np.std(e2)
			sd_d2 = np.std(d2)

			cor_v_e2 = np.corrcoef(v, e2)[0,1]
			cor_v_d2 = np.corrcoef(v, d2)[0,1]

			calibration = - cor_v_e2
			herding = - cor_v_d2

			# Run the function
			func_change_in_crowd_beta = theoretical_code.get_equation_4_crowd_beta(CV_v, initial_crowd_bias, sd_d2, herding, sd_e2, calibration)
			func_change_in_indy_error_via_beta = theoretical_code.get_change_in_individual_error_via_beta(initial_crowd_bias, func_change_in_crowd_beta, change_in_opinion_variance)

			# Test
			assert np.isclose(sim_change_in_indy_error, func_change_in_indy_error_via_beta)


if __name__ == '__main__':
	unittest.main()