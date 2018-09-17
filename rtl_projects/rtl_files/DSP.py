import numpy as np
import matplotlib.pyplot as plt
# import warnings
# warnings.filterwarnings("ignore")

def rcosine(beta, Tbaud, oversampling, Nbauds, Norm):
    """ Respuesta al impulso del pulso de caida cosenoidal """
    t_vect = np.arange(-0.5*Nbauds*Tbaud, 0.5*Nbauds*Tbaud, float(Tbaud)/oversampling)
    
    y_vect = []
    for t in t_vect:
        y_vect.append(np.sinc(t/Tbaud)*(np.cos(np.pi*beta*t/Tbaud)/
                                        (1-(4.0*beta*beta*t*t/(Tbaud*Tbaud)))))

    y_vect = np.array(y_vect)
    
    if(Norm):
        return (t_vect, y_vect/y_vect.sum())
    else:
        return (t_vect,y_vect)

def rrcosine(alpha, Tbaud, oversampling, Nbauds, Norm):
    N = Nbauds*oversampling
    Ts = Tbaud
    Fs = oversampling/Tbaud


    T_delta = 1/float(Fs)
    time_idx = ((np.arange(N)-N/2))*T_delta
    sample_num = np.arange(N)
    h_rrc = np.zeros(N, dtype=float)

    for x in sample_num:
        t = (x-N/2)*T_delta
        if t == 0.0:
            h_rrc[x] = 1.0 - alpha + (4*alpha/np.pi)
        elif alpha != 0 and t == Ts/(4*alpha):
            h_rrc[x] = (alpha/np.sqrt(2))*(((1+2/np.pi)* \
                    (np.sin(np.pi/(4*alpha)))) + ((1-2/np.pi)*(np.cos(np.pi/(4*alpha)))))
        elif alpha != 0 and t == -Ts/(4*alpha):
            h_rrc[x] = (alpha/np.sqrt(2))*(((1+2/np.pi)* \
                    (np.sin(np.pi/(4*alpha)))) + ((1-2/np.pi)*(np.cos(np.pi/(4*alpha)))))
        else:
            h_rrc[x] = (np.sin(np.pi*t*(1-alpha)/Ts) +  \
                    4*alpha*(t/Ts)*np.cos(np.pi*t*(1+alpha)/Ts))/ \
                    (np.pi*t*(1-(4*alpha*t/Ts)*(4*alpha*t/Ts))/Ts)

    return time_idx, h_rrc

def eyediagram(data, n, offset, period, color1):
    span     = 2*n
    segments = int(len(data)/span)
    xmax     = (n-1)*period
    xmin     = -(n-1)*period
    x        = list(np.arange(-n,n,)*period)
    xoff     = offset

    plt.figure()
    for i in range(0,segments-1):
        plt.plot(x, data[(i*span+xoff):((i+1)*span+xoff)],color1)
        plt.hold(True)
        plt.grid(True)
    plt.xlim(xmin, xmax)

def float2fix(NB,NBF,numbers,signed_mode,round_mode,saturate_mode):
    local_numbers = []
    for elem in numbers:
        local_numbers.append(elem)

    error = False
    fix_numbers = []
    int_numbers = []
    # for num in numbers:
    #   if(type(num) != float):
    #       error_msg = 'No se pasaron flotantes'
    #       error = True

    NBI = NB-NBF
    step = 2**(-NBF)
    
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
            if(local_numbers[ptr] < lim_inf):
                local_numbers[ptr] = lim_inf
    elif(saturate_mode == 'wrap'):
        for ptr in range(0,len(local_numbers)):
            while((local_numbers[ptr] > lim_sup) or (local_numbers[ptr] < lim_inf)):
                if(local_numbers[ptr] > lim_sup):
                    local_numbers[ptr] = local_numbers[ptr] - (2**NB)*step
                if(local_numbers[ptr] < lim_inf):
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
            if(num>=0):
                # la clase de referencia truncaba "bien" para los positivos
                fix_values.append(int(num/step)*step)
            else:
                # la clase de referencia truncaba "mal" en los negativos, si era una cantidad no entera de steps, pasaba al siguiente directamente
                if(num%step == 0):
                    fix_values.append(int(num/step)*step)
                else:
                    fix_values.append(int((num/step)-1)*step)
        elif(round_mode == 'trunc_alt'):
            fix_values.append(int(num/step)*step) # solo esta linea deberia ser lo correcto, la clase de referencia truncaba "mal" pero simplificaba la implementacion
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

def int2fix(NB,NBF,numbers,signed_mode,round_mode,saturate_mode):
	local_numbers = []
	for elem in numbers:
		local_numbers.append(elem)

	error = False
	fix_numbers = []
	int_numbers = []
	fix_values = []
	# for num in numbers:
	#   if(type(num) != float):
	#       error_msg = 'No se pasaron flotantes'
	#       error = True

	NBI = NB-NBF
	step = 2**(-NBF)

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

	fix_numbers = np.arange(lim_inf,lim_sup+step,step)
	int_numbers = int_numbers.tolist()
	
	for ptr in range (0,len(local_numbers)):
		fix_values.append(fix_numbers[int_numbers.index(local_numbers[ptr])])

	if(error):
		print error_msg
		return None
	else:
		return np.array(fix_values)

def twos_comp(val,NB):
    if(val<0):
        return val + 2**NB
    else:
        return val