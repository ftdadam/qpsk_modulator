# === LIBRARIES ===
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from DSP import *
# from mpl_toolkits.mplot3d import Axes3D
# import os
import warnings
warnings.filterwarnings("ignore")

def save_plot(title):
	global img_ptr
	global img_format
	title = title.replace(' ','_')
	title = title.replace(':','')
	title = title.lower()
	plt.savefig('modem_figures/' + str(img_ptr) + '_' + title + img_format, bbox_inches='tight')
	img_ptr = img_ptr + 1

# === PARAMETERS ===

Nsymb = 1000 # numero de simbolos para la prueba
os    = 16.0 # oversampling
Nbauds = 16.0 # numero de baudios del filtro
rolloff   = 0.2 # exceso de ancho de banda del filtro RRC
Tbaud = 1.0/(1024000.0)
Ts = Tbaud/os

img_ptr = 0
img_format = '.png'

# === DSP FLOAT POINT === 
filter_type = "RRC"

if(filter_type == "RRC"):
	(t,tx_filter) = rcosine(rolloff, Tbaud, os, Nbauds, Norm=False )  #Filtro en punto flotante
elif(filter_type == "SRRC"):
	(t,tx_filter) = rrcosine(rolloff, Tbaud, os, Nbauds, Norm=False )  #Filtro en punto flotante

symbols = np.random.choice([-1+1j, -1-1j, 1+1j, 1-1j],Nsymb)
symb_infase = np.zeros(int(os*Nsymb))
symb_infase[0:len(symb_infase):int(os)]=symbols.real
symb_quadrature = np.zeros(int(os*Nsymb))
symb_quadrature[0:len(symb_quadrature):int(os)]=symbols.imag
symb = symb_infase+1j*symb_quadrature

out_infase_filter = np.convolve(tx_filter,symb.real)
out_quadrature_filter = np.convolve(tx_filter,symb.imag)

# out_infase_filter = symb_infase
# out_quadrature_filter = symb_quadrature

# Nsamples = 2**5
Nsamples = 20

sin = []
cos = []

for t in range(0,len(out_infase_filter)):
	sin.append(np.sin( (2*np.pi/Nsamples) *t ))
	cos.append(np.cos( (2*np.pi/Nsamples) *t ))

out_infase_psk = out_infase_filter * cos
out_quadrature_psk = out_quadrature_filter * sin

out_qpsk = out_quadrature_psk+out_infase_psk

in_infase_psk = out_qpsk * sin
in_quadrature_psk = out_qpsk * sin

in_infase_filter = np.convolve(tx_filter,in_infase_psk)
in_quadrature_filter = np.convolve(tx_filter,in_quadrature_psk)


# ===== PLOTS =====

title = 'QPSK constelation'
plt.figure()
title = 'QPSK Symbols'
plt.scatter(symbols.real, symbols.imag)
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

eyediagram(out_infase_filter[100:len(symb_infase)-100],int(os),5,Nbauds,'b')
plt.xlabel('Tx out_filter')
title = 'Eye diagram TX out_filter'
plt.title(title)
save_plot(title)

eyediagram(out_quadrature_filter[100:len(symb_infase)-100],int(os),5,Nbauds,'b')
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
ax1.plot(in_infase_psk,'k.-',linewidth=1.0)
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