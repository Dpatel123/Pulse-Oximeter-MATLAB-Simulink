% POXI raw data simulator

f_resp = 0.11;
RESP = 0.05;
DC = 1.0;
f_ac = 80 / 60;
AC1 = 0.04;
AC2 = -0.02;
AC3 = 0.005;
NOISE = 0.008;
T = 2e-3;
fs = 1.0 / T;

N = 10000;
k = (0:N-1)';

u_po = DC + RESP * sin(2.0*pi*f_resp*T*k);
u_po = u_po + AC1 * sin(2.0*pi*f_ac*T*k);
u_po = u_po + AC2 * sin(2.0*pi*2.0*f_ac*T*k);
u_po = u_po + AC3 * sin(2.0*pi*3.0*f_ac*T*k);
u_po = u_po + NOISE * randn(N, 1);
u_po = round(u_po * 1200.0);
subplot(4,1,1); % first of three plots
stairs(k*T, u_po);
title('pulse oximeter raw data simulator (80 beats/min)');
axis([0 20 0 1500]);
grid;

%{
% Removing Noise from the signal
eY = fft(u_po);
fY = fix(eY/N)*N; % set numbers < 10000 to zero
ifY = ifft(fY); % inverse Fourier transform of fixed data
cy = real(ifY); % remove imaginary parts
subplot(2,1,2); % second of two plots
stairs(k*T, cy);
axis([0 20 0 1500]);
grid;

[peaks,R] = findpeaks(cy);
%}
u_po_mean = mean(u_po);
u_po_new = u_po - u_po_mean;
subplot(4,1,2); % second of four plots
stairs(k*T, u_po_new);
title('After mean value substraction');
grid;
 
order = 2;
Wc_hp = 0.3/fs*2;
[B_buhp,A_buhp]= butter(order,Wc_hp,'high');
fprintf('High pass filter coeffcients:\n');
for i=1:3
    fprintf('    IIR_Filt.num[%d] = %.15g;\n', i-1, B_buhp(i));
end
fprintf('\n');
for i=1:3
    fprintf('    IIR_Filt.den[%d] = %.15g;\n', i-1, A_buhp(i));
end
fprintf('\n');
x_fh = filter(B_buhp,A_buhp,u_po_new);
subplot(4,1,3); % third of four plots
stairs(k*T, x_fh);
title('After applying butterworth highpass filter(0.3 Hz)');
grid;

Wc_lp = 6/fs*2;
[B_bulp,A_bulp]= butter(order,Wc_lp,'low');
fprintf('Low pass filter coeffcients:\n');
for i=1:3
    fprintf('    IIR_Filt.num[%d] = %.15g;\n', i-1, B_bulp(i));
end
fprintf('\n');
for i=1:3
    fprintf('    IIR_Filt.den[%d] = %.15g;\n', i-1, A_bulp(i));
end
fprintf('\n');
x_fl = filter(B_bulp,A_bulp,x_fh);
subplot(4,1,4); % fourth of four plots
stairs(k*T, x_fl);
title('After applying butterworth lowpass filter(6 Hz)');
grid;

input_signal.time = k*T;
input_signal.signals.values = [u_po];
input_signal.dimension = 1;
%{
order = 4;
fcutlow=0.5;   %low cut frequency in kHz
fcuthigh=6;   %high cut frequency in kHz
[num,den]=butter(order,[fcutlow,fcuthigh]/(fs/2),'bandpass');
filtsig=filter(num,den,u_po_new);  %filtered signal
subplot(3,1,3); %third of three plots
stairs(k*T, filtsig);
title('After applying 4th order butterworth bandpass filter');
grid;
%}
disp('That`s all, folks.');

