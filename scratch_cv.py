
import numpy as np

v = np.array([1,1,1,1,1,0,0,0,0,0])
v = v/sum(v)
print(np.std(v))

v = np.array([1,0,0,0,0,0,0,0,0,0])
v = v/sum(v)
print(v)
print(np.std(v))

print(np.mean(v))
# Manaully calcaulte std
std = np.sqrt(sum((v - np.mean(v))**2)/len(v))
print(std)

std = np.sqrt((((1-np.mean(v))**2) + ((0-np.mean(v))**2)*9)/10)
print(std)

n = len(v)

std = np.sqrt((((1-1/n)**2) + ((1/n)**2)*(n-1))/n)
print(std)

A = 1-1/n
B = (n-1) * (1/n)**2

