#!python2.7
import numpy as np
from DSP import*
import matplotlib.pyplot as plt
from scipy import signal
import random
import warnings
warnings.filterwarnings("ignore")

NB_OUT_MX = 8
NBF_OUT_MX = 6

# Behavoral simulation outputs

rtl_out_filter_infase = []
rtl_out_filter_quadrature = []
rtl_out_psk_infase = []
rtl_out_psk_quadrature = []
rtl_out_qpsk = []

rtl_out_filter_infase = np.zeros(0).tolist()
rtl_out_filter_quadrature = np.zeros(0).tolist()
rtl_out_psk_infase = np.zeros(109+80).tolist()
rtl_out_psk_quadrature = np.zeros(109+77).tolist()
rtl_out_qpsk = np.zeros(109).tolist()

with open("file_out_tx_filter_infase_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_filter_infase.append( twos_comp(int(line),NB_OUT_MX ) )

with open("file_out_tx_filter_quadrature_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_filter_quadrature.append( twos_comp(int(line),NB_OUT_MX ) )

with open("file_out_psk_infase_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_psk_infase.append( twos_comp(int(line),NB_OUT_MX ) )

with open("file_out_psk_quadrature_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_psk_quadrature.append( twos_comp(int(line),NB_OUT_MX ) )

with open("file_out_qpsk_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_qpsk.append( twos_comp(int(line),NB_OUT_MX ) )


rtl_out_filter_infase = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_filter_infase,'S','trunc','saturate')
rtl_out_filter_quadrature = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_filter_quadrature,'S','trunc','saturate')
rtl_out_psk_infase = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_psk_infase,'S','trunc','saturate')
rtl_out_psk_quadrature = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_psk_quadrature,'S','trunc','saturate')
rtl_out_qpsk = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_qpsk,'S','trunc','saturate')

# Fixed signals from python

py_fixv_out_filter_infase = np.zeros(82).tolist() #agregar latencias por el transitorio para plotear
py_fixv_out_filter_quadrature = np.zeros(82).tolist()
py_intv_out_infase_psk = np.zeros(0).tolist()
py_intv_out_quadrature_psk = np.zeros(0).tolist()
py_fixv_out_qpsk = np.zeros(0).tolist()

with open("py_fixv_out_filter_infase.txt", "r") as ins:
    for line in ins:
        py_fixv_out_filter_infase.append(float(line))

with open("py_fixv_out_filter_quadrature.txt", "r") as ins:
    for line in ins:
        py_fixv_out_filter_quadrature.append(float(line))

with open("py_fixv_out_infase_psk.txt", "r") as ins:
    for line in ins:
        py_intv_out_infase_psk.append(float(line))

with open("py_fixv_out_quadrature_psk.txt", "r") as ins:
    for line in ins:
        py_intv_out_quadrature_psk.append(float(line))

with open("py_fixv_out_qpsk.txt", "r") as ins:
    for line in ins:
        py_fixv_out_qpsk.append(float(line))

samples_to_show = [0,4000]
signal = []


title = 'Filter infase output'
plt.figure()
plt.plot(py_fixv_out_filter_infase,'r.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_filter_infase,'k.',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

title = 'Filter quadrature output'
plt.figure()
plt.plot(py_fixv_out_filter_quadrature,'r.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_filter_quadrature,'k.',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

offset = 2
os = 16
Nbauds = 16

eyediagram(rtl_out_filter_infase[0:len(rtl_out_filter_infase)],int(os),int(offset),Nbauds,'b')
eyediagram(rtl_out_filter_quadrature[0:len(rtl_out_filter_quadrature)],int(os),int(offset),Nbauds,'b')

title = 'PSK infase output'
plt.figure()
plt.plot(py_intv_out_infase_psk,'b.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_psk_infase,'r.-',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

title = 'PSK quadrature output'
plt.figure()
plt.plot(py_intv_out_quadrature_psk,'b.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_psk_quadrature,'r.-',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

title = 'QPSK output'
plt.figure()
plt.plot(py_fixv_out_qpsk,'b.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_qpsk,'r.-',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

plt.show()