# === LIBRARIES ===
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from tool.DSP import*
import os
# import warnings
# warnings.filterwarnings("ignore")

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
    NB = np.zeros(NB_test)
    NBF = np.zeros(NB_test)
    SNR_maxs = np.empty(NB_test)
    SNR_maxs.fill('nan')
    plt.figure()
    for ptr in range (2,NB_test+1):     # Desde NB = 2 hasta NB = NB_test
        SNR=np.empty(ptr+2)             # Definicion de un float_signal para alojar los valores del SNR
        SNR.fill('nan')
        for ptr2 in range (0,ptr+2):    # Desde parte fraccional NBF = 0 hasta NBF = NB+1
            fixed_signal = []
            fixed_signal = fix2append(fx.arrayFixedInt(ptr,ptr2,float_signal,'S',mode,'saturate'))
            SNR[ptr2] = np.dot(float_signal,float_signal)/(np.dot ( (float_signal-fixed_signal), (float_signal-fixed_signal) ) )
            if(SNR[ptr2] == float('Inf')):
                SNR[ptr2] = SNR[ptr2-1]*20 # Turbio... para que salga en el plot solamente
        # Los siguientes tres vectores combinados tienen toda la informacion para saber la resolucion optima    
        NB [ptr-1] = ptr             # vector que guarda NB en cada prueba
        NBF [ptr-1] = np.argmax(SNR)    # vector que guarda NBF para el SNR maximos para cada prueba
        SNR_maxs[ptr-1] = np.max(SNR)    # vector que guarda el valor de los SNR maximos para cada prueba
        # Generacion de la grafica en cada iteracion
        plt.plot(10*np.log10(SNR),colors[ptr-1],label='NB=%s' %ptr)
        plt.title(title)
        plt.grid()
        plt.legend(loc='upper left')
        plt.xlabel('NBF')
        plt.ylabel('SNR (dB)')
        plt.hold(True)
    # el index del supremo (el maximo del float_signal SNR_maxs) dara la resolucion optima

    NB_opt = NB[np.nanargmax(SNR_maxs)] 
    NBF_opt = NBF[np.nanargmax(SNR_maxs)]
    fixed_signal_opt = arrayFixedInt(int(NB_opt),int(NBF_opt),float_signal,'S',mode,'saturate')

    return (NB_opt,NBF_opt,fixed_signal_opt)

def save_plot(title):
	global img_ptr
	global img_format
	title = title.replace(' ','_')
	title = title.replace(':','-')
	title = title.lower()
	plt.savefig('figures/' + str(img_ptr) + '_' + title + img_format, bbox_inches='tight')
	img_ptr = img_ptr + 1

# === PARAMETERS ===

Nsymb = 1000 # numero de simbolos para la prueba
os    = 4.0 # oversampling
Nbauds = 8.0 # numero de baudios del filtro
rolloff   = 0.5 # exceso de ancho de banda del filtro RRC
Tbaud = 1.0/1024000.0
Ts = Tbaud/os

img_ptr = 0
img_format = '.png'

# === DSP FLOAT POINT === 

(t,tx_filter) = rrcosine(rolloff, Tbaud, os, Nbauds, Norm=False )  #Filtro en punto flotante

symbols = np.random.choice([-1+1j, -1-1j, 1+1j, 1-1j],Nsymb)

symb_infase = np.zeros(int(os*Nsymb))
symb_infase[0:len(symb_infase):int(os)]=symbols.real
symb_quadrature = np.zeros(int(os*Nsymb))
symb_quadrature[0:len(symb_quadrature):int(os)]=symbols.imag
symb = symb_infase+1j*symb_quadrature

out_infase_filter = np.convolve(tx_filter,symb.real)
out_quadrature_filter = np.convolve(tx_filter,symb.imag)

# # without filter
# out_infase_filter = symb_infase
# out_quadrature_filter = symb_quadrature

Nsamples = 2**8

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
(NB_opt,NBF_opt,tx_filter_fx) = fx_opt_res(8,np.array(tx_filter),'round',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Tx filter Infase Output'
(NB_opt,NBF_opt,out_infase_filter_fx) = fx_opt_res(8,np.convolve(fix2array(tx_filter_fx),np.array(symb_infase)),'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Tx filter Quadrature Output'
(NB_opt,NBF_opt,out_quadrature_filter_fx) = fx_opt_res(8,np.convolve(fix2array(tx_filter_fx),np.array(symb_quadrature)),'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Sine'
(NB_opt,NBF_opt,sin_fx) = fx_opt_res(6,np.array(sin),'round',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Cosine'
(NB_opt,NBF_opt,cos_fx) = fx_opt_res(6,np.array(cos),'round',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Infase PSK Output'
(NB_opt,NBF_opt,out_infase_psk_fx) = fx_opt_res(8,fix2array(out_infase_filter_fx)*fix2array(cos_fx),'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: Quadrature PSK Output'
(NB_opt,NBF_opt,out_quadrature_psk_fx) = fx_opt_res(8,fix2array(out_quadrature_filter_fx)*fix2array(sin_fx),'trunc',title)
print title,': ',NB_opt,NBF_opt
save_plot(title)

title = 'Test SNR: QPSK Output'
(NB_opt,NBF_opt,out_qpsk_fx) = fx_opt_res(8,fix2array(out_infase_psk_fx)+fix2array(out_quadrature_psk_fx),'trunc',title)
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

file = open('files/0_symb_infase.txt','w')
for n in range (0,len(symb_infase)):
	if(symb_infase[n] == 1):
		file.write('%d\n' %0)
	elif(symb_infase[n] == -1):
		file.write('%d\n' %1)
file.close()

file = open('files/0_symb_quadrature.txt','w')
for n in range (0,len(symb_quadrature)):
	if(symb_quadrature[n] == 1):
		file.write('%d\n' %0)
	elif(symb_quadrature[n] == -1):
		file.write('%d\n' %1)
file.close()

file = open('files/1_tx_filter_fx.txt','w')
for n in range (0,len(tx_filter_fx)):
		file.write('%d\n' %tx_filter_fx[n].intvalue)
file.close()

file = open('files/2_out_infase_filter_fx.txt','w')
for n in range (0,len(out_infase_filter_fx)):
		file.write('%d\n' %out_infase_filter_fx[n].intvalue)
file.close()


file = open('files/3_out_quadrature_filter_fx.txt','w')
for n in range (0,len(out_quadrature_filter_fx)):
		file.write('%d\n' %out_quadrature_filter_fx[n].intvalue)
file.close()

file = open('files/4_out_infase_psk_fx.txt','w')
for n in range (0,len(out_infase_psk_fx)):
		file.write('%d\n' %out_infase_psk_fx[n].intvalue)
file.close()

a = fix2array(out_infase_psk_fx)
file = open("../rtl_projects/rtl_files/out_psk_infase_fx.txt",'w')
for n in range (0,len(a)):
		file.write('%f\n' %a[n])
file.close()

file = open('files/4_out_quadrature_psk_fx.txt','w')
for n in range (0,len(out_quadrature_psk_fx)):
		file.write('%d\n' %out_quadrature_psk_fx[n].intvalue)
file.close()

file = open('files/5_out_qpsk_fx.txt','w')
for n in range (0,len(out_qpsk_fx)):
		file.write('%d\n' %out_qpsk_fx[n].intvalue)
file.close()

a = fix2array(out_qpsk_fx)
file = open("../rtl_projects/rtl_files/out_qpsk_fx.txt",'w')
for n in range (0,len(a)):
		file.write('%f\n' %a[n])
file.close()

file = open('files/6_sin_RAM_fx.txt','w')
for n in range (0,Nsamples):
		file.write('%x\n' %sin_fx[n].intvalue)
file.close()

file = open('files/6_cos_RAM_fx.txt','w')
for n in range (0,Nsamples):
		file.write('%x\n' %cos_fx[n].intvalue)
file.close()

# === PLOTS ===

plot_fixed = 0 # booleano, plotear en punto fijo

# title = 'QPSK constelation'
# plt.figure()
# title = 'QPSK Symbols'
# plt.scatter(symbols.real, symbols.imag)
# plt.axis([-2, 2 , -2, 2])
# plt.legend()
# plt.grid(True)
# plt.title(title)
# save_plot(title)

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
plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

title = 'RRC Tx Filter'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h= signal.freqz(tx_filter)
ax1.plot(tx_filter,'r.-',linewidth=1.0,label=r'$\beta= %s$' %rolloff)
if(plot_fixed):
	ax1.plot(tx_filter_fx,'k.')
ax1.legend()
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
plt.get_current_fig_manager().window.showMaximized()
save_plot(title)

# eyediagram(out_infase_filter[100:len(symb_infase)-100],int(os),5,Nbauds,'b')
# plt.xlabel('Tx out_qpsk')
# title = 'Eye diagram - TX out_qpsk'
# plt.title(title)
# save_plot(title)

samples_to_show = [300,800]

title = 'Tx filter infase output'
f, (ax1, ax2) = plt.subplots(1, 2)
f.suptitle(title)
w, h= signal.freqz(out_infase_filter)
ax1.plot(out_infase_filter,'r.-',linewidth=1.0)
if(plot_fixed):
	ax1.plot(out_infase_filter,'k.')
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
if(plot_fixed):
	ax1.plot(out_infase_psk,'k.')
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
if(plot_fixed):
	ax1.plot(out_qpsk,'k.')
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
plt.plot(sin,'r.-',linewidth=.75,label='sine')
plt.plot(cos,'b.-',linewidth=.75,label='cosine')
plt.xlim(0,len(sin))
plt.grid(True)
plt.legend()
plt.xlabel('sample')
plt.ylabel('magnitude')
title = 'sine & cosine'
plt.title(title)
save_plot(title)

plt.show()