---
title: Matlab实现滤波器
date: 2019-11-12 23:55:43
tags:
cover: https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/Matlab.jpg
---
# 前言
Tips：冬学期手痒，选了信息与电子工程导论，这门课用Matlab作为编程语言，那么我就随着进程更新一下学到的东西叭。

本文讲解如何利用Matlab程序对一段语音进行低通和高通滤波处理。以下为Matlab代码
```matlab
% Read the voice file.
[x1,fs] = audioread('segment2.mp3');

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
fc1 = 4000;

%design of the lowpass filter. 
N1 = 2*pi*0.9/(0.1*pi);
wc1 = 2*pi*fc1/fs;
if rem(N1,2)
    N1 = N1+1;
end;
Window = boxcar(N1+1);
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
audiowrite('segment2AfterLowpassFilter.wav',x1_low, fs);

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
audiowrite('segment2AfterHighFilter.wav',x1_high, fs);
```
猜想该程序可以将一段.mp3格式的语音滤波，输出两段新的音频和八张表格。

# First Try
我将代码直接丢入编辑器,把音频换成了五月天演唱会现场的一段音频，运行！只输出了两张图，然后报错了（咳咳
错误显示在第38行：未定义函数或变量 'boxcar'
经由bing/google后分析：
1.此版本已经不支持boxcar
2.没有对应的库
为了排除问题，我将line38``` Window = boxcar(N1+1);```替换为等价的```Window = ones(1,N1+1);```再次运行，又报错了，这次在39行

```matlab
>>错误使用 lvboqi (line 39)
'fir1' 需要 Signal Processing Toolbox。
```
罢辽，安装这个库吧，点击报错提示中的“Signal Processing Toolbox”，输入账号密码完成这个库的安装，还能用rectwin呢。
安装完成，试试看。关闭Matlab窗口，重新运行这段代码。
成功运行！
程序的输出结果是两段新的音频segment2AfterHighFilter.wav和segment2AfterLowpassFilter.wav以及八张图Figure1～8，那么我们一一分析叭！
我先听了高通滤波和低通滤波之后的两个音频，由于我把滤波频率设置为了4000Hz，所以低通滤波的变化效果一般（后来发现我有些耳背，小小年纪，哎）。高通滤波后的音频在我听来就只有滋滋声。我开始好奇自己能听到的极限频率，最后测试得8000Hz左右。对于我的这段音频，还是1000Hz低通效果比较明显（所以最后选择了这个频率）。

# 程序分析
以下将程序剖开分析
## 读入音频
```matlab
% Read the voice file.
[x1,fs] = audioread('segment2.mp3');%x1和fs大概采集了声音信号和频率叭

%Convert the voice from double channels to single channel.
if length(size(x1))>1
    x1 = x1(:,1);
end; %这段函数的作用是将多声道的音频转换成单声道并对其做傅里叶变换。主要目的应该是减少计算量，因为一个声道就可以得到声音的特征曲线。
```
之后就是八个绘图函数，重复的部分不再作分析
## 图表一：原声音的时域
```matlab
%Plot the voice waveform in the time and frequency domains. 
figure(1); %该函数的作用是建立第一张图表
plot(x1); %做原始语音信号的时域图形，默认横轴是时间
title('The voice in the time domain'); %输出图表的标题
xlabel('Time(second)'); %x代表的量及单位
ylabel('Amplitude'); %y代表的量
```
输出结果
![a1.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a1.jpg)

## 图表二：原声音的频域
```matlab
figure(2);
y1 = fft(x1); % 通过快速傅里叶变换得到声音的振幅
y1 = fftshift(y1); %让正半轴部分和负半轴部分的图像分别关于各自的中心对称，因为直接用fft得出的数据与频率不是对应的
derta_fs = fs/length(x1); %设置频谱的间隔，分辨率
plot([-fs/2:derta_fs:fs/2-derta_fs],abs(y1)/fs); %画出原始语音信号的频谱图
title('The voice in the frequency domain');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on; %添加网格线
```
输出结果
![a2.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a2.jpg)
## 设置低通频率
```matlab
fc1 = 1000;
N1 = 2*pi*0.9/(0.1*pi);   %N1为滤波器的阶数
wc1 = 2*pi*fc1/fs;    %wcl为截止频率
if rem(N1,2)
    N1 = N1+1;
end;
Window = boxcar(N1+1);
b1 = fir1(N1,wc1/pi,Window);
```
## 图表三：低通滤波器的频率响应函数
```matlab
figure(3);
freqz(b1,1,512);
title('The frequency response function of the lowpass filter');
```
输出结果：
![a3.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a3.jpg)
## 图表四：低通声音的时域
```matlab
x1_low = filter(b1,1,x1);
figure(4);   
plot(x1_low);
title('The voice in the time domain after passing through the lowpass filter');
xlabel('Time(second)');
ylabel('Amplitude');
```
输出结果：
![a4.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a4.jpg)
## 图表五：低通声音的频域
```matlab
figure(5);
plot([-fs/2:derta_fs:fs/2-derta_fs],abs(fftshift(fft(x1_low))));
title('The voice in the time domain after passing through the lowpass filter');
xlabel('Frequency(Hz)');
ylabel('Amplitude');
```
输出结果：
![a5.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a5.jpg)
## 输出音频
```matlab
audiowrite('segment2AfterLowpassFilter.wav',x1_low, fs);
```
## 设置高通的频率
```matlab
N2 = 2*pi*3.1/(0.1*pi);
wc2 = 2*pi*fc2/fs;
N2 = N2+mod(N2,2);
Window = hanning(N2+1);
b2 = fir1(N2,wc2/pi,'high',Window);
figure(6);
freqz(b2,1,512);
title('The frequency response function of the highpass filter');
```
## 图表六：高通滤波器的频率响应函数
不再重复说明
输出结果：
![a6.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a6.jpg)
## 图表七：高通声音的时域
不再重复说明
输出结果：
![a7.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a7.jpg)
## 图表八：高通声音的频域
不再重复说明
输出结果：
![a8.jpg](https://cdn.jsdelivr.net/gh/QSCtech-WaterCube/picbed/a8.jpg)

# 结语
在频域图形上，可以很直观的看出通过低通滤波器后原声音1000HZ以上的声音被消除了，同样的通过高通滤波器后4000HZ以下部分的声音也被消除了。图形产生了非常大的变化。
不难看出，若频率设置相同，低通和高通之后两张频率表若是重合，则会与原声音的图表一致。低通后的声音与远声音变化不大，因高音部分的消除使得声音更加清晰，而高通后的声音则与原来的声音有了很大的区别，显得很刺耳。
不知道是不是我对作业的要求有所误解……但是这几天看全英的MATLAB的说明书看得我非常茫然，感觉这节课应该是让我体验一下这个软件而不是去深入的学习它的函数。
但是这几天对于MATLAB的学习和教程的编写总是有益的，希望在之后的课程中能对信息世界有更加深入的了解。

有问题或错误欢迎联系QQ：515310897哈

