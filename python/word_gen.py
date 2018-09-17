# import numpy as np
# for elem in config:
# 	header += (str(unichr(elem)))

# text = "Lorem ipsu"
# text = header + text
# print text
# file = open('files/info_ram.txt','w')
# for char in text:
# 	file.write('%x\n' %ord(char))
# file.close()

# === hex file with original test symbols ===

from __future__ import print_function  # Only needed for Python 2

random_symb_infase = []
random_symb_quadrature = []
random_symb = []

with open("files/py_intv_symb_infase.txt", "r") as ins:
	for line in ins:
		random_symb_infase.append(int(line))

with open("files/py_intv_symb_quadrature.txt", "r") as ins:
	for line in ins:
		random_symb_quadrature.append(int(line))

for ptr in range (0,len(random_symb_infase)):
	random_symb.append(random_symb_infase[ptr])
	random_symb.append(random_symb_quadrature[ptr])

file = open('files/prbs_msg_hex.txt','w')
file2 = open('files/prbs_msg_addr.txt','w')
file3 = open('files/prbs_msg.txt','w')
for ptr in range(0,len(random_symb),8):
	b = 0
	a = []
	a = random_symb[ptr:ptr+8]
	b = b + a[0]*2**7
	b = b + a[1]*2**6
	b = b + a[2]*2**5
	b = b + a[3]*2**4
	b = b + a[4]*2**3
	b = b + a[5]*2**2
	b = b + a[6]*2**1
	b = b + a[7]*2**0
	file.write('%x\n' %b)
	file2.write('%x\n' %(ptr/8))
	print (chr(b),file =file3)
file.close()
file2.close()
file3.close()

# === test 