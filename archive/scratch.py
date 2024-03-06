
import numpy as np

def coskewness(X, Y, Z):

    sd_X = np.std(X)
    sd_Y = np.std(Y)
    sd_Z = np.std(Z)

    n = len(X)
    S = 0
    for i in range(n):
        S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y)) * (Z[i] - np.mean(Z))

    return S / (n * sd_X * sd_Y * sd_Z)

def coskewness_2(X, Y):

    sd_X = np.std(X)
    sd_Y = np.std(Y)

    n = len(X)
    S = 0
    for i in range(n):
        S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y))**2
    return S / (n * sd_X * sd_Y * sd_Y)

def coskewness_2_simple(X, Y):

    mean_XY2 = np.mean(X * Y**2)
    mean_X = np.mean(X)
    mean_Y = np.mean(Y)
    mean_Y2 = np.mean(Y**2)
    mean_XY = np.mean(X * Y)

    sd_X = np.std(X)
    sd_Y = np.std(Y)

    return (mean_XY2 - 2*mean_XY*mean_Y - mean_X*mean_Y2 + 2*mean_X * mean_Y**2)/(sd_X*sd_Y**2)

def coskewness_unnormalised(X, Y, Z):
    
    n = len(X)
    S = 0
    for i in range(n):
        S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y)) * (Z[i] - np.mean(Z))
    
    return S / n

def covariance(X,Y):
    n = len(X)
    S = 0
    for i in range(n):
        S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y))
    return S / n

def covariance_simple(X,Y):
    mean_XY = np.mean(X * Y)
    mean_X = np.mean(X)
    mean_Y = np.mean(Y)
    return mean_XY - mean_X*mean_Y

def covariance_from_coskewness(X,Y):

    coskewness = coskewness_unnormalised(X,Y,Y)
    covariance_xy2 = covariance(X,Y**2)
    covariance_xy2 = np.real(np.cov(X, Y**2, bias=True)[0,1])
	
    return (covariance_xy2 - coskewness)/(2*np.mean(Y))


def covariance_from_coskewness_2(X,Y):

    n = len(X)
    S = 0
    for i in range(n):
        S += (X[i] - np.mean(X)) * (Y[i] - np.mean(Y))**2
    
    coskewness = S/n

    D = X - np.mean(X)
    covariance_xd2 = np.real(np.cov(X, D**2, bias=True)[0,1])
    print(covariance_xd2, coskewness)

    covariance_xy2 = np.real(np.cov(X, Y**2, bias=True)[0,1])
	
    return (covariance_xy2 - coskewness)/(2*np.mean(Y))
    

def coskewness_2_with_covar(X,Y):
    
    mean_X = np.mean(X)
    mean_Y = np.mean(Y)
    mean_XY = np.mean(X * Y)

    sd_X = np.std(X)
    sd_Y = np.std(Y)
    
    covar_Y2 = covariance(X,Y*Y)

    S = covar_Y2 - 2*mean_XY*mean_Y + 2*mean_X*mean_Y**2
    return S/(sd_X*sd_Y**2)

def coskewness_2_with_covar_2(X,Y):

    mean_Y = np.mean(Y)
    S = covariance(X,Y**2) - 2*mean_Y*covariance(X,Y)
    return S/(np.std(X)*np.std(Y)**2)


def test_coskewness():
    X = np.random.normal(0, 1, 100)
    Y = np.random.normal(0, 1, 100)
    Z = np.random.normal(0, 1, 100)
    print(coskewness(X, Y, Z))
    
    print(coskewness(X,Y,Y))
    print(coskewness_2(X,Y))
    print(coskewness_2_simple(X,Y))
    print(coskewness_2_with_covar(X,Y))
    print(coskewness_2_with_covar_2(X,Y))

    print(covariance(X,Y))
    print(covariance_simple(X,Y))
    print(covariance_from_coskewness(X,Y))

    print(np.real(np.cov(X, Y, bias=True)[0,1]))
    print(covariance_from_coskewness_2(X,Y))


def get_covariance_from_covs_2(X,Y):

    D = X - np.mean(X)
    D_squared = D**2


    

def test_covars():

    np.random.seed(1)

    X = np.random.normal(0, 1, 100)
    Y = np.random.normal(0, 1, 100)
    truth = 0.4
    E = X - truth
    E_squared = E**2

    D = X - np.mean(X)
    D_squared = D**2

    print("Here")
    print(covariance(X, D**2) - covariance(X, E**2))
    print(2 * np.mean(E) * covariance(X, E))

    print(covariance(X,E))
    print((covariance(X, D**2) - covariance(X, E**2))/(2*np.mean(E)))

    print(covariance(X, D**2))
    print(coskewness_unnormalised(X, E, E))





    print(np.mean(E))

    print(covariance(X, E_squared) - covariance(X, D_squared)/np.mean(E))

    print(2*covariance(X, E))

    print(coskewness_unnormalised(X, Y, Y))
    print(covariance(X, D**2))

    covariance_from_coskewness_2(X,Y)


    covariance_xe = covariance(X, E_squared) - covariance(X, D_squared)/(2*np.mean(E))
    print(covariance_xe)
    print(covariance(X, E))

def test_coskewness_and_covars():

    np.random.seed(1)

    X = np.random.normal(0, 1, 100)
    Y = np.random.normal(0, 1, 100)

    D = Y - np.mean(Y)

    print(coskewness_unnormalised(X, Y, Y))
    print(covariance(X, D**2))





def test_coefficeint_var():

    V = [0.1, 0.2,0.1,0.2,0.1,0.2, 0.1]

    print(np.sum(V))

    print(np.std(V))

    print(np.std(V)/np.mean(V))

    V_big = np.repeat(V, 10)
    V_big = V_big/np.sum(V_big)

    print(np.std(V_big))
    print(np.std(V_big)/np.mean(V_big))


def test_relationship_between_skewness_covariance():

    np.random.seed(1)

    X = np.random.normal(0, 1, 100)
    Y = np.random.normal(0, 1, 100)

    coskewness_unnormed = coskewness_unnormalised(X, Y, Y)
    cov_xy2 = covariance(X, Y**2)
    

    print(coskewness_unnormed, cov_xy2)






def test_variance_x_e_d():

    pass

if __name__ == "__main__":
     test_coskewness_and_covars()