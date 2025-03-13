
import numpy as np

n = 10
opinions = np.random.rand(n)
truth = 1

crowd_error = (np.mean(opinions - truth))**2
indy_error = np.mean((opinions - truth)**2)
var_x = np.var(opinions)

print(crowd_error, indy_error, var_x)
print(crowd_error - indy_error)

opinions2 = np.random.rand(n)
truth = 1

crowd_error_2 = (np.mean(opinions2 - truth))**2
indy_error_2 = np.mean((opinions2 - truth)**2)
var_x_2 = np.var(opinions2)

delta_crowd_error = crowd_error_2 - crowd_error
delta_indy_error = indy_error_2 - indy_error
delta_var_x = var_x_2 - var_x
print(delta_crowd_error, delta_indy_error, delta_var_x)
print(delta_crowd_error + delta_var_x, delta_indy_error)