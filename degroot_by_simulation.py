"""
DeGroot by simulation
"""

import numpy as np

def generate_random_opinions_lognormal(n, mu, sd):
	return np.random.lognormal(mean=mu, sigma=sd, size=n)

def generate_random_trust_matrix(n):
	unnomralised_trust_matrix = np.random.rand(n, n)
	trust_matrix = unnomralised_trust_matrix / unnomralised_trust_matrix.sum(axis=1)[:, None]
	return trust_matrix

def get_next_opinion_i_manual(i, opinions, trust_matrix):
	"""
	The simplest way to calculate the next opinion of agent i
	"""
	opinion = 0
	for j in range(len(opinions)):
		opinion += trust_matrix[i][j] * opinions[j]
	return opinion

def get_next_opinions(opinions, trust_matrix):
	return np.matmul(trust_matrix, opinions)

def test_next_opinions():

	n = 10
	opinions = generate_random_opinions_lognormal(n, 0, 1)
	trust_matrix = generate_random_trust_matrix(n)

	next_opinions = get_next_opinions(opinions, trust_matrix)
	for i in range(n):
		next_opinion_i = get_next_opinion_i_manual(i, opinions, trust_matrix)

		if np.isclose(next_opinions[i], next_opinion_i):
			print("Test passed")
		else:
			print("Test failed")

def get_opinions_at_time_t_manual(opinions, trust_matrix, t):
	opinions_t = opinions
	for i in range(t):
		opinions_t = get_next_opinions(opinions_t, trust_matrix)
	return opinions_t

def get_opinions_at_time_t(opinions, trust_matrix, t):
	trust_matrix_t = np.linalg.matrix_power(trust_matrix, t)
	return np.matmul(trust_matrix_t, opinions)

def test_get_opinions_at_time_t():
	n = 10
	opinions = generate_random_opinions_lognormal(n, 0, 1)
	trust_matrix = generate_random_trust_matrix(n)
	t = 5
	opinions_t = get_opinions_at_time_t(opinions, trust_matrix, t)
	opinions_t_manual = get_opinions_at_time_t_manual(opinions, trust_matrix, t)

	for i in range(n):
		# Assert almost equal
		if np.isclose(opinions_t[i], opinions_t_manual[i]):
			print("Test passed")
		else:
			print("Test failed")

		
def get_asymptotic_beliefs_manual(opinions, trust_matrix):
	"""
	The simplest way to calculate the asymptotic beliefs vector
	"""
	return get_opinions_at_time_t(opinions, trust_matrix, 1000)

def get_eigenvector_influence(trust_matrix):

	eigenvalues, eigenvectors = np.linalg.eig(np.transpose(trust_matrix))
	idx = eigenvalues.argsort()[::-1]   
	eigenvectors = eigenvectors[:,idx]
	eigenweights = eigenvectors[:,0]/sum(eigenvectors[:,0])
	return np.real(eigenweights)

def get_asymptotic_belief(opinions, trust_matrix):
	"""
	Using the leading eigenvectors to calculate the asymptotic belief
	"""
	# GEt jsut the real part of the eigenweights
	eigenweights = get_eigenvector_influence(trust_matrix)
	return np.dot(eigenweights, opinions)

def test_asymptotic_beliefs():
	n = 10
	opinions = generate_random_opinions_lognormal(n, 0, 1)
	trust_matrix = generate_random_trust_matrix(n)
	asymptotic_belief = get_asymptotic_belief(opinions, trust_matrix)
	asymptotic_beliefs_manual = get_asymptotic_beliefs_manual(opinions, trust_matrix)

	for j in range(n):
		# Assert almost equal
		if np.isclose(asymptotic_belief, asymptotic_beliefs_manual[j]):
			print("Test passed")
		else:
			print("Test failed")


if __name__=="__main__":
	test_asymptotic_beliefs()