clear all;
clc;
close all;

fs = 10e6;                  % Sampling frequency
T = 1/fs;                   % Sampling period

fileID = fopen('filtered_signal.txt','r');
signal = fscanf(fileID,'%f');
fclose(fileID);

T = 1/fs;                   % Sampling period
len = length(signal);       % Length of signal
f_ol = fs/256;              % OL frec
t = (0:len-1)*T;            % Time vector
f = fs*(0:((len-1)/2))/len; % Frec vector

ol = cos(2*pi*f_ol.*t);
ol = ol.';
signal = signal.*ol;

spectrum = fft(signal);
P2 = abs(spectrum/len);
P1 = P2(1:(len-1)/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure()
plot(t,signal)
title('PSK signal (cos in matlab)')
xlabel('t(us)')
ylabel('magnitude')

figure()
plot(10e-7*f,P1) 
title('Spectrum PSK signal (cos in matlab)')
xlabel('f (MHz)')
ylabel('|P1(f)|')

% =========================================================================
fileID = fopen('filtered_signal.txt','r');
signal = fscanf(fileID,'%f');
fclose(fileID);

len = length(signal);       % Length of signal
t = (0:len-1)*T;            % Time vector
f = fs*(0:(len/2))/len;     % Frec vector
frec = fs*(0:len-1);     % Frec vector

spectrum = fft(signal);
P2 = abs(spectrum/len);
P1 = P2(1:(len-1)/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure()
plot(1e6*t,signal)
title('Filtered signal')
xlabel('t(us)')
ylabel('magnitude')

figure()
plot(10e-7*f,P1) 
title('Spectrum Filtered signal')
xlabel('f (MHz)')
ylabel('|P1(f)|')

% =========================================================================

fileID = fopen('psk_signal.txt','r');
signal = fscanf(fileID,'%f');
fclose(fileID);

len = length(signal);   % Length of signal
t = (0:len-1)*T;        % Time vector
f = fs*(0:(len/2))/len; % Frec vector

spectrum = fft(signal);
P2 = abs(spectrum/len);
P1 = P2(1:(len-1)/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure()
plot(1e6*t,signal)
title('PSK signal')
xlabel('t(s)')
ylabel('magnitude')

figure()
plot(10e-7*f,P1)  
title('Spectrum PSK signal')
xlabel('f (MHz)')
ylabel('|P1(f)|')

% =========================================================================

fileID = fopen('qpsk_signal.txt','r');
signal = fscanf(fileID,'%f');
fclose(fileID);

len = length(signal);   % Length of signal
t = (0:len-1)*T;        % Time vector
f = fs*(0:(len/2))/len; % Frec vector

%spectrum = fft(signal);
% P2 = abs(spectrum/len);
% P1 = P2(1:(len-1)/2+1);
% P1(2:end-1) = 2*P1(2:end-1);

figure()
plot(1e6*t,signal)
title('QPSK signal')
xlabel('t(s)')
ylabel('magnitude')

figure()
plot(10e-7*f,P1)  
title('Spectrum QPSK signal')
xlabel('f (MHz)')
ylabel('|P1(f)|')


% alternativa ?
% 
% spectrum = fft(signal,length(t));
% Pspectrum = spectrum.*conj(spectrum)/length(t);
% f = 1000/length(t)*(1:length(t));
% length(f)
% length(Pspectrum)
% plot(f(1:4000),Pspectrum(1:4000))
% title('Power spectral density')
% xlabel('Frequency (Hz)')