

def get_equation_1_change_in_individual_error(change_in_crowd_error, change_in_variance):
    return change_in_crowd_error + change_in_variance

def get_equation_2_standardised_change_in_crowd_opinion(cv, cor_ve):
    return cv * cor_ve

def get_equation_3_crowd_beta(final_crowd_opinion, initial_crowd_opinion):
    return final_crowd_opinion / initial_crowd_opinion

def get_equation_4_crowd_beta(cv, initial_crowd_bias, s_d2, herding, s_e2, calibration):
    return cv/(2*initial_crowd_bias**2) * (s_d2 * herding - s_e2 * calibration) + 1

def get_change_in_crowd_bias_via_beta(initial_crowd_bias, beta):
    return initial_crowd_bias * (beta-1)

def get_change_in_crowd_error_via_beta(initial_crowd_bias, beta):
    return initial_crowd_bias**2 * (beta**2 - 1)

def get_change_in_individual_error_via_beta(initial_crowd_bias, beta, change_in_variance):
    return initial_crowd_bias**2 * (beta**2 - 1) + change_in_variance

def get_asymptotic_change_in_crowd_error_calibration_herding(cv, initial_crowd_bias, s_d2, herding, s_e2, calibration):
    beta = get_equation_4_crowd_beta(cv, initial_crowd_bias, s_d2, herding, s_e2, calibration)
    change_in_crowd_error = get_change_in_crowd_error_via_beta(initial_crowd_bias, beta)
    return change_in_crowd_error

def get_asymptotic_change_in_individual_error_calibration_herding(cv, initial_crowd_bias, s_d2, herding, s_e2, calibration, s_e):
    beta = get_equation_4_crowd_beta(cv, initial_crowd_bias, s_d2, herding, s_e2, calibration)
    change_in_indy_error = get_change_in_individual_error_via_beta(initial_crowd_bias, beta, -s_e**2)
    return change_in_indy_error

def get_asymptotic_change_in_crowd_error_standardised(cv, cor_v_e, z):
    """
    Asymptotic change in crowd error as a function of the correlation between the crowd and the truth
    and the correlation between the crowd and the individual.
    """
    return cv**2 * cor_v_e**2 + 2*z*cv*cor_v_e

def get_asymptotic_change_in_individual_error_standardised(cv, cor_v_e, z):
    """
    Asymptotic change in individual error as a function of the correlation between the crowd and the truth
    and the correlation between the crowd and the individual.
    """
    return cv**2 * cor_v_e**2 + 2*z*cv*cor_v_e - 1



"""
def get_asymptotic_change_in_crowd_error_from_cv_r_z(Cv, cor_v_e, z):
    return Cv**2 * cor_v_e**2 + 2*z*Cv*cor_v_e

def get_asymptotic_change_in_individual_error_from_cv_r_z(Cv, cor_v_e, z):
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

def get_asymptotic_change_in_indy_error_w_h(Cv, calibration, herding, mean_z, std_e2, std_d2, std_e):
    A = (Cv/std_e**2) * (std_e2 * -calibration - std_d2 * - herding)
    return  A**2 / (4*mean_z**2) + A - 1



def get_asymptotic_change_in_individual_error_expanded(Cv, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2, std_e):
    A = std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2
    return Cv**2 * A**2 / (4*mean_e**2) + Cv * A - std_e**2

"""