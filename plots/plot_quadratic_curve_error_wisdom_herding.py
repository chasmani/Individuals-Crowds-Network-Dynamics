
import numpy as np
import matplotlib.pyplot as plt

wisdom_minus_herdings = np.linspace(-5,5,200)

z = -1

change_crowd_error = [1/(4*z**2) * beta**2 - beta for beta in wisdom_minus_herdings]
change_indy_error = [1/(4*z**2) * beta**2 - beta - 1 for beta in wisdom_minus_herdings]

plt.plot(wisdom_minus_herdings, change_crowd_error, label="Crowd", linewidth=3, color="#f39c12")
plt.plot(wisdom_minus_herdings, change_indy_error, label="Individual", linewidth=3, color="#9b59b6")

# PLot y = 0 line
plt.axhline(y=0, color='k', linestyle='--')

plt.axvline(x=2*z**2, color="pink", linewidth=3)

# Remove plot boundary lines
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)


plt.legend()

plt.xlabel(r"Wisdom - Herding")
plt.ylabel(r"Asymptotic Change in Error")

plt.savefig("images/error_curve_wisdom_minus_herding.png", dpi=300)

plt.show()