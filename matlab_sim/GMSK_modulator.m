%% ------------------------------参数设置-----------------------------
Tb = 1/9600;                                        %码元宽度为1/9600s
BTb = 0.4;                                          %归一化带宽B*Tb为0.4
B = BTb/Tb;                                         %3dB带宽
fc = 161.975e6;                                     %载波频率为161.975MHz
N_sample = 5000;                                    %每码元采样点数
N_sample_rcv = 8;                                   %抽取滤波后的每码元采样点数
f_sample = N_sample/Tb;                             %采样频率
b_num = 256;                                        %基带信号为256个码元
dt = 1/f_sample;                                    %采样间隔
t = 0:dt:b_num*Tb-dt;                               %仿真离散时间
data_sample = kron(2*AIS_in-1, ones(1, N_sample));  %码元扩展(上采样)
alpha = sqrt(log(2))/2/B;                           %高斯滤波器的参数
h = 0.5;                                            %调制指数为0.5

%% ------------------------------高斯滤波-----------------------------
t_gauss = -3*Tb:dt:3*Tb;                                %滤波器冲激响应函数截断后的时间范围
h_gauss = sqrt(pi)/alpha*exp(-(pi*t_gauss/alpha).^2);   %滤波器冲激响应函数
gi = conv(data_sample/Tb, h_gauss) * dt;                %计算卷积产生高斯脉冲信号

%% ------------------------------MSK调制-----------------------------
phi = pi*h*dt*cumsum(gi');                          %求和代替积分，求相位函数
phi = phi(3*N_sample+1:end-3*N_sample)';            %将相位函数截取在仿真的时间范围
I_t = cos(phi);                                     %信号的同相分量
Q_t = sin(phi);                                     %信号的正交分量
gmsk = I_t.*cos(2*pi*fc*t) - Q_t.*sin(2*pi*fc*t);   %GMSK调制信号
