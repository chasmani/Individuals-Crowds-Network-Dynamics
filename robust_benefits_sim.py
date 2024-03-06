
import numpy as np

def sim_asymptotic_change_in_crowd_error_standardised(opinions, W, truth):

    sd_e = np.std(opinions)
    initial_crowd_error = (np.mean(opinions) - truth)**2
    
    # Run 1000 timesteps
    for i in range(1000):
        opinions = np.matmul(W, opinions)
    final_crowd_error = (np.mean(opinions) - truth)**2
    return (final_crowd_error - initial_crowd_error)/sd_e**2