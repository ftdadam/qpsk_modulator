import sys
import os
os.system('cls')
print 'Starting |                    | 0%'
import time
os.system('cls')
print 'Starting |####                | 20%'
import serial
os.system('cls')
print 'Starting |########            | 40%'
import numpy as np
os.system('cls')
print 'Starting |############        | 60%'
import matplotlib.pyplot as plt
os.system('cls')
print 'Starting |################    | 80%'
# from mpl_toolkits.mplot3d import Axes3D
os.system('cls')
print 'Starting |####################| 100%'
from DSP import*
os.system('cls')
print 'Ready'


# ============================================ Function ============================================
enb = 0
delay = 0.002*5
ctrl_tx_reg = 0
GPIO_command = 0
addr = 0
data = 0
os    = 4 # oversampling
offset = 0
Nbauds = 8 # numero de baudios del filtro
rolloff   = 0.5 # exceso de ancho de banda del filtro RRC
Tbaud = 1.0/1024000.0
Ts = Tbaud/os

out_filter_infase_fx = []
out_filter_quadrature_fx = []
out_psk_infase_fx = []
out_psk_quadrature_fx = []
out_qpsk_fx = []

def write_GPIO(c, e, a, d):
    # print c, a, d
    GPIO_command = c << 24 | e << 23 | a << 8 | d << 0
    for ptr in range(0,4):
        valor = (GPIO_command>>(8*ptr)) & (0xFF)
        ser.write(chr(valor))
    return

def read_files():
	global out_filter_infase_fx
	global out_filter_quadrature_fx
	global out_psk_infase_fx
	global out_psk_quadrature_fx
	global out_qpsk_fx

	out_filter_infase_fx = []
	out_filter_quadrature_fx = []
	out_psk_infase_fx = []
	out_psk_quadrature_fx = []
	out_qpsk_fx = []

	with open("files_FPGA/out_filter_infase_fx.txt", "r") as ins:	
		for line in ins:
			out_filter_infase_fx.append(float(line))

	with open("files_FPGA/out_filter_quadrature_fx.txt", "r") as ins:
		for line in ins:
			out_filter_quadrature_fx.append(float(line))

	with open("files_FPGA/out_psk_infase_fx.txt", "r") as ins:
		for line in ins:
			out_psk_infase_fx.append(float(line))

	with open("files_FPGA/out_psk_quadrature_fx.txt", "r") as ins:
		for line in ins:
			out_psk_quadrature_fx.append(float(line))

	with open("files_FPGA/out_qpsk_fx.txt", "r") as ins:
		for line in ins:
			out_qpsk_fx.append(float(line))
def enb_RF():
	global enb
	enb = 1
	write_GPIO(0, enb, 0, 0)
def dbl_RF():
	global enb
	enb = 0
	write_GPIO(0, enb, 0, 0)
def dbl_RAM_write():
	global enb
	write_GPIO(0, enb, 0, 0)
def enb_RAM_write():
	global enb
	write_GPIO(1, enb, 0, 0)
def rst_RAM_output():
	global enb
	write_GPIO(2, enb, 0, 0)
def set_RAM_output():
	global enb
	write_GPIO(3, enb, 0, 0)
def set_RAM_output():
	global enb
	write_GPIO(4, enb, 0, 0)
def dbl_RAM_output():
	global enb
	write_GPIO(5, enb, 0, 0)
def enb_RAM_read():
	global enb
	write_GPIO(6, enb, 0, 0)
def dbl_RAM_read():
	global enb
	write_GPIO(7, enb, 0, 0)
def rst_addr_counter():
	global enb
	write_GPIO(34, enb, 0, 0)
def write_coef_to_RAM(addr,data):
	global enb
	# print addr, data
	write_GPIO(32, enb, addr, data)
def write_coef_to_SR():
	global enb
	write_GPIO(33, enb, 0, 0)
def enb_write_info_RAM():
	global enb
	write_GPIO(36, enb, 0, 0)
def dbl_write_info_RAM():
	global enb
	write_GPIO(37, enb, 0, 0)
def set_msg_long(addr):
	global enb
	write_GPIO(38, enb, addr, 0)
def set_filter_type(tipo):
	global enb
	write_GPIO(39, enb, 0, tipo)
def enb_tx():
	global enb, ctrl_tx_reg
	ctrl_tx_reg = ctrl_tx_reg | (0b00000001)
	write_GPIO(16, enb, 0, ctrl_tx_reg)
def rst_tx():
	global enb, ctrl_tx_reg
	ctrl_tx_reg = ctrl_tx_reg | (0b00000010)
	write_GPIO(16, enb, 0, ctrl_tx_reg)
def dbl_tx():
	global enb, ctrl_tx_reg
	ctrl_tx_reg = ctrl_tx_reg & (0b11111110)
	write_GPIO(16, enb, 0, ctrl_tx_reg)
def set_tx():
	global enb, ctrl_tx_reg
	ctrl_tx_reg = ctrl_tx_reg & (0b11111101)
	write_GPIO(16, enb, 0, ctrl_tx_reg)
def write_filter_to_ram():
	global enb
	write_GPIO(47, enb, 0, 0)
def write_psk_to_ram():
	global enb
	write_GPIO(48, enb, 0, 0)
def write_qpsk_to_ram():
	global enb
	write_GPIO(49, enb, 0, 0)
def read_RAM(addr):
	global enb
	write_GPIO(50, enb, addr, 0)
def write_info_ram(addr,data):
	global enb
	write_GPIO(35, enb, addr, data)
def rst_aux_counter():
	global enb
	write_GPIO(30, enb, 0, 0)
def uart_read_request():
	global enb
	write_GPIO(31,enb,0,0)
	time.sleep(delay)
	rst_aux_counter()

# ============================================ Serial Port ============================================

print 'Enter serial port number:\r'
serial_port = raw_input("<< ")
# serial_port = 'COM4'
if(serial_port != '' ):
	ser = serial.Serial(
	    port = 'COM' + serial_port,
	    #port='COM4',	#Configurar con el puerto
	    baudrate=9600,
	    parity=serial.PARITY_NONE,
	    stopbits=serial.STOPBITS_ONE,
	    bytesize=serial.EIGHTBITS
	)
	ser.isOpen()
	ser.timeout = 1
	print 'Communication Established\n'
	#print(ser.timeout)
else:
	print 'Communication Override\n'

# ==================================================== COEF ====================================================

coef_SRRC = []
with open('files/py_intv_coef_filter.txt') as ins:
	for line in ins:
		coef_SRRC.append(int(line))

coef_RRC = []
with open('files/py_intv_coef_filter_RRC.txt') as ins:
	for line in ins:
		coef_RRC.append(int(line))

#coef = [127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127]
#coef = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]

read_files()

# ==================================================== Main ====================================================

while 1:
	print 'Enter command:\r'
	input = raw_input("<< ")

	if input == 'exit':
	    if(serial_port != '' ):
	    	ser.close()
	    exit()
# ============================ Enable RF ============================
	elif input == 'enb_RF':
		enb_RF()
	elif input == 'dbl_RF':
		dbl_RF()
# ============================ RAM commands ============================
	elif input == 'dbl_write':
		dbl_RAM_write()
	elif input == 'enb_RAM_write':
		enb_RAM_write()
	elif input == 'rst_RAM_output':
		rst_RAM_output()
	elif input == 'set_RAM_output':
		set_RAM_output()
	elif input == 'enb_RAM_output':
		enb_RAM_output()
	elif input == 'dbl_RAM_output':
		dbl_RAM_output()
	elif input == 'enb_RAM_read':
		enb_RAM_read()
	elif input == 'dbl_RAM_read':
		dbl_RAM_read()
# ============================ Coef Control ============================
	elif input == 'load_coef':
		global coef_RRC
		global coef_SRRC
		coef_aux = []
		filter_type = raw_input("RRC or SRRC?<< ")
		if(filter_type == "RRC"):
			set_filter_type(0)
			enb_RAM_write()
			time.sleep(delay)
			rst_addr_counter()
			time.sleep(delay)
			coef_aux = coef_RRC + coef_RRC # dos veces para los dos filtros
			for ptr in range (0,len(coef_aux)):
				write_coef_to_RAM(ptr,coef_aux[ptr])
				time.sleep(delay)
			write_coef_to_SR()
		elif(filter_type == "SRRC"):
			set_filter_type(1)
			enb_RAM_write()
			time.sleep(delay)
			rst_addr_counter()
			time.sleep(delay)
			coef_aux = coef_SRRC + coef_SRRC # dos veces para los dos filtros
			for ptr in range (0,len(coef_aux)):
				write_coef_to_RAM(ptr,coef_aux[ptr])
				time.sleep(delay)
			write_coef_to_SR()
		else:
			print "Invalid filter type"
# ============================ Tx Control ============================
	elif input == 'enb_tx':
		enb_tx()
	elif input == 'rst_tx':
		rst_tx()
	elif input == 'dbl_tx':
		dbl_tx()
	elif input == 'set_tx':
		set_tx()
	elif input == 'rst_addr_counter':
		rst_addr_counter()
	elif input == 'enb_write_info_RAM':
		enb_write_info_RAM()
	elif input == 'dbl_write_info_RAM':
		dbl_write_info_RAM()
# ============================ Write Message ============================
	elif input == 'set_msg':
		header = np.zeros(10).tolist()
		text = []
		intv_text = []

		# with open ("files/0_msg.txt",'r') as ins:
		with open ("files/prbs_msg.txt",'r') as ins:
			for line in ins:
				text.append(line)

		for elem in header:
			intv_text.append(int(elem))
		for line in text:
			for char in line:
				intv_text.append(ord(char))

		if(len(intv_text)>2**15):
			intv_text = intv_text[0:2**15]
		msg_long = len(intv_text)

		set_tx()
		dbl_tx()
		enb_write_info_RAM()
		
		for ptr in range (0,msg_long):
			write_info_ram(ptr,intv_text[ptr])
			time.sleep(delay)

		# file = open("files/msg_hex.txt",'w')
		# for d in intv_text:
		# 	file.write('%x\n' %d)
		# file.close()

		set_msg_long(msg_long)

# ============================ Log FILTER ============================

	elif (input == 'log_filter'): #copiar para las otras seniales
		data_infase = []
		data_quadrature = []

		enb_RAM_write()
		time.sleep(delay)
		rst_addr_counter()
		time.sleep(delay)
		write_filter_to_ram()	# write RAM
		
		time.sleep(delay*10)

		cant = 2**10
		percent = -10

		rst_aux_counter()

		for ptr in range (0,cant):
			read_RAM(ptr)
			
			uart_read_request()

			uart_rx = ser.read(1) 	# filter_infase
			data_infase.append(ord(uart_rx))

			uart_rx = ser.read(1) 	# zeros

			uart_rx = ser.read(1) 	# filter_quadrature
			data_quadrature.append(ord(uart_rx))

			uart_rx = ser.read(1) 	# zeros

			if( ptr % int(((cant)/10)) == 0):
				percent = percent + 10
				if(percent <= 100):
					sys.stdout.write("\r" + "Log: " + str(percent) + '%' )
					sys.stdout.flush()

		rst_aux_counter()

		# Conversion a punto fijo
		
		NB_OUT_FILTER = 8
		NBF_OUT_FILTER = 6

		for ptr in range(0,len(data_infase)):
			data_infase[ptr] = twos_comp(int(data_infase[ptr]),NB_OUT_FILTER)
			data_quadrature[ptr] = twos_comp(int(data_quadrature[ptr]),NB_OUT_FILTER)
		data_infase = int2fix(int(NB_OUT_FILTER),int(NBF_OUT_FILTER),data_infase,'S','trunc','saturate')
		data_quadrature = int2fix(int(NB_OUT_FILTER),int(NBF_OUT_FILTER),data_quadrature,'S','trunc','saturate')

		file = open("files_FPGA/out_filter_infase_fx.txt",'w')
		for d in data_infase:
			file.write('%f\n' %d)
		file.close()

		file = open("files_FPGA/out_filter_quadrature_fx.txt",'w')
		for d in data_quadrature:
			file.write('%f\n' %d)
		file.close()

		read_files()

		print " >> " + "log ready!"

# ============================ Log PSK ============================

	elif (input == 'log_psk'): #copiar para las otras seniales
		data_infase = []
		data_quadrature = []

		enb_RAM_write()
		time.sleep(delay)
		rst_addr_counter()
		time.sleep(delay)
		write_psk_to_ram()	# write RAM
		
		time.sleep(delay*10)

		cant = 2**11
		percent = -10

		rst_aux_counter()

		for ptr in range (0,cant):
			read_RAM(ptr)
			
			uart_read_request()

			uart_rx = ser.read(1) 	# psk_quadrature
			data_quadrature.append(ord(uart_rx))

			# time.sleep(delay)
			uart_rx = ser.read(1) 	# zeros
			
			uart_rx = ser.read(1) 	# psk_infase
			data_infase.append(ord(uart_rx))

			uart_rx = ser.read(1) 	# zeros

			if( ptr % int(((cant)/10)) == 0):
				percent = percent + 10
				if(percent <= 100):
					sys.stdout.write("\r" + "Log: " + str(percent) + '%' )
					sys.stdout.flush()

		rst_aux_counter()

		# Conversion a punto fijo
		
		NB_MIXER = 8
		NBF_MIXER = 6


		for ptr in range(0,len(data_infase)):
			data_infase[ptr] = twos_comp(int(data_infase[ptr]),NB_MIXER)
			data_quadrature[ptr] = twos_comp(int(data_quadrature[ptr]),NB_MIXER)
		data_infase = int2fix(int(NB_MIXER),int(NBF_MIXER),data_infase,'S','trunc','saturate')
		data_quadrature = int2fix(int(NB_MIXER),int(NBF_MIXER),data_quadrature,'S','trunc','saturate')

		file = open("files_FPGA/out_psk_infase_fx.txt",'w')
		for d in data_infase:
			file.write('%f\n' %d)
		file.close()

		file = open("files_FPGA/out_psk_quadrature_fx.txt",'w')
		for d in data_quadrature:
			file.write('%f\n' %d)
		file.close()

		read_files()

		print " >> " + "log ready!"

# ============================ Log QPSK ============================

	elif (input == 'log_qpsk'): #copiar para las otras seniales
		data = []

		enb_RAM_write()
		time.sleep(delay)
		rst_addr_counter()
		time.sleep(delay)
		write_qpsk_to_ram()	# write RAM
		
		time.sleep(delay*10)

		cant = 2**11
		percent = -10

		rst_aux_counter()

		for ptr in range (0,cant):
			read_RAM(ptr)
			
			uart_read_request()

			uart_rx = ser.read(1) 	# qpsk
			data.append(ord(uart_rx))

			# time.sleep(delay)
			uart_rx = ser.read(1) 	# zeros
			
			uart_rx = ser.read(1) 	# qpsk

			uart_rx = ser.read(1) 	# zeros

			if( ptr % int(((cant)/10)) == 0):
				percent = percent + 10
				if(percent <= 100):
					sys.stdout.write("\r" + "Log: " + str(percent) + '%' )
					sys.stdout.flush()

		rst_aux_counter()
		# Conversion a punto fijo
		
		NB_ADDER = 8
		NBF_ADDER = 6

		for ptr in range(0,len(data)):
			data[ptr] = twos_comp(int(data[ptr]),NB_ADDER)
		data = int2fix(int(NB_ADDER),int(NBF_ADDER),data,'S','trunc','saturate')

		file = open("files_FPGA/out_qpsk_fx.txt",'w')
		for d in data:
			file.write('%f\n' %d)
		file.close()

		read_files()

		print " >> " + "log ready!"

# ============================ Plots ============================

	elif input == 'read_files':
		read_files()

	# elif input == 'eyes':
	# 	for ptr in range (0,os):
	# 		eyediagrams(out_filter_quadrature_fx[0:len(out_filter_quadrature_fx)],out_filter_infase_fx[0:len(out_filter_infase_fx)],int(os),int(ptr),Nbauds,'b')

	elif input == 'eye_i':
		eyediagram(out_filter_infase_fx[0:len(out_filter_infase_fx)],int(os),int(offset),Nbauds,'b')
		plt.show()
	
	elif input == 'eye_q':
		eyediagram(out_filter_quadrature_fx[0:len(out_filter_quadrature_fx)],int(os),int(offset),Nbauds,'b')
		plt.show()

	elif input == 'const':
		for ptr in range (0,os):
			plt.figure()
			plt.plot(out_filter_infase_fx[50+ptr:len(out_filter_infase_fx)-50-ptr:int(os)], 
					 out_filter_quadrature_fx[50+ptr:len(out_filter_quadrature_fx)-50-ptr:int(os)],'.r'
					 )
			plt.title('Offset de Fase=%d' % ptr)
			plt.xlabel('Constelacion QPSK')
			plt.grid(True)
			limit = 2
			plt.axis([-limit, limit , -limit, limit])
		plt.show()

	elif input == 'signal_filter':
		title = 'Output filter infase'
		plt.figure()
		plt.title(title)
		plt.plot(out_filter_infase_fx,'r.-',linewidth=1.0)
		plt.xlabel('Tension')
		plt.xlabel('Muestras')
		plt.grid(True)
		title = 'Output filter quadrature'
		plt.figure()
		plt.title(title)
		plt.plot(out_filter_quadrature_fx,'r.-',linewidth=1.0)
		plt.xlabel('Tension')
		plt.xlabel('Muestras')
		plt.grid(True)
		plt.show()

	elif input == 'signal_psk':
		title = 'Output psk infase'
		plt.figure()
		plt.title(title)
		plt.plot(out_psk_infase_fx,'r.-',linewidth=1.0)
		plt.xlabel('Tension')
		plt.xlabel('Muestras')
		plt.grid(True)
		title = 'Output psk quadrature'
		plt.figure()
		plt.title(title)
		plt.plot(out_psk_quadrature_fx,'r.-',linewidth=1.0)
		plt.xlabel('Tension')
		plt.xlabel('Muestras')
		plt.grid(True)
		plt.show()

	elif input == 'signal_q	psk':
		title = 'Output QPSK'
		plt.figure()
		plt.title(title)
		plt.plot(out_qpsk_fx,'r.-',linewidth=1.0)
		plt.xlabel('Tension')
		plt.xlabel('Muestras')
		plt.grid(True)
		plt.show()

	elif input == 'show_plots':
		plt.show()
		
# ============================ Aux ============================

	elif input == 'clear':
		os.system('cls')

	else:
		print ">> Wrong command" 