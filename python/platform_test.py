import sys
import os
#clear = lambda: os.system('cls')
os.system('cls')
#clear ()
print 'Starting |                    | 0%'
import time
os.system('cls')
#clear ()
print 'Starting |####                | 20%'
import serial
os.system('cls')
#clear ()
print 'Starting |####################| 100%'
os.system('cls')
print 'Ready'
#%matplotlib inline


# ============================================ Function ============================================

def write_GPIO(a, b, c, d):
    GPIO_command = a << 24 | b << 16 | c << 8 | d <<0
    for ptr in range(0, 4):
        valor = (GPIO_command>>(8*ptr)) & (0xFF)
        print valor
        ser.write(chr(valor))
        time.sleep(delay)
        #print ">> " + str (valor)
    return


# ============================================ Variables y Parametros ============================================

enb = 0
delay = 0.002
os = 4
Nbauds = 8
beta = 0.5
Tbaud = 1.0/1024000.0
offset = 3
datos_i = []
datos_q = []
pe_vect = []
pe_acum_vect = []
datos_fx_i = []
datos_fx_q = []

print 'Enter serial port number:\r'
# serial_port = raw_input("<< ")
serial_port = '6'
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

# ==================================================== Main ====================================================

while 1:
	print 'Enter command:\r'
	input = raw_input("<< ")

	if input == 'exit':
	    if(serial_port != '' ):
	    	ser.close()
	    exit()
	
# ============================ RAM commands ============================
	elif input == '1':
		write_GPIO(0,0,0,0)
		time.sleep(delay*10)
		write_GPIO(255, 255, 255, 255)

	elif input == '2':
		write_GPIO(0,0,0,0)
		time.sleep(delay*10)
		write_GPIO(128, 255, 0, 0)

	elif input == '3':
		write_GPIO(0,0,0,0)
		time.sleep(delay*10)
		write_GPIO(128, 255, 0, 255)

	elif input == '4':
		write_GPIO(0,0,0,0)
		time.sleep(delay*10)
		write_GPIO(128, 255, 255,0 )

	elif input == '5':
		write_GPIO(0,0,0,0)
		time.sleep(delay*10)
		write_GPIO(128, 55, 8, 12 )

	elif input == '0':
		uart_rx = ser.read(1)
		print (ord(uart_rx))
		time.sleep(delay)
		uart_rx = ser.read(1)
		print (ord(uart_rx))
		time.sleep(delay)	
		uart_rx = ser.read(1)
		print (ord(uart_rx))
		time.sleep(delay)	
		uart_rx = ser.read(1)
		print (ord(uart_rx))
		time.sleep(delay)	
# ============================ Aux ============================

	elif input == 'clear':
		os.system('cls')

	else:
		print ">> Wrong command, type help for a command list" 