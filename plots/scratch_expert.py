import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl

import matplotlib.colors as mcolors

def get_change_in_error(log_w, log_sigma_e_over_sigma_c):

    sigma_c = 1
    sigma_e = sigma_c * 10**log_sigma_e_over_sigma_c
    w =  10**log_w

    return (w**2 - 1)*sigma_e + (1-w)**2*sigma_c

def plot_log_heatmap_change_in_error():

    log_sigma_e_over_sigma_c = np.linspace(-1, 1, 1000)

    log_w = np.linspace(-1, 0, 1000)

    X, Y = np.meshgrid(log_sigma_e_over_sigma_c, log_w)

    Z = get_change_in_error(Y, X)

    fig, ax = plt.subplots()

    
    vmin = Z.min()
    vmax = Z.max()
    print(vmin, vmax)

    cmap = mpl.colormaps.get_cmap('coolwarm') 
    norm = mcolors.TwoSlopeNorm(vmin=vmin, vcenter=0, vmax=vmax)

    print(vmin, vmax)

    c = ax.pcolormesh(X, Y, Z, cmap=cmap, norm=norm)

    



    fig.colorbar(c, ax=ax)

    plt.xlabel(r'$10^(\sigma_e^2 / \sigma_c^2)$')
    plt.ylabel(r'$10^w$')

    
    plt.show()

plot_log_heatmap_change_in_error()
