

import numpy as np

v = np.random.normal(0, 1, 100)

e = np.random.normal(0, 1, 100)
cov_v_e = np.cov(v, e, bias=True)[0,1]

e_2 = e**2

d = e - np.mean(e)
d_2 = d**2

cov_v_e_2 = np.cov(v, e_2, bias=True)[0,1]
cov_v_d_2 = np.cov(v, d_2, bias=True)[0,1]

print(cov_v_e)
cov_v_e_b = (cov_v_e_2 - cov_v_d_2)/ (2 * np.mean(e))
print(cov_v_e_b)

