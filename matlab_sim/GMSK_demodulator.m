%假设信号经过了加性高斯白噪声信道，传输过程产生了时延。
%经下变频得到I、Q两路信号，利用1bit差分解调法解调，广义互相关法估计时延

%% ------------------------------数字下变频-----------------------------
f_dpl = 4000 * (2*rand-1);                  %多普勒频移，范围一般在4kHz以内
gmsk_dpl = I_t.*cos(2*pi*(fc+f_dpl)*t)...
           - Q_t.*sin(2*pi*(fc+f_dpl)*t);   %卫星相对接收机运动产生多普勒频移
gmsk_rcv = awgn(gmsk_dpl, 15, 'measured');  %信号经过AWGN信道后信噪比为15dB
fc1 = 17.975e6;                             %接收机AD转换后的数据采样率为48MHz，载波被搬移到17.975MHz处

%二阶循环累积量法估计频偏
fft_gmsk2 = abs(fft(gmsk_rcv.^2));                                  %信号平方的频谱
f_gmsk2 = 0:f_sample/length(t):f_sample*(length(t)-1)/length(t);    %FFT频率轴
fft_gmsk2(1:N_sample*b_num/2) = 0;                                  %去除直流分量及镜频
f1x2_index = find(fft_gmsk2 == max(fft_gmsk2));                     %第一个峰值点
f1x2 = f_gmsk2(f1x2_index);                                         %码元频率f1的两倍
fft_gmsk2(f1x2_index) = 0;
f2x2_index = find(fft_gmsk2 == max(fft_gmsk2));                     %第二个峰值点
f2x2 = f_gmsk2(f2x2_index);                                         %码元频率f2的两倍
f_dpl_est = (f1x2 + f2x2) / 4 - fc1;                                %多普勒频移估计值

%产生两路正交因子进行下变频
cn = cos(2*pi*(fc1+f_dpl_est)*t);           %同相分量的下变频正交因子
sn = sin(2*pi*(fc1+f_dpl_est)*t);           %正交分量的下变频正交因子
In = gmsk_rcv .* cn;                        %同相分量下变频
Qn = - gmsk_rcv .* sn;                      %正交分量下变频
r1 = 25;  r2 = 5;  r3 = 5;                  %抽取因子

% CIC滤波，降低数据采样率
hm = dsp.CICDecimator(r1);                  %生成CIC滤波器,25倍抽取
In_cic = hm(In')';                          %I支路滤波抽取
Qn_cic = hm(Qn')';                          %Q支路滤波抽取

% 两级FIR滤波器设计
Fs1 = f_sample/r1;          Fs2 = Fs1/r2;               % 数据采样率
Fpass1 = 35000;             Fpass2 = 10000;             % 通带频率
Fstop1 = Fs1/(2*r2);        Fstop2 = Fs2/(2*r3);        % 阻带频率
Dpass1 = 0.057501127785;    Dpass2 = 0.17099735734;     % 通带波纹1dB和3dB
Dstop = 0.0056234132519;                                % 阻带波纹45dB
dens  = 20;               
[N1, Fo1, Ao1, W1] = firpmord([Fpass1, Fstop1]/(Fs1/2), [1 0], [Dpass1, Dstop]);
[N2, Fo2, Ao2, W2] = firpmord([Fpass2, Fstop2]/(Fs2/2), [1 0], [Dpass2, Dstop]);
b1  = firpm(N1, Fo1, Ao1, W1, {dens});                  % 第一级滤波器系数
b2  = firpm(N2, Fo2, Ao2, W2, {dens});                  % 第二级滤波器系数

%两级FIR滤波，分两级以降低滤波器阶数
In_fir1 = filter(b1, 1, In_cic);   In_fir1 = In_fir1(1:r2:end);    %第一级FIR滤波抽取
Qn_fir1 = filter(b1, 1, Qn_cic);   Qn_fir1 = Qn_fir1(1:r2:end);
In_fir2 = filter(b2, 1, In_fir1);  In_fir2 = In_fir2(1:r3:end);    %第二级FIR滤波抽取
Qn_fir2 = filter(b2, 1, Qn_fir1);  Qn_fir2 = Qn_fir2(1:r3:end);
I_de0 = In_fir2;
Q_de0 = Qn_fir2;

%% ------------------------------1bit差分解调-----------------------------
delay = 7e-3 * rand;                                                        %信号传输过程的时延（1Tb以内）
dt_rcv = dt * 25 * 25;
ave_dist = sum(sqrt(I_de0.^2 + Q_de0.^2)) / length(I_de0);                  %相位图上的点到原点的平均距离
I_de = [2*rand(1, round(delay/dt_rcv))-1, I_de0];                           %抽取滤波后的同相信号分量
Q_de = [2*rand(1, round(delay/dt_rcv))-1, Q_de0];                           %抽取滤波后的正交信号分量
I_de = I_de/ave_dist;                                                       %归一化
Q_de = Q_de/ave_dist;                                                       %归一化
f_de = [zeros(1, N_sample_rcv) I_de(1:end-N_sample_rcv)] .* Q_de -...
       [zeros(1, N_sample_rcv) Q_de(1:end-N_sample_rcv)] .* I_de;           %1bit差分法求频率点

%% ------------------------------时延估计-----------------------------
loc = reshape([zeros(1, 6); zeros(1, 6); ones(1, 6); ones(1, 6)], 1, 24);       %本地训练序列
loc = 2 * kron(loc, ones(1, N_sample_rcv)) - 1;                                 %上采样
[xcorr_data, move_num] = xcorr(f_de, [zeros(1, 8.5*N_sample_rcv) loc], 'none'); %求本地训练序列与信号的互相关函数(8.5bit移位？)
[~, max_num] = max(xcorr_data);                                                 %互相关函数最大值下标
delay_num = move_num(max_num);                                                  %估计时延的采样点数
delay_est = delay_num * dt_rcv;                                                 %时延估计值
f_de = f_de(delay_num:end);

%% ------------------------------抽样判决-----------------------------
if length(f_de) >= b_num * N_sample_rcv
    f_de = f_de(1:b_num * N_sample_rcv);
else
    f_de = [f_de f_de(end) * ones(1, b_num*N_sample_rcv-length(f_de))];
end
AIS_out = f_de(N_sample_rcv:N_sample_rcv:end) > 0;                      %大于0判为1，否则判为0