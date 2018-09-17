import sys
import os
import time
from Tkinter import *
import ttk
import tkFileDialog
import tkMessageBox
from PIL import ImageTk
import zlib,base64
import serial
import numpy as np
import matplotlib.pyplot as plt
# from mpl_toolkits.mplot3d import Axes3D
from DSP import*

# ====== functions ======

def load_coef():
    radioValue = filter_type.get()
    print entry_rolloff.get()
    print radioValue
    return

def log_data():
    radioValue = log_output.get()
    print radioValue
    return

def changelabel():
	return

def cb_main():
	if(cb_main_val.get()):
		cb_control_1.configure(state=ACTIVE)
		cb_control_2.configure(state=ACTIVE)
		cb_control_3.configure(state=ACTIVE)
		cb_log_ram_1.configure(state=ACTIVE)
		cb_log_ram_2.configure(state=ACTIVE)
		cb_log_ram_3.configure(state=ACTIVE)
		cb_log_ram_4.configure(state=ACTIVE)
		cb_info_ram_1.configure(state=ACTIVE)
		browsebutton.configure(state=ACTIVE)
		button_rst_addr_counter.configure(state=ACTIVE)
		button_rst_aux_counter.configure(state=ACTIVE)
		button_load_coef.configure(state=ACTIVE)
		button_write_file.configure(state=ACTIVE)
		tkMessageBox.showinfo("Warning","Check the FPGA:\nLED[0] must be turned ON mannualy with SW[0].")
	else:
		cb_control_1.configure(state=DISABLED)
		cb_control_2.configure(state=DISABLED)
		cb_control_3.configure(state=DISABLED)
		cb_log_ram_1.configure(state=DISABLED)
		cb_log_ram_2.configure(state=DISABLED)
		cb_log_ram_3.configure(state=DISABLED)
		cb_log_ram_4.configure(state=DISABLED)
		cb_info_ram_1.configure(state=DISABLED)
		browsebutton.configure(state=DISABLED)
		button_rst_addr_counter.configure(state=DISABLED)
		button_rst_aux_counter.configure(state=DISABLED)
		button_load_coef.configure(state=DISABLED)
		button_write_file.configure(state=DISABLED)
	return

def cb_control():
	print "1 is", cb_control_1_val.get()
	print "2 is", cb_control_2_val.get()
	print "3 is", cb_control_3_val.get()
	return

def cb_log_ram():
	print "1 is", cb_log_ram_1_val.get()
	print "2 is", cb_log_ram_2_val.get()
	print "3 is", cb_log_ram_3_val.get()
	print "4 is", cb_log_ram_4_val.get()
	return

def cb_plot():
	print "1 is", cb_plot_1_val.get()
	print "2 is", cb_plot_2_val.get()
	print "3 is", cb_plot_3_val.get()
	print "4 is", cb_plot_4_val.get()
	print "5 is", cb_plot_5_val.get()
	return

def cb_info_ram():
	print "1 is", cb_info_ram_1_val.get()
	return

def showplot():
	return

def read_files():
	return

def top_menu_archivo():
	print 'archivo'
	return

def hola():
	print 'hola'
	return

def browse():
	pathname = tkFileDialog.askopenfilename()
	filename.config(text = os.path.basename(pathname))
	pathlabel.config(text=filename)

def set_COM_port():
	COM_port_status = ""
	global button_COM_text
	if(button_COM_text == "Connect"):
		if(COM_dropoff_list.get() != 'None'):
			if(COM_dropoff_list.get() == 'Select'):
				tkMessageBox.showinfo("Warning","Select a COM Port")
			else:
				try:
					ser = serial.Serial(
					port = 'COM' + COM_dropoff_list.get(),
					baudrate=9600,
					parity=serial.PARITY_NONE,
					stopbits=serial.STOPBITS_ONE,
				    bytesize=serial.EIGHTBITS
					)
					ser.isOpen()
					ser.timeout = 1.0
					print_COM_port_status("Connected","green")
					tkMessageBox.showinfo("Warning","Succesfuly Connected.\nCheck the FPGA, to enable clocks & UART:\nSW[0] must be LOW\nLED[0] must be ON.")
					button_COM_text = "Disconnect"
					button_COM.configure(text = button_COM_text)
				except serial.SerialException:
					print_COM_port_status("Error","red")
					tkMessageBox.showinfo("Error","COM"+COM_dropoff_list.get()+" is not open.\n Please check Device Manager")
		else:
			print_COM_port_status("Override","blue")
	else:
		tkMessageBox.showinfo("Information","Succesfully disconnected")
		button_COM_text = "Connect"
		print_COM_port_status("Disconnected","black")
		button_COM.configure(text = button_COM_text)
		try:
			ser.close()
		except serial.SerialException:
			None
	return

def print_COM_port_status(COM_port_status,color):
	label2.config(text=COM_port_status,fg = color)
	return


# ======================================================= Windows Interface =======================================================
root = Tk()
icon=PhotoImage(height=16, width=16)
root.tk.call('wm', 'iconphoto', root._w, icon)

root.title("QPSK Modulator Control")
window_height = 600
window_width = 850
root.geometry(str(window_width)+'x'+str(window_height))

# ==============================================================================================================

master_lf0 = LabelFrame(root, width=100, height=450, bd = 0)
master_lf0.grid(row=0,column=0,sticky=W+N)

lf_0_0 = LabelFrame(master_lf0, text="Serial Port Selection",relief = SUNKEN, width=300, height=window_height)
lf_0_0.grid(row=0,column=0,sticky=W+N,pady=10,padx=20)

label1 = Label(lf_0_0, text="COM Port:")
label1.grid(row=0,column=0)

COM_ports = np.arange(1,13)
COM_ports = np.append(COM_ports,"None")
COM_dropoff_list = StringVar(lf_0_0)
COM_dropoff_list.set('Select')
dropoff_list1 = OptionMenu (lf_0_0, COM_dropoff_list, *COM_ports)
dropoff_list1.configure(width=8)
dropoff_list1.grid(row=0,column=1)

label2 = Label(lf_0_0, text="Disconnected",width=10)
label2.grid(row=1,column=0,pady=10,padx=5)
button_COM_text = "Connect"
button_COM = Button(lf_0_0, text=button_COM_text, width = 15, command = set_COM_port)
button_COM.grid(row=1,column=1,pady=10,padx=5)


lf_0_1 = LabelFrame(master_lf0, text="Control Signals",relief = SUNKEN)
lf_0_1.grid(row=1,column=0,sticky=W+E,pady=10,padx=20)

cb_main_val = IntVar(lf_0_1)
cb_control_1_val = IntVar(lf_0_1)
cb_control_2_val = IntVar(lf_0_1)
cb_control_3_val = IntVar(lf_0_1)
cb_control_main = Checkbutton(lf_0_1, variable = cb_main_val, text="Set Register File (LED[0] on)", height = 0, command = cb_main)
cb_control_main.grid(row=0,column=0,sticky=W)
cb_control_1 = Checkbutton(lf_0_1, variable = cb_control_1_val, state = DISABLED, text="Enable Register File", height = 0, command = cb_control)
cb_control_1.grid(row=1,column=0,sticky=W)
cb_control_2 = Checkbutton(lf_0_1, variable = cb_control_2_val, state = DISABLED, text="Enable Tx Modules", height = 0, command = cb_control)
cb_control_2.grid(row=2,column=0,sticky=W)
cb_control_3 = Checkbutton(lf_0_1, variable = cb_control_3_val, state = DISABLED, text="Reset Tx Modules", height = 0, command = cb_control)
cb_control_3.grid(row=3,column=0,sticky=W)

lf_0_2 = LabelFrame(master_lf0, text="LOG RAM Control Signals",relief = SUNKEN)
lf_0_2.grid(row=2,column=0,sticky=W+E,pady=10,padx=20)

cb_log_ram_1_val = IntVar(lf_0_2)
cb_log_ram_2_val = IntVar(lf_0_2)
cb_log_ram_3_val = IntVar(lf_0_2)
cb_log_ram_4_val = IntVar(lf_0_2)
cb_log_ram_1 = Checkbutton(lf_0_2, variable = cb_log_ram_1_val, state = DISABLED, text="Write enable", height = 0, command = cb_log_ram)
cb_log_ram_1.grid(row=0,column=0,sticky=W)
cb_log_ram_2 = Checkbutton(lf_0_2, variable = cb_log_ram_2_val, state = DISABLED, text="Read Enable", height = 0, command = cb_log_ram)
cb_log_ram_2.grid(row=1,column=0,sticky=W)
cb_log_ram_3 = Checkbutton(lf_0_2, variable = cb_log_ram_3_val, state = DISABLED, text="Output Enable", height = 0, command = cb_log_ram)
cb_log_ram_3.grid(row=2,column=0,sticky=W)
cb_log_ram_4 = Checkbutton(lf_0_2, variable = cb_log_ram_4_val, state = DISABLED, text="Output Reset", height = 0, command = cb_log_ram)
cb_log_ram_4.grid(row=3,column=0,sticky=W)

lf_0_3 = LabelFrame(master_lf0, text="INFO RAM Control & Message",relief = SUNKEN)
lf_0_3.grid(row=3,column=0,sticky=W+E,pady=10,padx=20)

cb_info_ram_1_val = IntVar(lf_0_3)
cb_info_ram_1 = Checkbutton(lf_0_3, variable = cb_info_ram_1_val, state = DISABLED, text="Write enable", height = 0, command = cb_info_ram)
cb_info_ram_1.grid(row=0,column=0,sticky=W)
browsebutton = Button(lf_0_3, text='Browse', command=browse, state = DISABLED)
browsebutton.grid(row=1,column=0,sticky=W,pady=5,padx=20)

pathlabel = Label(lf_0_3)
filename = Label(lf_0_3,text ="No file selected")
filename.grid(row=2,column=0,sticky=W)

# # ==============================================================================================================
master_lf1 = LabelFrame(root, width=100, height=window_height,bd=0)
master_lf1.grid(row=0,column=1,sticky=W+N)

lf_1_0 = LabelFrame(master_lf1, text="Counters Control",relief = SUNKEN)
lf_1_0.grid(row=0,column=0,sticky=W+E,pady=10,padx=10)

button_rst_addr_counter = Button(lf_1_0, text="Reset Addr Counter",state=DISABLED, width = 15, command = log_data)
button_rst_addr_counter.grid(row=0,column=0,sticky=W+E,padx=10,pady=5)
button_rst_aux_counter = Button(lf_1_0, text="Reset Aux Counter",state=DISABLED, width = 15, command = log_data)
button_rst_aux_counter.grid(row=0,column=1,sticky=W+E,padx=10,pady=5)

lf_1_1 = LabelFrame(master_lf1, text="Filter Control",relief = SUNKEN)
lf_1_1.grid(row=1,column=0,sticky=W+E,pady=10,padx=10)

filter_type = StringVar()
filter_type.set("RRC")
rolloff = StringVar()
radio1 = Radiobutton(lf_1_1, text="RRC",value="RRC",variable=filter_type) 
radio2 = Radiobutton(lf_1_1, text="SRRC",value="SRRC",variable=filter_type) 
radio1.grid(row=0,column=0,sticky=W)
radio2.grid(row=1,column=0,sticky=W)
button_load_coef = Button(lf_1_1, text="Load Coefs", width = 10, state=DISABLED,command = load_coef)
button_load_coef.grid(row=0,column=1,sticky=W,padx=41)
label_rolloff = Label(lf_1_1, text = "Rolloff",width=15)
label_nbaud = Label(lf_1_1,text = "Baudios",width=15)
label_os = Label(lf_1_1,text = "Oversampling",width=15)
entry_rolloff = Entry(lf_1_1)
entry_nbaud = Label(lf_1_1,text = "8",width=15)
entry_os = Label(lf_1_1,text = "4",width=15)
label_rolloff.grid(row=2,column=0,sticky=W)
label_nbaud.grid(row=3,column=0,sticky=W)
label_os.grid(row=4,column=0,sticky=W)
entry_rolloff.grid(row=2,column=1,sticky=W)
entry_nbaud.grid(row=3,column=1,sticky=W)
entry_os.grid(row=4,column=1,sticky=W)

lf_1_2 = LabelFrame(master_lf1, text="Datalogger",relief = SUNKEN)
lf_1_2.grid(row=2,column=0,sticky=W+E,pady=10,padx=10)

log_output = StringVar()
log_output.set("Filter")
radio3 = Radiobutton(lf_1_2, text="Filter",value="Filter",variable=log_output)
radio4 = Radiobutton(lf_1_2, text="PSK",value="PSK",variable=log_output)
radio5 = Radiobutton(lf_1_2, text="QPSK",value="QPSK",variable=log_output)
radio3.grid(row=0,column=0,sticky=W)
radio4.grid(row=1,column=0,sticky=W)
radio5.grid(row=2,column=0,sticky=W)

button_write_file = Button(lf_1_2, text="Write File", width = 10, command = log_data)
button_write_file.grid(row=0,column=1,sticky=W)

pb1_label = Label(lf_1_2,text = "Filter Log 0%",width=15)
pb1_label.grid(row=3,column=0,sticky=W,pady=5)
pb1 = ttk.Progressbar(lf_1_2,orient ="horizontal",length = 200, mode ="determinate")
pb1.grid(row=3,column=1,sticky=W,padx=5)

pb2_label = Label(lf_1_2,text = "PSK Log 0%",width=15)
pb2_label.grid(row=4,column=0,sticky=W,pady=5)
pb2 = ttk.Progressbar(lf_1_2,orient ="horizontal",length = 200, mode ="determinate")
pb2.grid(row=4,column=1,sticky=W,padx=5)

pb3_label = Label(lf_1_2,text = "QPSK Log 100%",width=15)
pb3_label.grid(row=5,column=0,sticky=W,pady=5)
pb3 = ttk.Progressbar(lf_1_2,orient ="horizontal",length = 200, mode ="determinate")
pb3.grid(row=5,column=1,sticky=W,padx=5)

button4 = Button(lf_1_2, text="Read Files", width = 10, command = read_files)
button4.grid(row=6,column=1,sticky=W,pady=5)

pb1["maximum"] = 100
pb1["value"] = 50

# # ==============================================================================================================

master_lf2 = LabelFrame(root, width=100, height=window_height,bd=0)
master_lf2.grid(row=0,column=2,sticky=W+N)

lf_2_0 = LabelFrame(master_lf2, text="Plot Results",relief = SUNKEN)
lf_2_0.grid(row=0,column=0,sticky=W+N,pady=10,padx=10)

cb_plot_1_val = IntVar(lf_2_0)
cb_plot_2_val = IntVar(lf_2_0)
cb_plot_3_val = IntVar(lf_2_0)
cb_plot_4_val = IntVar(lf_2_0)
cb_plot_5_val = IntVar(lf_2_0)
cb_plot_1 = Checkbutton(lf_2_0, variable = cb_plot_1_val, text="Eyes Diagrams", height = 0, command = cb_plot)
cb_plot_1.grid(row=1,column=0,sticky=W)
cb_plot_2 = Checkbutton(lf_2_0, variable = cb_plot_2_val, text="Constelation", height = 0, command = cb_plot)
cb_plot_2.grid(row=2,column=0,sticky=W)
cb_plot_3 = Checkbutton(lf_2_0, variable = cb_plot_3_val, text="Signal Filter", height = 0, command = cb_plot)
cb_plot_3.grid(row=3,column=0,sticky=W)
cb_plot_4 = Checkbutton(lf_2_0, variable = cb_plot_4_val, text="Signal PSK", height = 0, command = cb_plot)
cb_plot_4.grid(row=4,column=0,sticky=W)
cb_plot_5 = Checkbutton(lf_2_0, variable = cb_plot_5_val, text="Signal QPSK", height = 0, command = cb_plot)
cb_plot_5.grid(row=5,column=0,sticky=W)

button5 = Button(lf_2_0, text="Show Plots", width = 10, command = showplot)
button5.grid(row=6,column=1,sticky=W,pady=10)

lf_2_1 = LabelFrame(master_lf2, text="Autor",bd=0)
lf_2_1.grid(row=1,column=0,sticky=W+N,pady=10,padx=10)

autor = Label(lf_2_1,text="Federico Tomas Dadam\n UNC, FCEFyN, 2018")
autor.grid(row=1,column=2,sticky=W+E,padx=10)

# ================= Top Tearoff menu =================

top_menu = Menu(root)

file_menu = Menu(top_menu, tearoff=0)
file_menu.add_command(label="Test", command=hola)
file_menu.add_separator()
file_menu.add_command(label="Exit", command=root.quit)

help_menu = Menu(top_menu, tearoff=0)
help_menu.add_command(label="About...", command=hola)

top_menu.add_cascade(label="File", menu=file_menu)
top_menu.add_cascade(label="Help", menu=help_menu)

root.config(menu=top_menu)

# ================= Status Bar =================

# status = Label(root, text = "Nothing going on...", bd =1, relief = SUNKEN, anchor=W)
# status.pack(side=BOTTOM, fill = "x")

root.mainloop()