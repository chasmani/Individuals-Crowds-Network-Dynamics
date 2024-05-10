
import numpy as np
import matplotlib.pyplot as plt

crs = np.linspace(-2,2,200)

z = -0.5

change_crowd_error = [cr**2 + 2*z*cr for cr in crs]
change_indy_error = [cr**2 + 2*z*cr - 1 for cr in crs]



plt.plot(crs, change_crowd_error, label="Crowd", linewidth=3, color="#f39c12", alpha=0.5)
plt.plot(crs, change_indy_error, label="Individual", linewidth=3, color="#9b59b6", alpha=0.5)



plt.axvline(x=-2*z, color="black", linewidth=2)
plt.axvline(x=0, color="pink", linewidth=2)

indy_lim_1 = - z + np.sqrt(z**2 + 1)
indy_lim_2 = - z - np.sqrt(z**2 + 1)

plt.axvline(x=indy_lim_1, linestyle='--', color='black')
plt.axvline(x=indy_lim_2, linestyle='--', color='pink')

plt.axvline(x=-2*z**2, color="yellow", linewidth=2)

# Scatter only negative points
for i in range(len(crs)):
    cr = crs[i]
    crowd_change = change_crowd_error[i]

    cond = -cr/z 
    if cond > 0 and cond < 2:
        plt.scatter(cr, crowd_change, color="black", s=20)

    indy_change = change_indy_error[i]
    if cr > (-z - np.sqrt(z**2 + 1)) and cr < (-z + np.sqrt(z**2 + 1)):
        plt.scatter(cr, indy_change, color="black", s=20)
    


# Add gridlines
plt.grid(True, which='both', linestyle='--', linewidth=0.5)

plt.show()

