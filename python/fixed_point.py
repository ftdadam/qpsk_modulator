from tool import _fixedInt as fx
import numpy as np

def float2fix(NB,NBF,numbers,signed_mode,round_mode,saturate_mode):
	local_numbers = []
	for elem in numbers:
		local_numbers.append(elem)
	error = False

	# for num in numbers:
	# 	if(type(num) != float):
	# 		error_msg = 'No se pasaron flotantes'
	# 		error = True

	NBI = NB-NBF
	step = 2**(-NBF)
	# int_numbers = []
	if(signed_mode == 'S'):
		lim_inf = -2**(NBI-1)
		lim_sup = 2**(NBI-1)-2**(-NBF)
		int_numbers = np.arange(2**(NB-1),2**(NB),1)
		int_numbers = np.append(int_numbers,np.arange(0,2**(NB-1),1))
	elif(signed_mode == 'U'):
		for num in local_numbers:
			if(num<0):
				error_msg = 'Numeros negativos en unsigned'
				error = True
				break
		lim_inf = 0
		lim_sup = 2**(NBI)-2**(-NBF)
		int_numbers = np.arange(0,2**(NB),1)
	else:
		error_msg = 'Modo de signo no soportado'
		error = True

	if(saturate_mode == 'saturate'):
		for ptr in range(0,len(local_numbers)):
			if(local_numbers[ptr] > lim_sup):
				local_numbers[ptr] = lim_sup
			elif(local_numbers[ptr] < lim_inf):
				local_numbers[ptr] = lim_inf
	elif(saturate_mode == 'wrap'):
		for ptr in range(0,len(local_numbers)):
			while((local_numbers[ptr] > lim_sup) or (local_numbers[ptr] < lim_inf)):
				if(local_numbers[ptr] > lim_sup):
					local_numbers[ptr] = local_numbers[ptr] - (2**NB)*step
				elif(local_numbers[ptr] < lim_inf):
					local_numbers[ptr] = local_numbers[ptr] + (2**NB)*step
	else:
		error_msg = 'Modo de saturacion no soportado'
		error = True

	fix_numbers = np.arange(lim_inf,lim_sup+step,step)
	fix_numbers = fix_numbers.tolist()
	int_numbers = int_numbers[::-1] # para sesgado hacia infinito positivo, el primer minimo que encontrara es el mas positivo
	fix_numbers = fix_numbers[::-1] # para sesgado hacia infinito positivo
	fix_values = []
	int_values = []

	for num in local_numbers:
		if(round_mode == 'trunc'):
			# fix_values.append(int(num/step)*step) # solo esta linea deberia ser lo correcto, la clase de referencia truncaba "mal" pero simplificaba la implementacion
			if(num>=0):
				# la clase de referencia truncaba "bien" para los positivos
				fix_values.append(int(num/step)*step)
				print 'aca', fix_values
			else:
				# la clase de referencia truncaba "mal" en los negativos, si era una cantidad no entera de steps, pasaba al siguiente directamente
				if(num%step == 0):
					fix_values.append(int(num/step)*step)
				else:
					fix_values.append(int((num/step)-1)*step)
		elif(round_mode == 'round'):
			dif = []
			for fixed_num in fix_numbers:
				dif.append(np.abs(num-fixed_num))
			fix_values.append(fix_numbers[np.argmin(dif)])
		else:
			error = True
			error_msg = 'Modo de redondeo no soportado'
	
	for ptr in range (0,len(fix_values)):
		int_values.append(int_numbers[fix_numbers.index(fix_values[ptr])])
	
	if(error):
		print error_msg
		return None, None
	else:
		return np.array(fix_values), np.array(int_values)

# test_numbers = [-2.2,-2.0,-1.7578125,-1.75,0.015,0.3828125,1.96,1.984375,20.0]
# test_numbers = [0.375,0.3828125,0.390625,0.0]
# test_numbers = [-1.75,-1.7578125,-1.765625,-10.0]
# test_numbers = [20]


# testing

# NB_vector =[1,2,3,4,5,6,7,8,9]
# NBF_vector = [1,2,3,4,5,6,7,8,9,10,11,12]
# signed_vector = ['U','S']
# round_vector = ['round','trunc']
# saturate_vector = ['saturate','wrap']

# total_general = 0

# for NB in NB_vector:
# 	for NBF in NBF_vector:
# 		for s_mode in signed_vector:
# 			for r_mode in round_vector:
# 				for sat_mode in saturate_vector:
# 					step = 2**(-NBF)/4.0
# 					NBI = NB - NBF
# 					if(s_mode == 'S'):
# 						lim_inf = -2**(NBI-1)
# 						lim_sup = 2**(NBI-1)-2**(-NBF)
# 					elif(s_mode == 'U'):
# 						lim_inf = 0
# 						lim_sup = 2**(NBI)-2**(-NBF)

# 					test_numbers = np.arange(lim_inf,lim_sup+step,step)

# 					a=[]
# 					b=[]
# 					c=[]
# 					d=[]

# 					funda = fx.arrayFixedInt(NB,NBF,test_numbers,s_mode,r_mode,sat_mode)
# 					for ptr in range(0,len(funda)):
# 						a.append(funda[ptr].fValue)
# 						b.append(funda[ptr].intvalue)

# 					# print type(a[0])
# 					c,d = float2fix(NB,NBF,test_numbers,s_mode,r_mode,sat_mode)
# 					total = 0
# 					for ptr in range (0,len(a)):
# 						total = total + (a[ptr]-c[ptr]) + (b[ptr]-d[ptr])
# 					total_general = total_general + total
# 					print 'Test: ' + s_mode +'('+ str(NB) + ',' + str(NBF) + ') , ' + r_mode + ' , ' + sat_mode + ' , Resultado = ' + str(total)

# print 'Resultado general = ' + str(total_general)

test_numbers = [1.0]
# print test_numbers
c,d = float2fix(2,1,test_numbers,'S','trunc','saturate')
print d
# print test_numbers