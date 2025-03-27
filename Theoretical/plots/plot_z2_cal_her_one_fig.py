
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt


def get_max_cal_minus_herd(z2):
    
    return min(2 * np.sqrt(z2), 2)

def get_indy_change_zero_deltas(z2):

    d_plus = 1 + np.sqrt(1 + 1/(z2))
    d_minus = 1 - np.sqrt(1 + 1/(z2))

    print(d_plus, d_minus)
    return d_plus, d_minus

def get_indy_change_zero_cal_minus_herd(z2):

    zero_deltas = get_indy_change_zero_deltas(z2)
    zero_delta_plus = zero_deltas[0]
    zero_delta_minus = zero_deltas[1]
    return 2 * z2 * zero_delta_plus, 2 * z2 * zero_delta_minus

def plot_figure():

    zs = np.linspace(0, 1.2, 100)
    z2s = zs**2
    #    z2s = np.linspace(0, 1.2, 100)
    abs_max_cal_minus_herd = np.array([get_max_cal_minus_herd(z2) for z2 in z2s])

    plt.plot(zs, abs_max_cal_minus_herd, label="Max Allowed Range", color="grey")
    plt.plot(zs, -abs_max_cal_minus_herd, label="Min Allowed Range", color="grey")

    crowd_change_zero_max = 4 * z2s

    plt.plot(zs, crowd_change_zero_max, label="Crowd Change Zero", color="blue")
    plt.plot(zs, np.zeros(100), label="Crowd Change Zero", color="blue")

    indy_change_zero_max = np.array([get_indy_change_zero_cal_minus_herd(z2)[0] for z2 in z2s])
    indy_change_zero_min = np.array([get_indy_change_zero_cal_minus_herd(z2)[1] for z2 in z2s])


    plt.plot(zs, indy_change_zero_max, label="Indy Change Zero", color="red")
    plt.plot(zs, indy_change_zero_min, label="Indy Change Zero", color="red")

    plt.ylim(-2.2, 2.2)

    plt.show()

if __name__ == "__main__":
    plot_figure()

