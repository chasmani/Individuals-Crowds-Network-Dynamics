
def get_asymptotic_change_in_crowd_error_standardised(Cv, cor_v_e, z):
    return Cv**2 * cor_v_e**2 + 2*z*Cv*cor_v_e

def get_asymptotic_change_in_individual_error_standardised(Cv, cor_v_e, z):
    return Cv**2 * cor_v_e**2 + 2*z*Cv*cor_v_e - 1

def get_asymptotic_change_in_crowd_error_expanded(Cv, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2):
    A = std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2
    return Cv**2 * A**2 / (4*mean_e**2) + Cv * A

def get_asymptotic_change_in_crowd_error_expanded_std(Cv, cor_v_e_2, cor_v_d_2, mean_z, std_e2, std_d2, std_e):
    A = (Cv/std_e**2) * (std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2)
    return  A**2 / (4*mean_z**2) + A


def get_asymptotic_change_in_individual_error_expanded_std(Cv, cor_v_e_2, cor_v_d_2, mean_z, std_e2, std_d2, std_e):
    A = (Cv/std_e**2) * (std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2)
    return  A**2 / (4*mean_z**2) + A - 1

def get_asymptotic_change_in_crowd_error_w_h(Cv, calibration, herding, mean_z, std_e2, std_d2, std_e):
    A = (Cv/std_e**2) * (std_e2 * -calibration - std_d2 * - herding)
    return  A**2 / (4*mean_z**2) + A




"""
def get_asymptotic_change_in_crowd_error_expanded_standardised(Cv, cor_v_e_2, cor_v_d_2, mean_z, std_e2, std_d2, std_e):
    A = Cv * (std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2)
    return  A**2 / (4*mean_z**2) + A/(std_e**2)
"""

def get_asymptotic_change_in_individual_error_expanded(Cv, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2, std_e):
    A = std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2
    return Cv**2 * A**2 / (4*mean_e**2) + Cv * A - std_e**2








# DELETE ALL OF THESE ONCE DONE::
def get_asymptotic_change_in_crowd_error_w_h(wisdom, herding, mean_e):
   
    return (herding-wisdom) * ( 1/(4*mean_e**2) * (herding-wisdom) + 1)

def get_asymptotic_change_in_individual_error_w_h(wisdom, herding, mean_e, std_e):
   
    return (herding-wisdom) * ( 1/(4*mean_e**2) * (herding-wisdom) + 1) - std_e**2

def get_asymptotic_change_in_crowd_error_w_h_standarised(wisdom, herding, z):
   
    return (wisdom-herding) * ( 1/(4*z**2) * (wisdom-herding) - 1)

def get_asymptotic_change_in_individual_error_w_h_standardised(wisdom, herding,z):
   
    return (wisdom-herding) * ( 1/(4*z**2) * (wisdom-herding) - 1) - 1

