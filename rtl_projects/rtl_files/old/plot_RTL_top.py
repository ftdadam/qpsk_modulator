#!python2.7
import numpy as np
from DSP import*
import matplotlib.pyplot as plt
from scipy import signal
import random

NB_OUT_MX = 8
NBF_OUT_MX = 6

# Behavoral simulation outputs

rtl_out_filter_infase = []
rtl_out_filter_quadrature = []

with open("file_out_tx_filter_infase_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_filter_infase.append( twos_comp(int(line),NB_OUT_MX ) )

with open("file_out_tx_filter_quadrature_from_top_rtl.txt", "r") as ins:
    for line in ins:
        rtl_out_filter_quadrature.append( twos_comp(int(line),NB_OUT_MX ) )

rtl_out_filter_infase = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_filter_infase,'S','trunc','saturate')
rtl_out_filter_quadrature = int2fix(int(NB_OUT_MX),int(NBF_OUT_MX),rtl_out_filter_quadrature,'S','trunc','saturate')

offset = 2
os = 16
Nbauds = 16

eyediagram(rtl_out_filter_infase[0:len(rtl_out_filter_infase)],int(os),int(offset),Nbauds,'b')
eyediagram(rtl_out_filter_quadrature[0:len(rtl_out_filter_quadrature)],int(os),int(offset),Nbauds,'b')

plt.show()