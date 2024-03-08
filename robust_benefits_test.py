import unittest
import numpy as np

import robust_benefits
import robust_benefits_sim

def get_eigenweights(W):
	eigenvectors = np.linalg.eig(np.transpose(W))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_eigenvector = leading_eigenvector/sum(leading_eigenvector)
	return np.real(normalised_eigenvector)

class TestCrowdErrorAsymptotic(unittest.TestCase):

	def test_crowd_error_asymptotic_simple(self):
		"""
		The actual test.
		Any method which starts with ``test_`` will considered as a test case.
		"""
		for seed in range(10):
			np.random.seed(seed)
			

			opinions = np.array([1,2])
			W = np.array([
				[0.5,0.5],
				[0.5, 0.5]])
			truth = 1
			# Run the simulation
			sim_asym_change_crowd_error_stnd = robust_benefits_sim.sim_asymptotic_change_in_crowd_error_standardised(opinions, W, truth)

			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]
			z = np.mean(e)/np.std(e)  

			# Run the function
			func_asym_change_crowd_error_stnd = robust_benefits.get_asymptotic_change_in_crowd_error_standardised(CV_v, cor_v_e, z)

			assert np.isclose(sim_asym_change_crowd_error_stnd, func_asym_change_crowd_error_stnd)
			

	def test_crowd_error_asymptotic_random(self):
		"""
		The actual test.
		Any method which starts with ``test_`` will considered as a test case.
		"""
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
			sim_asym_change_crowd_error_stnd = robust_benefits_sim.sim_asymptotic_change_in_crowd_error_standardised(opinions, W, truth)
			
			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]
			z = np.mean(e)/np.std(e)  

			# Run the function
			func_asym_change_crowd_error_stnd = robust_benefits.get_asymptotic_change_in_crowd_error_standardised(CV_v, cor_v_e, z)
			assert np.isclose(sim_asym_change_crowd_error_stnd, func_asym_change_crowd_error_stnd)
			

class TestIndyErrorAsymptotic(unittest.TestCase):

	def test_cindy_error_asymptotic_simple(self):
		"""
		The actual test.
		Any method which starts with ``test_`` will considered as a test case.
		"""
		for seed in range(10):
			np.random.seed(seed)

			opinions = np.array([1,2])
			W = np.array([
				[0.5,0.5],
				[0.5, 0.5]])
			truth = 1
			# Run the simulation
			sim_asym_change_indy_error_stnd = robust_benefits_sim.sim_asymptotic_change_in_individual_error_standardised(opinions, W, truth)

			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]
			z = np.mean(e)/np.std(e)  

			# Run the function
			func_asym_change_indy_error_stnd = robust_benefits.get_asymptotic_change_in_individual_error_standardised(CV_v, cor_v_e, z)

			assert np.isclose(sim_asym_change_indy_error_stnd, func_asym_change_indy_error_stnd)
			

	def test_indy_error_asymptotic_random(self):
		"""
		The actual test.
		Any method which starts with ``test_`` will considered as a test case.
		"""
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
			sim_asym_change_indy_error_stnd = robust_benefits_sim.sim_asymptotic_change_in_individual_error_standardised(opinions, W, truth)

			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			cor_v_e = np.corrcoef(v, e)[0,1]
			z = np.mean(e)/np.std(e)  

			# Run the function
			func_asym_change_indy_error_stnd = robust_benefits.get_asymptotic_change_in_individual_error_standardised(CV_v, cor_v_e, z)

			assert np.isclose(sim_asym_change_indy_error_stnd, func_asym_change_indy_error_stnd)


class TestCrowdErrorAsymptoticExpanded(unittest.TestCase):

	def test_crowd_error_asymptotic_simple_expanded(self):
		"""
		The actual test.
		Any method which starts with ``test_`` will considered as a test case.
		"""
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
			sim_asym_change_crowd_error_stnd = robust_benefits_sim.sim_asymptotic_change_in_crowd_error_standardised(opinions, W, truth)
			
			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			e_2 = (opinions - truth)**2
			d_2 = (opinions - np.mean(opinions))**2
			cor_v_e_2 = np.corrcoef(v, e_2)[0,1]
			cor_v_d_2 = np.corrcoef(v, d_2)[0,1]
			mean_e = np.mean(e)

			std_e2 = np.std(e_2)
			std_d2 = np.std(d_2)
			
			# Run the function
			func_asym_change_crowd_error_stnd = robust_benefits.get_asymptotic_change_in_crowd_error_expanded(
				CV_v, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2)

			std_e = np.std(e)

			sim_asym_change_crowd_error = sim_asym_change_crowd_error_stnd * std_e**2

			assert np.isclose(sim_asym_change_crowd_error, func_asym_change_crowd_error_stnd)


class TestIndyErrorAsymptoticExpanded(unittest.TestCase):

	def test_indy_error_asymptotic_expanded(self):
		
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
			sim_asym_change_indy_error_stnd = robust_benefits_sim.sim_asymptotic_change_in_individual_error_standardised(opinions, W, truth)

			v = get_eigenweights(W)
			CV_v = np.std(v)/np.mean(v)

			e = opinions - truth
			e_2 = (opinions - truth)**2
			d_2 = (opinions - np.mean(opinions))**2
			cor_v_e_2 = np.corrcoef(v, e_2)[0,1]
			cor_v_d_2 = np.corrcoef(v, d_2)[0,1]
			mean_e = np.mean(e)

			std_e2 = np.std(e_2)
			std_d2 = np.std(d_2)

			std_e = np.std(e)
			
			sim_asym_change_indy_error = sim_asym_change_indy_error_stnd * std_e**2

			
			# Run the function
			func_asym_change_indy_error = robust_benefits.get_asymptotic_change_in_individual_error_expanded(
				CV_v, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2, std_e)


			

			assert np.isclose(sim_asym_change_indy_error, func_asym_change_indy_error)




if __name__ == '__main__':
	unittest.main()