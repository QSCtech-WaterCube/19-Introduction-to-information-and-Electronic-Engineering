% Read the voice file.
[x1,fs] = audioread('yanchanghuitest.mp3');

%Convert the voice from double channels to single channel.
if length(size(x1))>1
    x1 = x1(:,1);
end;

%Plot the voice waveform in the time and frequency domains. 
figure(1);
plot(x1);
title('The voice in the time domain');
xlabel('Time(second)');
ylabel('Amplitude');
figure(2);
y1 = fft(x1);
y1 = fftshift(y1);
derta_fs = fs/length(x1);
plot([-fs/2:derta_fs:fs/2-derta_fs],abs(y1)/fs);
title('The voice in the frequency domain');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The design of lowpass filter.

% Set the cutoff frequency of the lowpass filter to 4000Hz.
fc1 = 1000;

%design of the lowpass filter. 
N1 = 2*pi*0.9/(0.1*pi);
wc1 = 2*pi*fc1/fs;
if rem(N1,2)
    N1 = N1+1;
end;
Window = ones(1,N1+1);
b1 = fir1(N1,wc1/pi,Window);
figure(3);
freqz(b1,1,512);
title('The frequency response function of the lowpass filter');

%Process the voice using the lowpass filter.
x1_low = filter(b1,1,x1);
figure(4);
plot(x1_low);
title('The voice in the time domain after passing through the lowpass filter');
xlabel('Time(second)');
ylabel('Amplitude');

figure(5);
plot([-fs/2:derta_fs:fs/2-derta_fs],abs(fftshift(fft(x1_low))));
title('The voice in the time domain after passing through the lowpass filter');
xlabel('Frequency(Hz)');
ylabel('Amplitude');

%Save the voice after passing through the lowpass filter. You can hear it.
audiowrite('yanchanghuiAfter1000LowpassFilter.wav',x1_low, fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Design of the highpass filter.

%set the cutoff frequency of the highpass filter.
fc2 = 4000;

%Design the highpass filter.
N2 = 2*pi*3.1/(0.1*pi);
wc2 = 2*pi*fc2/fs;
N2 = N2+mod(N2,2);
Window = hanning(N2+1);
b2 = fir1(N2,wc2/pi,'high',Window);
figure(6);
freqz(b2,1,512);
title('The frequency response function of the highpass filter');


x1_high = filter(b2,1,x1);
figure(7);
plot(x1_high);
title('The voice in the time domain after passing through the high pass filter');
xlabel('Time(second)');
ylabel('Amplitude');

figure(8);
plot([-fs/2:derta_fs:fs/2-derta_fs],abs(fftshift(fft(x1_high))));
title('The voice in the frequency domain after passing through the high pass filter');
xlabel('Frequency(Hz)');
ylabel('Amplitude');

%save the voice after passing through the highpass filter. You can hear it.
audiowrite('yangchanghuiAfter4000HighFilter.wav',x1_high, fs);