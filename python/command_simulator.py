import numpy as np

coef = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,0,0,0,1,1,1,2,2,2,2,2,2,1,1,1,0,255,255,254,254,253,253,252,252,252,253,253,254,254,255,0,1,2,4,5,5,6,7,7,7,6,5,4,3,1,255,253,251,249,247,246,244,243,243,243,243,245,247,249,253,1,5,11,16,22,28,34,40,46,51,56,60,63,66,67,67,67,66,63,60,56,51,46,40,34,28,22,16,11,5,1,253,249,247,245,243,243,243,243,244,246,247,249,251,253,255,1,3,4,5,6,7,7,7,6,5,5,4,2,1,0,255,254,254,253,253,252,252,252,253,253,254,254,255,255,0,1,1,1,2,2,2,2,2,2,1,1,1,0,0,0,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
coef = coef*2

ctrl_tx_reg = 0

file = open('files/sim_command.txt','w')



# === enb_RF
c = 0
e = 1
a = 0
d = 0
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
file.write('%d\n' %GPIO_command)

# === load_coef

# set_filter_type
c = 39
e = 1
a = 0
d = 1 #SRRC
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
file.write('%d\n' %GPIO_command)

# enable_RAM_write
c = 1
e = 1
a = 0
d = 0
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
file.write('%d\n' %GPIO_command)

# rst_addr_counter
c = 34
e = 1
a = 0
d = 0
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
file.write('%d\n' %GPIO_command)

# write_coef_to_RAM

for ptr in range (0,len(coef)):
	c = 32
	e = 1
	a = ptr
	d = coef[ptr]
	GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
	file.write('%d\n' %GPIO_command)

# write_coef_to_SR
c = 33
e = 1
a = 0
d = 0
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
for ptr in range(1,250):
	file.write('%d\n' %GPIO_command)

# === set_msg

# # set tx

# ctrl_tx_reg = ctrl_tx_reg & (0b11111101)
# c = 16
# e = 1
# a = 0
# d = ctrl_tx_reg
# GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
# file.write('%d\n' %GPIO_command)

# # dbl tx

# ctrl_tx_reg = ctrl_tx_reg & (0b11111110)
# c = 16
# e = 1
# a = 0
# d = ctrl_tx_reg
# GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
# file.write('%d\n' %GPIO_command)

# # enb info ram write

# c = 36
# e = 1
# a = 0
# d = ctrl_tx_reg
# GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
# file.write('%d\n' %GPIO_command)


# # write info ram


# for ptr in range(0,51):
# 	c = 35
# 	e = 1
# 	a = ptr
# 	d = ptr+15
# 	GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
# 	file.write('%d\n' %GPIO_command)

# set msg long

c = 38
e = 1
# a = 881
a = 249
d = 0
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
file.write('%d\n' %GPIO_command)

# === enb_tx

ctrl_tx_reg = ctrl_tx_reg | (0b00000001)
c = 16
e = 1
a = 0
d = ctrl_tx_reg
GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
for ptr in range(1,5000):
	file.write('%d\n' %GPIO_command)

file.close()

# === errores op amp ====

# Ad = 15000
# Vos = 6.2e-3
# Ios = 1e-9
# RRMC = 100e6
# FS = 3.3
# alpha = 1.0
# R = 1e3

# vo_Ios = alpha*R*Ios
# vo_Vos = (1+alpha)*Vos
# vo_Ad = FS*(1+alpha)/Ad
# vo_RRMC = FS/RRMC

# vo_total = vo_Ios+vo_Vos+vo_Ad+vo_RRMC
# print vo_total

# n = np.log2(FS/vo_total)

# print n