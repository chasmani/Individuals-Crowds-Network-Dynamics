
import numpy as np

def get_eigenweights(W):
	eigenvectors = np.linalg.eig(np.transpose(W))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_eigenvector = leading_eigenvector/sum(leading_eigenvector)
	return np.real(normalised_eigenvector)

def get_wisdom_and_herding(opinions, truth, W):

	n = len(opinions)

	v = get_eigenweights(W)

	e = opinions - truth
	e_2 = (opinions - truth)**2
	d_2 = (opinions - np.mean(opinions))**2
	
	z = np.mean(e)/np.std(e)

	std_e = np.std(e)

	v = get_eigenweights(W)

	e = opinions - truth
	e_2 = (opinions - truth)**2
	d_2 = (opinions - np.mean(opinions))**2

	cov_v_e2 = np.cov(v, e_2, bias=True)[0,1]
	cov_v_d2 = np.cov(v, d_2, bias=True)[0,1]

	wisdom = - (n * cov_v_e2)/(std_e**2)
	herding = - (n * cov_v_d2)/(std_e**2)

	return wisdom, herding

def test_wisdom_minus_herding():
	
	np.random.seed(1)
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
	
	v = get_eigenweights(W)

	e = opinions - truth
	e_2 = (opinions - truth)**2
	d_2 = (opinions - np.mean(opinions))**2
	
	z = np.mean(e)/np.std(e)

	std_e = np.std(e)

	v = get_eigenweights(W)

	e = opinions - truth
	e_2 = (opinions - truth)**2
	d_2 = (opinions - np.mean(opinions))**2

	cov_v_e2 = np.cov(v, e_2, bias=True)[0,1]
	cov_v_d2 = np.cov(v, d_2, bias=True)[0,1]

	wisdom = - (n * cov_v_e2)/(std_e**2)
	herding = - (n * cov_v_d2)/(std_e**2)
	

	print("W-H",wisdom-herding)

	A = -2*np.mean(e)*n/(std_e**2) * np.cov(v, e, bias=True)[0,1]
	

	assert np.isclose(wisdom-herding, A)

	c_v = np.std(v)/np.mean(v)
	cor_v_e2 = np.corrcoef(v, e_2)[0,1]
	wisdom = -np.std(e_2) / std_e**2 * c_v * cor_v_e2

	cor_v_d2 = np.corrcoef(v, d_2)[0,1]
	herding = -np.std(d_2) / std_e**2 * c_v * cor_v_d2

	assert np.isclose(wisdom-herding, A)

	cor_v_e = np.corrcoef(v, e)[0,1]
	A = -2 * z * c_v * cor_v_e

	assert np.isclose(wisdom-herding, A)

	print(wisdom, herding)
	print(wisdom - herding)
	print(A)

	wisdom, herding = get_wisdom_and_herding(opinions, truth, W)

	assert np.isclose(wisdom-herding, A)

def sim_some_random_stuff():
	
	for i in range(10):
		np.random.seed(i)
		n = 100
		# Random opinions
		opinions = np.random.rand(n)*4 - 10
		# Random influnce network
		W = np.random.rand(n,n)
		# Standardise the influence network
		W = W/W.sum(axis=1)[:,None]

		# Random truth
		truth = np.random.rand()
		# Run the simulation
		wisdom, herding = get_wisdom_and_herding(opinions, truth, W)
		print(wisdom, herding)
		print(wisdom-herding)

	for i in range(10):
		np.random.seed(i)
		print("Seed", i	)
		n = 10
		# Random opinions
		opinions = np.random.rand(n)*4 
		print(opinions)
		print(opinions[0] - truth)
		# Centralised Infliuence Network
		W = np.zeros((n,n))
		W[:,0] = 1
		# Normalise
		W = W/W.sum(axis=1)[:,None]



		
		# Random truth
		truth = np.random.rand()

		z = np.mean(opinions - truth)/np.std(opinions - truth)
		print("Test", (wisdom-herding)/z**2)

		# Run the simulation
		wisdom, herding = get_wisdom_and_herding(opinions, truth, W)
		print(wisdom, herding)
		print(wisdom-herding)

	
	
	

if __name__=="__main__":

	sim_some_random_stuff()
