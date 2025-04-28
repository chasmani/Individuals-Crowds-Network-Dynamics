
import numpy as np

def sim_change_in_crowd_bias_standardised(opinions, W, truth, steps):

    sd_e = np.std(opinions)
    initial_crowd_bias = np.mean(opinions) - truth
    
    # Run 1000 timesteps
    for i in range(steps):
        opinions = np.matmul(W, opinions)
    final_crowd_bias = np.mean(opinions) - truth

    return (final_crowd_bias - initial_crowd_bias)/sd_e

def sim_final_crowd_bias(opinions, W, truth, steps):

    # Run 1000 timesteps
    for i in range(steps):
        opinions = np.matmul(W, opinions)
    final_crowd_bias = np.mean(opinions) - truth

    return final_crowd_bias

def sim_get_final_opinions(opinions, W, steps):
    # Run 1000 timesteps
    for i in range(steps):
        opinions = np.matmul(W, opinions)
    return opinions


def sim_change_in_crowd_error_standardised(opinions, W, truth, steps):

    sd_e = np.std(opinions)
    initial_crowd_error = (np.mean(opinions) - truth)**2
    
    # Run 1000 timesteps
    for i in range(steps):
        opinions = np.matmul(W, opinions)
    final_crowd_error = (np.mean(opinions) - truth)**2
    return (final_crowd_error - initial_crowd_error)/sd_e**2


def sim_change_in_individual_error_standardised(opinions, W, truth, steps):

    sd_e = np.std(opinions)
    initial_indy_error = np.mean((opinions - truth)**2)
    
    # Run 1000 timesteps
    for i in range(steps):
        opinions = np.matmul(W, opinions)
    final_indy_error = np.mean((opinions - truth)**2)
    return (final_indy_error - initial_indy_error)/sd_e**2

