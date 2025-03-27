import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
plt.rcParams.update({'font.size': 12})

# Set random seed for reproducibility
np.random.seed(40)

# Generate data
truth = 8
n_individuals = 10
n_plots = 4

# Initial opinions
initial_opinions = np.random.normal(truth, 2, n_individuals)

# Create figure and axes
fig, axes = plt.subplots(n_plots, 1, figsize =(6,n_plots), sharex=True)

# Generate data for each subplot
for i in range(n_plots):
    if i == 0:
        opinions = initial_opinions
    elif i == n_plots - 1:
        opinions = np.full(n_individuals, np.mean(opinions)) + 0.05
    else:
        opinions = opinions * 0.7 + np.mean(opinions) * 0.3 + 0.1
    
    mean_opinion = np.mean(opinions)
    
    # Plot scatter points
    sns.scatterplot(x=opinions, y=[0]*n_individuals, ax=axes[i], s=100, color="#404040", linewidth=1)
    
    # Plot truth
    axes[i].axvline(x=truth, color='red', linestyle='--', label='Truth', linewidth=2)
    
    # Plot mean opinion
    axes[i].axvline(x=mean_opinion, color='#404040', linestyle='-', label='Mean Opinion', linewidth=2)
    
    axes[i].set_ylim(-0.5, 0.5)
    axes[i].set_yticks([])
    
    
    axes[i].spines['left'].set_visible(False)
    axes[i].spines['right'].set_visible(False)
    axes[i].spines['top'].set_visible(False)

    axes[i].set_xticklabels([])

    # Remove axes     
    if i == n_plots-1:
        axes[i].legend()
        plt.xlabel("Opinion")
    
    axes[i].set_ylabel("t = {}".format(i+1))


plt.tight_layout()

plt.savefig("images/converging_opinions_{}.png".format(n_plots), dpi=300)
plt.show()