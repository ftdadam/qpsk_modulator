# === LIBRARIES ===
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from DSP import *
# from mpl_toolkits.mplot3d import Axes3D
# import os
import warnings
warnings.filterwarnings("ignore")

# === CUSTOM FUNCTIONS ===
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
	matrix = []
	w, h = 3, len(NB_vect)*len(NBF_vect)
	matrix = [[0 for x in range(w)] for y in range(h)] # [NB,NBF,SNR]    
	ptr = 0
	ptr2 = 0
	# plot_NB_vect = []
	plt.figure()
	for NB in NB_vect:     # Desde NB = 2 hasta NB = NB_test
		plot_NBF_vect = []
		plot_SNR_vect = []
		for NBF in NBF_vect:    # Desde parte fraccional NBF = 0 hasta NBF = NB+1
			fixed_signal = []
			fixed_signal_int = []
			fixed_signal, fixed_signal_int = float2fix(int(NB),int(NBF),float_signal,'S',mode,'saturate')
			matrix[ptr][0] = NB
			matrix[ptr][1] = NBF
			matrix[ptr][2] = 10*np.log10( np.dot(float_signal,float_signal)/(np.dot ( (float_signal-fixed_signal), (float_signal-fixed_signal) ) ) )
			if(matrix[ptr][2] == float('Inf')):
				matrix[ptr][2] = matrix[ptr-1][2]+12.0 #turbio, para que salga el plot solamente
			plot_NBF_vect.append(NBF)
			plot_SNR_vect.append(matrix[ptr][2])
			ptr = ptr + 1
		plt.plot(plot_NBF_vect,plot_SNR_vect,colors[NB],label='NB='+str(NB))
		plt.hold(True)
	plt.xticks(np.arange(NBF_vect[0],NBF_vect[-1]+1.0, 1.0))
	plt.grid()
	plt.legend(loc='upper left')
	plt.xlabel('NBF')
	plt.ylabel('SNR_q (dB)')
	plt.title(title)

	matrix = sorted(matrix,key=lambda x: x[2])
	# for ptr in range (0,h):
	# 	print matrix[ptr]

	NB_opt = matrix[h-1][0]
	NBF_opt = matrix[h-1][1]
	# NB_opt = 8
	# NBF_opt = 6
	fixed_signal_opt, fixed_signal_opt_int = float2fix(int(NB_opt),int(NBF_opt),float_signal,'S',mode,'saturate')
	return (NB_opt,NBF_opt,fixed_signal_opt,fixed_signal_opt_int)

def save_plot(title):
	global img_ptr
	global img_format
	title = title.replace(' ','_')
	title = title.replace(':','')
	title = title.lower()
	plt.savefig('figures/' + str(img_ptr) + '_' + title + img_format, bbox_inches='tight')
	img_ptr = img_ptr + 1

# === PARAMETERS ===

Nsymb = 1000 # numero de simbolos para la prueba
os    = 16.0 # oversampling
Nbauds = 16.0 # numero de baudios del filtro
rolloff   = 0.2 # exceso de ancho de banda del filtro RRC
Tbaud = 1.0/1024000.0
Ts = Tbaud/os

img_ptr = 0
img_format = '.png'

# === DSP FLOAT POINT === 
filter_type = "SRRC"

if(filter_type == "RRC"):
	(t,tx_filter) = rcosine(rolloff, Tbaud, os, Nbauds, Norm=False )  #Filtro en punto flotante
elif(filter_type == "SRRC"):
	(t,tx_filter) = rrcosine(rolloff, Tbaud, os, Nbauds, Norm=False )  #Filtro en punto flotante

random_data = False # FALSE for static simulation, not for algorithim verification
if(random_data):
	symbols = np.random.choice([-1+1j, -1-1j, 1+1j, 1-1j],Nsymb)
	symb_infase = np.zeros(int(os*Nsymb))
	symb_infase[0:len(symb_infase):int(os)]=symbols.real
	symb_quadrature = np.zeros(int(os*Nsymb))
	symb_quadrature[0:len(symb_quadrature):int(os)]=symbols.imag
	symb = symb_infase+1j*symb_quadrature
	file = open('files_float/random_symb_infase.txt','w')
	file2 = open('files_float/random_symb_quadrature.txt','w')
	for n in range (0,len(symb_infase)):
		file.write('%f\n' %symb_infase[n])
		file2.write('%f\n' %symb_quadrature[n])
	file.close()
else:
	symb_infase = []
	symb_quadrature = []
	with open("files_float/random_symb_infase.txt", "r") as ins:
		for line in ins:
			symb_infase.append(float(line))
	with open("files_float/random_symb_quadrature.txt", "r") as ins:
		for line in ins:
			symb_quadrature.append(float(line))
	symb_infase = np.array(symb_infase)
	symb_quadrature = np.array(symb_quadrature)
	symb = symb_infase+1j*symb_quadrature

out_infase_filter = np.convolve(tx_filter,symb.real)
out_quadrature_filter = np.convolve(tx_filter,symb.imag)

# # without filter
# out_infase_filter = symb_infase
# out_quadrature_filter = symb_quadrature

Nsamples = 20
EXP_RAM = 2**5

sin = []
cos = []
for t in range(0,len(out_infase_filter)):
	sin.append(np.sin( (2*np.pi/Nsamples) *t ))
	cos.append(np.cos( (2*np.pi/Nsamples) *t ))

out_infase_psk = out_infase_filter * cos
out_quadrature_psk = out_quadrature_filter * sin

out_qpsk = out_quadrature_psk+out_infase_psk

# === FILES FLOAT ===

file = open('files_float/filtered_signal.txt','w')
for n in range (0,len(out_infase_filter)):
	file.write('%f\n' %out_infase_filter[n])
file.close()

file = open('files_float/psk_signal.txt','w')
for n in range (0,len(out_infase_psk)):
	file.write('%f\n' %out_infase_psk[n])
file.close()

file = open('files_float/qpsk_signal.txt','w')
for n in range (0,len(out_infase_filter)):
	file.write('%f\n' %out_qpsk[n])
file.close()

# === FIXED POINT === 

title = 'Test SNR : Tx Filter'
(NB_opt,NBF_opt,tx_filter_fx,tx_filter_fx_int) = fx_opt_res(8,np.array(tx_filter),'round',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Tx filter Infase Output'
(NB_opt,NBF_opt,out_infase_filter_fx,out_infase_filter_fx_int) = fx_opt_res(8,np.convolve(tx_filter_fx,np.array(symb_infase)),'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Tx filter Quadrature Output'
(NB_opt,NBF_opt,out_quadrature_filter_fx,out_quadrature_filter_fx_int) = fx_opt_res(8,np.convolve(tx_filter_fx,np.array(symb_quadrature)),'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Sine'
(NB_opt,NBF_opt,sin_fx,sin_fx_int) = fx_opt_res(6,np.array(sin),'round',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Cosine'
(NB_opt,NBF_opt,cos_fx,cos_fx_int) = fx_opt_res(6,np.array(cos),'round',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Infase PSK Output'
(NB_opt,NBF_opt,out_infase_psk_fx,out_infase_psk_fx_int) = fx_opt_res(8,out_infase_filter_fx*cos_fx,'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Quadrature PSK Output'
(NB_opt,NBF_opt,out_quadrature_psk_fx,out_quadrature_psk_fx_int) = fx_opt_res(8,out_quadrature_filter_fx*sin_fx,'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: QPSK Output'
(NB_opt,NBF_opt,out_qpsk_fx,out_qpsk_fx_int) = fx_opt_res(8,out_infase_psk_fx+out_quadrature_psk_fx,'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

# === SIN & COS SIGNAL FOR RAM ===

# 
# sin_RAM = []
# cos_RAM = []

# for ptr in range (0,Nsamples):
# 	sin_RAM.append(np.sin( (2*np.pi/Nsamples) *ptr ))
# 	cos_RAM.append(np.cos( (2*np.pi/Nsamples) *ptr ))

# title = 'Test SNR: sin_RAM'
# (NB_opt,NBF_opt,sin_RAM_fx) = fx_opt_res(6,np.array(sin_RAM))
# title = 'Test SNR: cos_RAM'
# (NB_opt,NBF_opt,cos_RAM_fx) = fx_opt_res(6,np.array(cos_RAM))

# === FILES ===

file = open('files/py_intv_symb_infase.txt','w')
for n in range (0,len(symb_infase)):
	if(symb_infase[n] == 1):
		file.write('%d\n' %0)
	elif(symb_infase[n] == -1):
		file.write('%d\n' %1)
file.close()

file = open('files/py_intv_symb_quadrature.txt','w')
for n in range (0,len(symb_quadrature)):
	if(symb_quadrature[n] == 1):
		file.write('%d\n' %0)
	elif(symb_quadrature[n] == -1):
		file.write('%d\n' %1)
file.close()

file = open('files/py_intv_coef_filter.txt','w')
for n in range (0,len(tx_filter_fx)):
		file.write('%d\n' %tx_filter_fx_int[n])
file.close()

file = open('files/py_intv_out_filter_infase.txt','w')
file2 = open("../rtl_projects/rtl_files/py_fixv_out_filter_infase.txt",'w')
for n in range (0,len(out_infase_filter_fx)):
		file.write('%d\n' %out_infase_filter_fx_int[n])
		file2.write('%f\n' %out_infase_filter_fx[n])
file.close()
file2.close()

file = open('files/py_intv_out_filter_quadrature.txt','w')
file2 = open("../rtl_projects/rtl_files/py_fixv_out_filter_quadrature.txt",'w')
for n in range (0,len(out_quadrature_filter_fx)):
		file.write('%d\n' %out_quadrature_filter_fx_int[n])
		file2.write('%f\n' %out_quadrature_filter_fx[n])
file.close()
file2.close()

file = open('files/py_intv_out_infase_psk.txt','w')
file2 = open("../rtl_projects/rtl_files/py_fixv_out_infase_psk.txt",'w')
for n in range (0,len(out_infase_psk_fx)):
		file.write('%d\n' %out_infase_psk_fx_int[n])
		file2.write('%f\n' %out_infase_psk_fx[n])
file.close()
file2.close()

file = open('files/py_intv_out_quadrature_psk.txt','w')
file2 = open("../rtl_projects/rtl_files/py_fixv_out_quadrature_psk.txt",'w')
for n in range (0,len(out_quadrature_psk_fx)):
		file.write('%d\n' %out_quadrature_psk_fx_int[n])
		file2.write('%f\n' %out_quadrature_psk_fx[n])
file.close()
file2.close()

file = open('files/py_intv_out_qpsk_fx.txt','w')
file2 = open("../rtl_projects/rtl_files/py_fixv_out_qpsk.txt",'w')
for n in range (0,len(out_qpsk_fx)):
		file.write('%d\n' %out_qpsk_fx_int[n])
		file2.write('%f\n' %out_qpsk_fx[n])
file.close()
file2.close()

file = open('files/py_intv_sin_RAM.txt','w')
for n in range (0,EXP_RAM):
	if(n<Nsamples):
		file.write('%x\n' %sin_fx_int[n])
	else:
		file.write('%x\n' %0)
file.close()

file = open('files/py_intv_cos_RAM.txt','w')
for n in range (0,EXP_RAM):
	if(n<Nsamples):
		file.write('%x\n' %cos_fx_int[n])
	else:
		file.write('%x\n' %0)
file.close()

# === PLOTS ===

title = 'QPSK constelation'
plt.figure()
title = 'QPSK Symbols'
plt.scatter(symb.real[300:len(symb)], symb.imag[300:len(symb)])
plt.axis([-2, 2 , -2, 2])
plt.legend()
plt.grid(True)
plt.title(title)
save_plot(title)

title = 'Infase symbols with os'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h = signal.freqz(symb_infase)
ax1.plot(symb_infase,'ro')
ax1.set_xlim([300,340])
ax1.set_ylim([-1.5,1.5])
ax1.grid(True)
ax1.set_title('Time')
ax1.set_xlabel('samples')
ax1.set_ylabel('magnitude')
ax2.plot(w/np.pi,abs(h),'r-')
ax2.grid(True)
ax2.set_title('PSD')
ax2.set_xlabel('frecuency (norm to '+ r'$\pi$'+')' )
ax2.set_ylabel('magnitude')
# plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

title = 'RC Tx Filter'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h= signal.freqz(tx_filter)
ax1.plot(tx_filter,'r.-',linewidth=1.0,label=r'$\beta= %s$' %rolloff)
ax1.plot(tx_filter_fx,'k.',label = 'Fixed Point')
ax1.legend(loc='lower right')
ax1.set_xlim([0,len(tx_filter)-1])
ax1.grid(True)
ax1.set_title('Time')
ax1.set_xlabel('Tab')
ax1.set_ylabel('magnitude')
ax2.plot(w/np.pi,abs(h),'r-')
ax2.grid(True)
ax2.set_title('PSD')
ax2.set_xlabel('frecuency (norm to '+ r'$\pi$'+')' )
ax2.set_ylabel('magnitude')
# plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

eyediagram(out_infase_filter[300:len(symb_infase)-300],int(os),5,Nbauds,'b')
plt.xlabel('Tx out_filter')
title = 'Eye diagram TX out_filter'
plt.title(title)
save_plot(title)

eyediagram(out_quadrature_filter[300:len(symb_infase)-300],int(os),5,Nbauds,'b')
plt.xlabel('Tx out_filter')
title = 'Eye diagram TX out_filter'
plt.title(title)
save_plot(title)

samples_to_show = [300,800]

title = 'Tx filter infase output'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h= signal.freqz(out_infase_filter)
ax1.plot(out_infase_filter,'r.-',linewidth=1.0)
ax1.plot(out_infase_filter,'k.',label = 'Fixed Point')
ax1.set_xlim(samples_to_show)
ax1.grid(True)
ax1.set_title('Time')
ax1.set_xlabel('sample')
ax1.set_ylabel('magnitude')
ax2.plot(w/np.pi,abs(h),'r-')
ax2.grid(True)
ax2.set_title('PSD')
ax2.set_xlabel('frecuency (norm to '+ r'$\pi$'+')' )
ax2.set_ylabel('magnitude')
plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

title = 'PSK infase output'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h= signal.freqz(out_infase_psk)
ax1.plot(out_infase_psk,'r.-',linewidth=1.0)
ax1.plot(out_infase_psk,'k.',label = 'Fixed Point')
ax1.set_xlim(samples_to_show)
ax1.grid(True)
ax1.set_title('Time')
ax1.set_xlabel('sample')
ax1.set_ylabel('magnitude')
ax2.plot(w/np.pi,abs(h),'r-')
ax2.grid(True)
ax2.set_title('PSD')
ax2.set_xlabel('frecuency (norm to '+ r'$\pi$'+')' )
ax2.set_ylabel('magnitude')
plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

title = 'QPSK output'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h= signal.freqz(out_qpsk)
ax1.plot(out_qpsk,'r.-',linewidth=1.0)
ax1.plot(out_qpsk,'k.',label = 'Fixed Point')
ax1.set_xlim(samples_to_show)
ax1.grid(True)
ax1.set_title('Time')
ax1.set_xlabel('sample')
ax1.set_ylabel('magnitude')
ax2.plot(w/np.pi,abs(h),'r-')
ax2.grid(True)
ax2.set_title('PSD')
ax2.set_xlabel('frecuency (norm to '+ r'$\pi$'+')' )
ax2.set_ylabel('magnitude')
plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

title = 'sin & cos'
plt.figure()
plt.plot(sin[0:Nsamples],'r.-',linewidth=.75,label='sine')
plt.plot(cos[0:Nsamples],'b.-',linewidth=.75,label='cosine')
plt.xlim(0,Nsamples)
plt.grid(True)
plt.legend()
plt.xlabel('sample')
plt.ylabel('magnitude')
title = 'sine & cosine'
plt.title(title)
save_plot(title)

plt.show()