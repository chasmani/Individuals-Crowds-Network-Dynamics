
import numpy as np

##########################
# Generating opinions and trust matrices
##########################

def generate_opinion_vector_random(n):
	return np.random.rand(n)

def generate_stochastic_weights_matrix_random(n):
	
	# Generate a random matrix of size n x n
	# where each row is a probability distribution
	# i.e. each row sums to 1
	# w_ij = weight that i gives to opinion of j
	W = np.random.rand(n,n)
	W = W/W.sum(axis=1)[:,None]
	return W


##########################
# DeGroot by simulation
##########################


def one_step_degroot(beliefs, W):
	return np.matmul(W, beliefs)

def one_step_degroot_single_node_manual(beliefs, W, i):

	weights = W[i,:]
	next_belief = 0
	for j in range(len(beliefs)):
		next_belief += beliefs[j] * weights[j]
	return next_belief

def test_one_step_degroot():

	beliefs = generate_opinion_vector_random(5)
	W = generate_stochastic_weights_matrix_random(5)
	next_beliefs = one_step_degroot(beliefs, W)

	for i in range(len(beliefs)):
		next_belief = one_step_degroot_single_node_manual(beliefs, W, i)
		if not np.isclose(next_belief, next_beliefs[i]):
			print("Test failed")
	print("Test passed")

def asympotic_degroot_manual(beliefs, W, t=1):

	for i in range(t):
		beliefs = np.matmul(W, beliefs)
	return beliefs

def asymptotic_degroot_matrix(beliefs, W, t=1):
	W_t = np.linalg.matrix_power(W, t)
	return np.matmul(W_t, beliefs)

def get_eigenweights(W):
	eigenvectors = np.linalg.eig(np.transpose(W))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_eigenvector = leading_eigenvector/sum(leading_eigenvector)
	return np.real(normalised_eigenvector)

def asymptotic_degroot(beliefs, W):
	eigenweights = get_eigenweights(W)
	final_opinion = np.matmul(eigenweights, beliefs)
	return final_opinion

def test_asymptotic_degroot():

	beliefs = generate_opinion_vector_random(5)
	W = generate_stochastic_weights_matrix_random(5)

	manual_version = asympotic_degroot_manual(beliefs, W, 100)
	eigenvector_version = asymptotic_degroot(beliefs, W)
	
	for i in range(len(beliefs)):
		if not np.isclose(manual_version[i], eigenvector_version):
			print("Test failed")
	print("Test passed")

def get_crowd_error(beliefs, truth):
	return np.mean(beliefs - truth)

def get_indy_error_vector(beliefs, truth):
	return beliefs - truth


#######################
# DeGoot by model
#######################


def get_change_in_crowd_opinion_asymptotic(beliefs, W):

	n = len(beliefs)
	eigenvectors = np.linalg.eig(np.transpose(W))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_leading_eigenvector = leading_eigenvector/sum(leading_eigenvector)

	covariance_eigenvector_beliefs = np.real(np.cov(beliefs, normalised_leading_eigenvector, bias=True)[0,1])

	return n*float(covariance_eigenvector_beliefs)

def test_change_in_crowd_opinion_asymptotic():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	change_in_crowd_opinion = np.mean(asymptotic_beliefs) - np.mean(beliefs)

	analytic_change_in_crowd_opinion = get_change_in_crowd_opinion_asymptotic(beliefs, W)

	if np.isclose(change_in_crowd_opinion, analytic_change_in_crowd_opinion):
		print("Test passed")
	else:
		print("Test failed")


def get_change_in_crowd_error_asymptotic(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	covariance_eigenvector_errors = np.real(np.cov(errors, eigenweights, bias=True)[0,1])
	mean_error = np.mean(errors)
	return n**2 * covariance_eigenvector_errors**2 + 2*mean_error*n*covariance_eigenvector_errors

def test_change_in_crowd_error_asymptotic():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_crowd_error = np.mean(asymptotic_beliefs - truth)**2
	initial_crowd_error = np.mean(beliefs - truth)**2

	change_in_crowd_error = final_crowd_error - initial_crowd_error

	analytic_change_in_crowd_error = get_change_in_crowd_error_asymptotic(beliefs, W, truth)

	if np.isclose(change_in_crowd_error, analytic_change_in_crowd_error):
		print("Test passed")
	else:
		print("Test failed")

def get_change_in_crowd_error_asymptotic_standardised(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	correlation_eigenweights_errors = np.corrcoef(errors, eigenweights)[0,1]   
	mean_error = np.mean(errors)
	standardised_mean_error = mean_error/np.sqrt(np.var(errors))
	coefficient_variation_v = np.sqrt(np.var(eigenweights))/np.mean(eigenweights)

	return coefficient_variation_v**2 * correlation_eigenweights_errors**2 + 2*standardised_mean_error*coefficient_variation_v*correlation_eigenweights_errors

def test_change_in_crowd_error_asymptotic_standardised():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_crowd_error = np.mean(asymptotic_beliefs - truth)**2
	initial_crowd_error = np.mean(beliefs - truth)**2

	change_in_crowd_error = final_crowd_error - initial_crowd_error
	change_in_crowd_error_standardised = change_in_crowd_error/np.var(beliefs)

	analytic_change_in_crowd_error_standardised = get_change_in_crowd_error_asymptotic_standardised(beliefs, W, truth)

	if np.isclose(change_in_crowd_error_standardised, analytic_change_in_crowd_error_standardised):
		print("Test passed")
	else:
		print("Test failed")
		print(change_in_crowd_error_standardised, analytic_change_in_crowd_error_standardised)


def get_change_in_indy_error_asymptotic(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	covariance_eigenvector_errors = np.real(np.cov(errors, eigenweights, bias=True)[0,1])
	mean_error = np.mean(errors)
	variance_error = np.var(errors)
	return n**2 * covariance_eigenvector_errors**2 + 2*mean_error*n*covariance_eigenvector_errors - variance_error

def test_change_in_indy_error_asymptotic():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_errors = (asymptotic_beliefs - truth)**2
	initial_errors = (beliefs - truth)**2

	mean_change_in_errors = np.mean(final_errors - initial_errors)

	analytic_change_in_errors = get_change_in_indy_error_asymptotic(beliefs, W, truth)

	if np.isclose(mean_change_in_errors, analytic_change_in_errors):
		print("Test passed")
	else:
		print("Test failed")
		

def get_change_in_indy_error_asymptotic_standardised(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	correlation_eigenweights_errors = np.corrcoef(errors, eigenweights)[0,1]   
	mean_error = np.mean(errors)
	standardised_mean_error = mean_error/np.sqrt(np.var(errors))
	coefficient_variation_v = np.sqrt(np.var(eigenweights))/np.mean(eigenweights)

	return coefficient_variation_v**2 * correlation_eigenweights_errors**2 + 2*standardised_mean_error*coefficient_variation_v*correlation_eigenweights_errors - 1

def test_change_in_indy_error_asymptotic_standardised():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_errors = (asymptotic_beliefs - truth)**2
	initial_errors = (beliefs - truth)**2

	mean_change_in_errors = np.mean(final_errors - initial_errors)
	mean_change_in_errors_standardised = mean_change_in_errors/np.var(beliefs)

	analytic_change_in_errors_standardised = get_change_in_indy_error_asymptotic_standardised(beliefs, W, truth)

	if np.isclose(mean_change_in_errors_standardised, analytic_change_in_errors_standardised):
		print("Test passed")
	else:
		print("Test failed")
		print(mean_change_in_errors_standardised, analytic_change_in_errors_standardised)

def test_all():

	test_one_step_degroot()
	test_asymptotic_degroot()
	test_change_in_crowd_opinion_asymptotic()
	test_change_in_crowd_error_asymptotic()
	test_change_in_crowd_error_asymptotic_standardised()
	test_change_in_indy_error_asymptotic()
	test_change_in_indy_error_asymptotic_standardised()





if __name__=="__main__":
	test_all()