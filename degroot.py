
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

def get_change_in_crowd_opinion_asymptotic(n, covariance):
	return n * covariance

def get_change_in_crowd_opinion_asymptotic_analytic(beliefs, W):

	n = len(beliefs)
	eigenvectors = np.linalg.eig(np.transpose(W))[1]
	leading_eigenvector = eigenvectors[:,0]
	normalised_leading_eigenvector = leading_eigenvector/sum(leading_eigenvector)

	covariance_eigenvector_beliefs = np.real(np.cov(beliefs, normalised_leading_eigenvector, bias=True)[0,1])

	return get_change_in_crowd_opinion_asymptotic(n, covariance_eigenvector_beliefs)

def test_change_in_crowd_opinion_asymptotic():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	change_in_crowd_opinion = np.mean(asymptotic_beliefs) - np.mean(beliefs)

	analytic_change_in_crowd_opinion = get_change_in_crowd_opinion_asymptotic_analytic(beliefs, W)

	if np.isclose(change_in_crowd_opinion, analytic_change_in_crowd_opinion):
		print("Test passed")
	else:
		print("Test failed")

def get_change_in_crowd_error_asymptotic(n, covariance_v_e, mean_error):
	return n**2 * covariance_v_e**2 + 2*mean_error*n*covariance_v_e

def get_change_in_crowd_error_asymptotic_analytic(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	covariance_eigenvector_errors = np.real(np.cov(errors, eigenweights, bias=True)[0,1])
	mean_error = np.mean(errors)
	return get_change_in_crowd_error_asymptotic(n, covariance_eigenvector_errors, mean_error)

def test_change_in_crowd_error_asymptotic():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_crowd_error = np.mean(asymptotic_beliefs - truth)**2
	initial_crowd_error = np.mean(beliefs - truth)**2

	change_in_crowd_error = final_crowd_error - initial_crowd_error

	analytic_change_in_crowd_error = get_change_in_crowd_error_asymptotic_analytic(beliefs, W, truth)

	if np.isclose(change_in_crowd_error, analytic_change_in_crowd_error):
		print("Test passed")
	else:
		print("Test failed")


def get_change_in_crowd_error_asymptotic_intuitive_analytic(n, coskewness, cov_v_e2, mean_error):
	covariance_v_e = (cov_v_e2-coskewness)/(2*mean_error)
	return n**2 * covariance_v_e**2 + 2*mean_error*n*covariance_v_e

def get_coskewness_unnormed(X, Y, Z):

	n = len(X)
	S = 0
	for i in range(n):
		S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y)) * (Z[i] - np.mean(Z))
	return S/n

def covariance_from_coskewness(X,Y):

	n = len(X)
	S = 0
	for i in range(n):
		S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y))**2
	
	coskewness = S/n
	covariance_xy2 = np.real(np.cov(X, Y**2, bias=True)[0,1])
	
	return (covariance_xy2 - coskewness)/(2*np.mean(Y))

def get_change_in_crowd_error_aymptotic_intuitive(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	mean_error = np.mean(errors)
	covariance_ve2 = np.real(np.cov(eigenweights, errors**2, bias=True)[0,1])
	coskewness = get_coskewness_unnormed(eigenweights, errors, errors)

	return get_change_in_crowd_error_asymptotic_intuitive_analytic(n, coskewness, covariance_ve2, mean_error)


def test_change_in_crowd_error_asymptotic_intuitive():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_crowd_error = np.mean(asymptotic_beliefs - truth)**2
	initial_crowd_error = np.mean(beliefs - truth)**2

	change_in_crowd_error = final_crowd_error - initial_crowd_error

	intuitive_change_in_crowd_error = get_change_in_crowd_error_aymptotic_intuitive(beliefs, W, truth)

	if np.isclose(change_in_crowd_error, intuitive_change_in_crowd_error):
		print("Test passed")
	else:
		print(change_in_crowd_error, intuitive_change_in_crowd_error)
		print("Test failed")





def get_change_in_crowd_error_asymptotic_standardised(coeff_variation_v, correlation_eigenweights_errors, mean_error_standardised):
	
	return coeff_variation_v**2 * correlation_eigenweights_errors**2 + 2*mean_error_standardised*coeff_variation_v*correlation_eigenweights_errors

def get_change_in_crowd_error_asymptotic_standardised_analytic(beliefs, W, truth):

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

	analytic_change_in_crowd_error_standardised = get_change_in_crowd_error_asymptotic_standardised_analytic(beliefs, W, truth)

	if np.isclose(change_in_crowd_error_standardised, analytic_change_in_crowd_error_standardised):
		print("Test passed")
	else:
		print("Test failed")
		print(change_in_crowd_error_standardised, analytic_change_in_crowd_error_standardised)

def get_change_in_indy_error_asymptotic(n, covariance_v_e, mean_error, variance_error):
	return n**2 * covariance_v_e**2 + 2*mean_error*n*covariance_v_e - variance_error


def get_change_in_indy_error_asymptotic_analytic(beliefs, W, truth):

	n = len(beliefs)
	eigenweights = get_eigenweights(W)
	errors = beliefs - truth
	covariance_eigenvector_errors = np.real(np.cov(errors, eigenweights, bias=True)[0,1])
	mean_error = np.mean(errors)
	variance_error = np.var(errors)
	return get_change_in_indy_error_asymptotic(n, covariance_eigenvector_errors, mean_error, variance_error)

def test_change_in_indy_error_asymptotic():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	asymptotic_beliefs = asymptotic_degroot(beliefs, W)

	final_errors = (asymptotic_beliefs - truth)**2
	initial_errors = (beliefs - truth)**2

	mean_change_in_errors = np.mean(final_errors - initial_errors)

	analytic_change_in_errors = get_change_in_indy_error_asymptotic_analytic(beliefs, W, truth)

	if np.isclose(mean_change_in_errors, analytic_change_in_errors):
		print("Test passed")
	else:
		print("Test failed")
		
def get_change_in_indy_error_asymptotic_standardised(coeff_variation_v, correlation_v_e, mean_error_standardised):
	
	return coeff_variation_v**2 * correlation_v_e**2 + 2*mean_error_standardised*coeff_variation_v*correlation_v_e - 1


def get_change_in_indy_error_asymptotic_standardised_analytic(beliefs, W, truth):

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

	analytic_change_in_errors_standardised = get_change_in_indy_error_asymptotic_standardised_analytic(beliefs, W, truth)

	if np.isclose(mean_change_in_errors_standardised, analytic_change_in_errors_standardised):
		print("Test passed")
	else:
		print("Test failed")
		print(mean_change_in_errors_standardised, analytic_change_in_errors_standardised)

def get_one_step_influence_vector(W):

	# Get the out-degree of each node
	out_degree = np.sum(W, axis=0)
	return out_degree

def get_change_in_crowd_error_one_step(covariance_wstar_e, mean_error):

	return covariance_wstar_e**2 + 2*mean_error*covariance_wstar_e

def get_change_in_crowd_error_one_step_analytic(beliefs, W, truth):

	influence_vector = get_one_step_influence_vector(W)
	errors = beliefs - truth

	covariance_influence_errors = np.real(np.cov(influence_vector, errors, bias=True)[0,1])

	mean_error = np.mean(errors)

	return get_change_in_crowd_error_one_step(covariance_influence_errors, mean_error)


def test_change_in_crowd_error_one_step():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	next_beliefs = one_step_degroot(beliefs, W)

	final_crowd_error = np.mean(next_beliefs - truth)**2
	initial_crowd_error = np.mean(beliefs - truth)**2

	change_in_crowd_error = final_crowd_error - initial_crowd_error

	one_step_change_in_crowd_error = get_change_in_crowd_error_one_step_analytic(beliefs, W, truth)

	if np.isclose(change_in_crowd_error, one_step_change_in_crowd_error):
		print("Test passed")
	else:
		print("Test failed")


def get_change_in_crowd_opinion_one_step(covariance_wstar_e):

	return covariance_wstar_e

def get_change_in_crowd_opinion_one_step_analytic(beliefs, W):

	influence_vector = get_one_step_influence_vector(W)

	covariance_influence_beliefs = np.real(np.cov(influence_vector, beliefs, bias=True)[0,1])

	return get_change_in_crowd_opinion_one_step(covariance_influence_beliefs)

def test_change_in_crowd_opinion_one_step():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	next_beliefs = one_step_degroot(beliefs, W)

	change_in_opinion = np.mean(next_beliefs) - np.mean(beliefs)

	one_step_change_in_opinion = get_change_in_crowd_opinion_one_step_analytic(beliefs, W)

	if np.isclose(np.mean(change_in_opinion), one_step_change_in_opinion):
		print("Test passed")
	else:
		print("Test failed")


def get_change_in_crowd_opinion_one_step_standardised(coeff_variation_wstar, correlation_wstar_e):
	
	return coeff_variation_wstar * correlation_wstar_e

def get_change_in_crowd_opinion_one_step_standardised_analytic(beliefs, W):

	influence_vector = get_one_step_influence_vector(W)

	correlation_influence_beliefs = np.corrcoef(influence_vector, beliefs)[0,1]

	coefficient_variation_w = np.sqrt(np.var(influence_vector))/np.mean(influence_vector)

	return get_change_in_crowd_opinion_one_step_standardised(coefficient_variation_w, correlation_influence_beliefs)

def test_change_in_crowd_opinion_one_step_standardised():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	next_beliefs = one_step_degroot(beliefs, W)

	change_in_opinion = np.mean(next_beliefs) - np.mean(beliefs)
	change_in_opinion_standardised = change_in_opinion/np.sqrt(np.var(beliefs))

	one_step_change_in_opinion_standardised = get_change_in_crowd_opinion_one_step_standardised_analytic(beliefs, W)

	if np.isclose(change_in_opinion_standardised, one_step_change_in_opinion_standardised):
		print("Test passed")
	else:
		print("Test failed")


def get_change_in_crowd_error_one_step_standardised(coeff_variation_wstar, correlation_wstar_e, mean_error_standardised):
	
	return coeff_variation_wstar**2 * correlation_wstar_e**2 + 2*mean_error_standardised*coeff_variation_wstar*correlation_wstar_e

def get_change_in_crowd_error_one_step_standardised_analytic(beliefs, W, truth):

	influence_vector = get_one_step_influence_vector(W)
	errors = beliefs - truth

	correlation_influence_errors = np.corrcoef(influence_vector, errors)[0,1]

	mean_error = np.mean(errors)

	standardised_mean_error = mean_error/np.sqrt(np.var(errors))

	coefficient_variation_w = np.sqrt(np.var(influence_vector))/np.mean(influence_vector)

	return get_change_in_crowd_error_one_step_standardised(coefficient_variation_w, correlation_influence_errors, standardised_mean_error)

def test_change_in_crowd_error_one_step_standardised():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	next_beliefs = one_step_degroot(beliefs, W)

	final_crowd_error = np.mean(next_beliefs - truth)**2
	initial_crowd_error = np.mean(beliefs - truth)**2

	change_in_crowd_error = final_crowd_error - initial_crowd_error
	change_in_crowd_error_standardised = change_in_crowd_error/np.var(beliefs)

	one_step_change_in_crowd_error_standardised = get_change_in_crowd_error_one_step_standardised_analytic(beliefs, W, truth)

	if np.isclose(change_in_crowd_error_standardised, one_step_change_in_crowd_error_standardised):
		print("Test passed")
	else:
		print("Test failed")
		print(change_in_crowd_error_standardised, one_step_change_in_crowd_error_standardised)

def get_indy_influence_vector(W, i):

	# Get the in-degree of node i
	in_vector = W[i,:]
	return in_vector

def get_change_in_indy_opinion_one_step(n, covariance_w_i_e, mean_belief, belief_i):
	
	return n * covariance_w_i_e + mean_belief - belief_i

def get_change_in_indy_opinion_one_step_analytic(beliefs, W, i):
	
	n = len(beliefs)
	w_i = get_indy_influence_vector(W, i)
	covariance_w_i_beliefs = np.real(np.cov(w_i, beliefs, bias=True)[0,1])

	return get_change_in_indy_opinion_one_step(n, covariance_w_i_beliefs, np.mean(beliefs), beliefs[i])

def test_change_in_indy_opinion_one_step():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	
	next_beliefs = one_step_degroot(beliefs, W)

	change_in_opinion = next_beliefs - beliefs

	for i in range(n):
		one_step_change_in_opinion = get_change_in_indy_opinion_one_step_analytic(beliefs, W, i)

		if not np.isclose(change_in_opinion[i], one_step_change_in_opinion):
			print("Test failed")
	print("Test passed")

def get_change_in_indy_error_one_step(n, covariance_w_i_errors, mean_error, error_i):

	return n**2 * covariance_w_i_errors**2 + 2*mean_error*n*covariance_w_i_errors + mean_error**2 - error_i**2


def get_change_in_indy_error_one_step_analytic(beliefs, W, truth, i):

	n = len(beliefs)
	w_i = get_indy_influence_vector(W, i)
	errors = beliefs - truth
	covariance_w_i_errors = np.real(np.cov(w_i, errors, bias=True)[0,1])
	mean_error = np.mean(errors)

	return get_change_in_indy_error_one_step(n, covariance_w_i_errors, mean_error, errors[i])

def test_change_in_indy_error_one_step():

	n = 10
	beliefs = generate_opinion_vector_random(n)
	W = generate_stochastic_weights_matrix_random(n)
	truth = 0.5
	
	next_beliefs = one_step_degroot(beliefs, W)

	final_errors = next_beliefs - truth
	initial_errors = beliefs - truth

	for i in range(n):
		one_step_change_in_errors = get_change_in_indy_error_one_step_analytic(beliefs, W, truth, i)

		if not np.isclose(final_errors[i]**2 - initial_errors[i]**2, one_step_change_in_errors):
			print("Test failed")

	print("Test passed")



def test_all():

	test_one_step_degroot()
	test_asymptotic_degroot()
	test_change_in_crowd_opinion_asymptotic()
	test_change_in_crowd_error_asymptotic()
	test_change_in_crowd_error_asymptotic_intuitive()
	test_change_in_crowd_error_asymptotic_standardised()
	test_change_in_indy_error_asymptotic()
	test_change_in_indy_error_asymptotic_standardised()
	test_change_in_crowd_opinion_one_step()
	test_change_in_crowd_opinion_one_step_standardised()
	test_change_in_crowd_error_one_step()
	test_change_in_crowd_error_one_step_standardised()
	test_change_in_indy_opinion_one_step()
	test_change_in_indy_error_one_step()





if __name__=="__main__":
	test_all()