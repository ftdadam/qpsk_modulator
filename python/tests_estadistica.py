import numpy as np
import matplotlib.pyplot as plt
import random
# import statsmodels
# import scipy
# import pandas
from tool.DSP import*

# normal = [random.gauss(3,1) for _ in range(400)]

def fx_opt_res(NB_test, float_signal,mode,title):
    # Se realiza una prueba iterativa para cada numero de bits totales desde 2 hasta X inclusive (donde X es un parametro).
    # Para cada numero de bits totales, se calcula en punto fijo la senial en todas las resoluciones de parte NBFcional posible,
    # es decir, S(N,0) hasta S(N,N-1). Para cada una se calcula el SNR y se guarda el SNR maximo, que implica el mejor desempenio
    # para ese numero de bits totales. Luego, para saber cual es la resolucion optima, se busca para cual resolucion se produce 
    # el SNR supremo.
    # NB_test: Numero de bits totales maximos para la prueba
    # float_signal: datos a los que se requiere aplicar la prueba    
    global img_format
    global img_ptr
    colors=['.b-','.g-','.r-','.k-','.y-','.m-','.c-','.b-','.g-','.r-','.k-','.y-','.m-','.c-']
    NB_vect = np.arange(2,NB_test+1)
    NBF_vect = np.arange(0,NB_test+2)
    w, h = 3, len(NB_vect)*len(NBF_vect)
    matrix = [[0 for x in range(w)] for y in range(h)] # [NB,NBF,SNR]    
    ptr = 0
    ptr2 = 0
    for NB in NB_vect:     # Desde NB = 2 hasta NB = NB_test
        for NBF in NBF_vect:    # Desde parte fraccional NBF = 0 hasta NBF = NB+1
            fixed_signal = []
            fixed_signal_int = []
            fixed_signal, fixed_signal_int = float2fix(int(NB),int(NBF),float_signal,'S',mode,'saturate')
            matrix[ptr][0] = NB
            matrix[ptr][1] = NBF
            matrix[ptr][2] = np.dot(float_signal,float_signal)/(np.dot ( (float_signal-fixed_signal), (float_signal-fixed_signal) ) )
            ptr = ptr + 1
    
    # plt.figure()
    # for ptr in range (0,h):
	   #  plt.plot(10*np.log10(matrix[ptr][2]),'b.')
	   #  plt.title(title)
	   #  plt.grid()
	   #  plt.legend(loc='upper left')
	   #  plt.xlabel('NBF')
	   #  plt.ylabel('SNR (dB)')
	   #  plt.hold(True)
	   #  ptr2 = ptr2 +1
    matrix = sorted(matrix,key=lambda x: x[2])
    # for ptr in range (0,h):
    # 	print matrix[ptr]
    
    NB_opt = matrix[h-1][0]
    NBF_opt = matrix[h-1][1]
    # NB_opt = 8
    # NBF_opt = 6
    fixed_signal_opt, fixed_signal_opt_int = float2fix(int(NB_opt),int(NBF_opt),float_signal,'S',mode,'saturate')
    return (NB_opt,NBF_opt,fixed_signal_opt,fixed_signal_opt_int)


data = np.random.randn(10000)

title = 'Truncado'
(NB_opt,NBF_opt,trunc,a) = fx_opt_res(8,np.array(data),'trunc',title)
print title,': ',NB_opt,NBF_opt

title = 'Truncado Alternativo'
(NB_opt,NBF_opt,trunc_alt,a) = fx_opt_res(8,np.array(data),'trunc_alt',title)
print title,': ',NB_opt,NBF_opt

mu = 0.0
sigma = 1.0
x1 = data
x2 = trunc
x3 = trunc_alt

file1 = open('files_float/data_float.txt','w')
file2 = open('files_float/data_trunc.txt','w')
file3 = open('files_float/data_trunc_alt.txt','w')
for n in x1:
	file1.write('%f\n' %n)
file1.close()
for n in x2:
	file2.write('%f\n' %n)
file2.close()
for n in x3:
	file3.write('%f\n' %n)
file3.close()

num_bins = 250
# the histogram of the data
f, (ax1, ax2,ax3) = plt.subplots(1, 3)
n1, bins1, patches1 = ax1.hist(x1, num_bins, normed=1, facecolor='red', alpha=1.0)
n2, bins2, patches2 = ax2.hist(x2, num_bins, normed=1, facecolor='green', alpha=1.0)
n3, bins3, patches3 = ax3.hist(x3, num_bins, normed=1, facecolor='blue', alpha=1.0)


y1 = plt.mlab.normpdf(bins1, mu, sigma)
y2 = plt.mlab.normpdf(bins2, mu, sigma)
y3 = plt.mlab.normpdf(bins3, mu, sigma)

ax1.plot(bins1, y1, 'k--')
ax1.set_xlabel('Float')
ax1.set_ylabel('Probability')
ax1.grid(True)
ax1.set_ylim([0,0.8])
ax2.plot(bins1, y2, 'k--')
ax2.set_xlabel('Truncado')
ax2.grid(True)
ax2.set_ylim([0,0.8])
ax3.plot(bins1, y3, 'k--')
ax3.set_xlabel('Truncado Alternativo')
ax3.grid(True)
ax3.set_ylim([0,0.8])


plt.figure()
plt.plot(bins1,y1,'r--',label='Float')
plt.plot(bins2,y2,'g--',label='Truncado')
plt.plot(bins3,y3,'b--',label='Truncado Alt.')
plt.grid(True)
plt.legend()

# plt.figure()
# plt.hist(normal,bins,alpha=0.5,label='normal')
# # plt.xlim()
# plt.grid(True)
# plt.legend()
# plt.xlabel('')
# plt.ylabel('')
# title = ''
# plt.title(title)

plt.show()