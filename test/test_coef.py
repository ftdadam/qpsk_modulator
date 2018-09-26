import numpy as np
import operator
from tool._fixedInt import*
from tool.DSP import*

os = 4
Nbauds = 4
beta = 0.5
Tbaud = 1.0/1024000.0
offset = 3

#filtro root rised cosine TX
# punto flotante
(t,rrc_tx) = rrcosine (beta, Tbaud, os, Nbauds, Norm=False ) 
# punto fijo optimo: S(8,6)
Ntotal_optimo = 8
frac_optimo = 6
rrc_fix_vect_optimo_tx = arrayFixedInt( int(Ntotal_optimo),int(frac_optimo),rrc_tx,'S','round','saturate' )
rrc_fix_optimo_tx = fixing_append(rrc_fix_vect_optimo_tx)

coef = []
for ptr in range (0, len(rrc_fix_vect_optimo_tx)):
	coef.append(rrc_fix_vect_optimo_tx[ptr].intvalue)

# coef = [255, 0, 1, 1, 0, 255, 255, 1, 3, 1, 251, 246, 249, 10, 37, 62, 73, 62, 37, 10, 249, 246, 251, 1, 3, 1, 255, 255, 0, 1, 1, 0]
ncoef = len(coef)
print coef

signs = []
aux = []
for ptr in range(0,ncoef):
	aux.append(2**ncoef/2**(ptr+1))

for ptr in range(0,ncoef):
	a=[]
	b=[]
	counter = 0
	while(len(a)<2**ncoef):
		if(counter%2 == 0):
			b = ([1]*aux[ptr])
		else:
			b = ([-1]*aux[ptr])
		a = a + b
		counter = counter + 1
	signs.append(a)


coef_matrix = np.tile(coef,(2**ncoef,1))

results = np.zeros(2**ncoef)

for ptr in range(0,ncoef):
	results = results+(coef_matrix[:,ptr]*signs[ptr])

for ptr in range(0,len(results)):
	if(results[ptr]>127):
		results[ptr] = 127
	elif(results[ptr]<-128):
		results[ptr] = -128

print len(np.unique(results))