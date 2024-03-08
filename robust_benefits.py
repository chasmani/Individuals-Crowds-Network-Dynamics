


def get_asymptotic_change_in_crowd_error_standardised(CV_v, cor_v_e, z):
    return CV_v**2 * cor_v_e**2 + 2*z*CV_v*cor_v_e

def get_asymptotic_change_in_individual_error_standardised(CV_v, cor_v_e, z):
    return CV_v**2 * cor_v_e**2 + 2*z*CV_v*cor_v_e - 1

def get_asymptotic_change_in_crowd_error_expanded(CV_v, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2):
    A = std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2
    return CV_v**2 * A**2 / (4*mean_e**2) + CV_v * A

def get_asymptotic_change_in_individual_error_expanded(CV_v, cor_v_e_2, cor_v_d_2, mean_e, std_e2, std_d2, std_e):
    A = std_e2 * cor_v_e_2 - std_d2 * cor_v_d_2
    return CV_v**2 * A**2 / (4*mean_e**2) + CV_v * A - std_e**2
