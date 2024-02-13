
import numpy as np

from degroot_by_simulation import get_asymptotic_change_in_crowd_error_squared

def generate_random_opinions_lognormal(n, mu, sd):
	return np.random.lognormal(mean=mu, sigma=sd, size=n)

def generate_random_trust_matrix(n):
	unnomralised_trust_matrix = np.random.rand(n, n)
	trust_matrix = unnomralised_trust_matrix / unnomralised_trust_matrix.sum(axis=1)[:, None]
	return trust_matrix

def get_change_in_crowd_opinion_t_manual(opinions, trust_matrix, t):
	
	n = len(opinions)
	trust_matrix_t = np.linalg.matrix_power(trust_matrix, t)
	opinions_t = np.matmul(trust_matrix_t, opinions)
	
	crowd_opinion_0 = np.mean(opinions)
	
	crowd_opinion_t = np.mean(opinions_t)

	return crowd_opinion_t - crowd_opinion_0

def get_eigenvector_influence(trust_matrix):

	eigenvectors = np.linalg.eig(np.transpose(trust_matrix))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_leading_eigenvector = np.real(leading_eigenvector/sum(leading_eigenvector))
	return normalised_leading_eigenvector


def get_asymptotic_change_in_crowd_opinion(opinions, trust_matrix):
	
	n = len(opinions)
	eigenweights = get_eigenvector_influence(trust_matrix)
	covariance = np.cov(eigenweights, opinions, bias=True)[0][1]
	return n * covariance 

def test_get_asymptotic_change_in_opinion():

	n = 10
	opinions = generate_random_opinions_lognormal(n, 0, 1)
	trust_matrix = generate_random_trust_matrix(n)
	
	change_in_opinion = get_asymptotic_change_in_crowd_opinion(opinions, trust_matrix)
	
	change_in_opinion_manual = get_change_in_crowd_opinion_t_manual(opinions, trust_matrix, 1000)

	print(change_in_opinion, change_in_opinion_manual)

	if np.isclose(change_in_opinion, change_in_opinion_manual):
		print("Test passed")
	else:
		print("Test failed")

def get_asymptotic_change_in_crowd_error(opinions, trust_matrix, truth):
	
	n = len(opinions)
	eigenweights = get_eigenvector_influence(trust_matrix)
	errors = opinions - truth
	covariance = np.cov(eigenweights, errors, bias=True)[0][1]

	mean_error = np.mean(errors)

	return n**2 * covariance**2 + 2*mean_error*n*covariance


def test_get_asymptotic_change_in_error():

	opinions = generate_random_opinions_lognormal(10, 0, 1)
	trust_matrix = generate_random_trust_matrix(10)

	truth = 1	

	change_in_error = get_asymptotic_change_in_crowd_error(opinions, trust_matrix, truth)
	change_in_error_manual = get_asymptotic_change_in_crowd_error_squared(opinions, trust_matrix, truth)

	print(change_in_error, change_in_error_manual)




if __name__ == "__main__":
	test_get_asymptotic_change_in_error()