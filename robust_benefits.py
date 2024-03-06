


def get_asymptotic_change_in_crowd_error_standardised(CV_v, cor_v_e, z):
    return CV_v**2 * cor_v_e**2 + 2*z*CV_v*cor_v_e

def get_asymptotic_change_in_individual_error_standardised(CV_v, cor_v_e, z):
    return CV_v**2 * cor_v_e**2 + 2*z*CV_v*cor_v_e - 1


"""
def get_asymptotic_change_in_crowd_error_standardised_expanded


def get_asymptotic_change_in_individual_error_standardised_expanded
"""