clear all;
clc;
close all;

fs = 1e3;              % Sampling frequency
T = 1/fs;               % Sampling period
len = 1500;   % Length of signal
f1 = 50; % RF frec
f2 = 100;   % OL frec
t = (0:len-1)*T;        % Time vector

f = fs*(0:((len-1)/2))/len; % Frec vector
signal = 1.0*sin(2*pi*f1*t);
ol = sin(2*pi*f2*t);
signal = signal.*ol;

spectrum = fft(signal);
P2 = abs(spectrum/len);
P1 = P2(1:(len-1)/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure()
plot(t,signal)
title('Filtered signal')
xlabel('t(us)')
ylabel('magnitude')

figure()
plot(f,P1) 
title('Spectrum')
xlabel('f (Hz)')
ylabel('|P1(f)|')
