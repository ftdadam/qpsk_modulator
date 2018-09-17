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

rtl_out_psk_infase = []
rtl_out_psk_quadrature = []

rtl_out_psk_infase = np.zeros(0).tolist()
rtl_out_psk_quadrature = np.zeros(0).tolist()

with open("rtl_out_psk_infase.txt", "r") as ins:
    for line in ins:
        rtl_out_psk_infase.append( twos_comp(int(line),NB_OUT_MX ) )

with open("rtl_out_psk_quadrature.txt", "r") as ins:
    for line in ins:
        rtl_out_psk_quadrature.append( twos_comp(int(line),NB_OUT_MX ) )

rtl_out_psk_infase = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_psk_infase,'S','trunc','saturate')
rtl_out_psk_quadrature = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_psk_quadrature,'S','trunc','saturate')

# Fixed signals from python

py_intv_out_infase_psk = np.zeros(2).tolist()
py_intv_out_quadrature_psk = np.zeros(2).tolist()

with open("py_fixv_out_infase_psk.txt", "r") as ins:
    for line in ins:
        py_intv_out_infase_psk.append(float(line))

with open("py_fixv_out_quadrature_psk.txt", "r") as ins:
    for line in ins:
        py_intv_out_quadrature_psk.append(float(line))


samples_to_show = [0,800]
signal = []

title = 'PSK infase output'
plt.figure()
plt.plot(py_intv_out_infase_psk,'r.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_psk_infase,'k.',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

title = 'PSK quadrature output'
plt.figure()
plt.plot(py_intv_out_quadrature_psk,'r.-',linewidth=1.0,label="Fixed Point")
plt.plot(rtl_out_psk_quadrature,'k.',linewidth=1.0,label="RTL")
plt.legend()
plt.xlim(samples_to_show)
plt.grid(True)
plt.title(title)
plt.xlabel('sample')
plt.ylabel('magnitude')

plt.show()