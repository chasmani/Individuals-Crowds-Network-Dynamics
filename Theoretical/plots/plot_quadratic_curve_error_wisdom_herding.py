
import numpy as np
import matplotlib.pyplot as plt

alphas = np.linspace(1-,1,200)

zs = [0.25, 0.5, 1]

for k, z in enumerate(zs):

    plt.subplot(1, 3, k+1)

    change_crowd_error = [1/(4*z**2) * alpha**2 + 2*z*alpha for alpha in alphas]
    change_indy_error = [1/(4*z**2) * alpha**2 + 2*z*alpha - 1 for alpha in alphas]

    plt.plot(alphas, change_crowd_error, label="Crowd", linewidth=3, color="#f39c12")
    plt.plot(alphas, change_indy_error, label="Individual", linewidth=3, color="#9b59b6")

    # PLot y = 0 line
    plt.axhline(y=0, color='k', linestyle='--')
    
    # Remove plot boundary lines
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)


    plt.legend()

    plt.xlabel(r"Wisdom - Herding")
    plt.ylabel(r"Asymptotic Change in Error")

plt.savefig("images/error_curves_alpha.png", dpi=300)

plt.show()