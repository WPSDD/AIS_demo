%�����źž����˼��Ը�˹�������ŵ���������̲�����ʱ�ӡ�
%���±�Ƶ�õ�I��Q��·�źţ�����1bit��ֽ������������廥��ط�����ʱ��

%% ------------------------------�����±�Ƶ-----------------------------
f_dpl = 4000 * (2*rand-1);                  %������Ƶ�ƣ���Χһ����4kHz����
gmsk_dpl = I_t.*cos(2*pi*(fc+f_dpl)*t)...
           - Q_t.*sin(2*pi*(fc+f_dpl)*t);   %������Խ��ջ��˶�����������Ƶ��
gmsk_rcv = awgn(gmsk_dpl, 15, 'measured');  %�źž���AWGN�ŵ��������Ϊ15dB
fc1 = 17.975e6;                             %���ջ�ADת��������ݲ�����Ϊ48MHz���ز������Ƶ�17.975MHz��

%����ѭ���ۻ���������Ƶƫ
fft_gmsk2 = abs(fft(gmsk_rcv.^2));                                  %�ź�ƽ����Ƶ��
f_gmsk2 = 0:f_sample/length(t):f_sample*(length(t)-1)/length(t);    %FFTƵ����
fft_gmsk2(1:N_sample*b_num/2) = 0;                                  %ȥ��ֱ����������Ƶ
f1x2_index = find(fft_gmsk2 == max(fft_gmsk2));                     %��һ����ֵ��
f1x2 = f_gmsk2(f1x2_index);                                         %��ԪƵ��f1������
fft_gmsk2(f1x2_index) = 0;
f2x2_index = find(fft_gmsk2 == max(fft_gmsk2));                     %�ڶ�����ֵ��
f2x2 = f_gmsk2(f2x2_index);                                         %��ԪƵ��f2������
f_dpl_est = (f1x2 + f2x2) / 4 - fc1;                                %������Ƶ�ƹ���ֵ

%������·�������ӽ����±�Ƶ
cn = cos(2*pi*(fc1+f_dpl_est)*t);           %ͬ��������±�Ƶ��������
sn = sin(2*pi*(fc1+f_dpl_est)*t);           %�����������±�Ƶ��������
In = gmsk_rcv .* cn;                        %ͬ������±�Ƶ
Qn = - gmsk_rcv .* sn;                      %���������±�Ƶ
r1 = 25;  r2 = 5;  r3 = 5;                  %��ȡ����

% CIC�˲����������ݲ�����
hm = dsp.CICDecimator(r1);                  %����CIC�˲���,25����ȡ
In_cic = hm(In')';                          %I֧·�˲���ȡ
Qn_cic = hm(Qn')';                          %Q֧·�˲���ȡ

% ����FIR�˲������
Fs1 = f_sample/r1;          Fs2 = Fs1/r2;               % ���ݲ�����
Fpass1 = 35000;             Fpass2 = 10000;             % ͨ��Ƶ��
Fstop1 = Fs1/(2*r2);        Fstop2 = Fs2/(2*r3);        % ���Ƶ��
Dpass1 = 0.057501127785;    Dpass2 = 0.17099735734;     % ͨ������1dB��3dB
Dstop = 0.0056234132519;                                % �������45dB
dens  = 20;               
[N1, Fo1, Ao1, W1] = firpmord([Fpass1, Fstop1]/(Fs1/2), [1 0], [Dpass1, Dstop]);
[N2, Fo2, Ao2, W2] = firpmord([Fpass2, Fstop2]/(Fs2/2), [1 0], [Dpass2, Dstop]);
b1  = firpm(N1, Fo1, Ao1, W1, {dens});                  % ��һ���˲���ϵ��
b2  = firpm(N2, Fo2, Ao2, W2, {dens});                  % �ڶ����˲���ϵ��

%����FIR�˲����������Խ����˲�������
In_fir1 = filter(b1, 1, In_cic);   In_fir1 = In_fir1(1:r2:end);    %��һ��FIR�˲���ȡ
Qn_fir1 = filter(b1, 1, Qn_cic);   Qn_fir1 = Qn_fir1(1:r2:end);
In_fir2 = filter(b2, 1, In_fir1);  In_fir2 = In_fir2(1:r3:end);    %�ڶ���FIR�˲���ȡ
Qn_fir2 = filter(b2, 1, Qn_fir1);  Qn_fir2 = Qn_fir2(1:r3:end);
I_de0 = In_fir2;
Q_de0 = Qn_fir2;

%% ------------------------------1bit��ֽ��-----------------------------
delay = 7e-3 * rand;                                                        %�źŴ�����̵�ʱ�ӣ�1Tb���ڣ�
dt_rcv = dt * 25 * 25;
ave_dist = sum(sqrt(I_de0.^2 + Q_de0.^2)) / length(I_de0);                  %��λͼ�ϵĵ㵽ԭ���ƽ������
I_de = [2*rand(1, round(delay/dt_rcv))-1, I_de0];                           %��ȡ�˲����ͬ���źŷ���
Q_de = [2*rand(1, round(delay/dt_rcv))-1, Q_de0];                           %��ȡ�˲���������źŷ���
I_de = I_de/ave_dist;                                                       %��һ��
Q_de = Q_de/ave_dist;                                                       %��һ��
f_de = [zeros(1, N_sample_rcv) I_de(1:end-N_sample_rcv)] .* Q_de -...
       [zeros(1, N_sample_rcv) Q_de(1:end-N_sample_rcv)] .* I_de;           %1bit��ַ���Ƶ�ʵ�

%% ------------------------------ʱ�ӹ���-----------------------------
loc = reshape([zeros(1, 6); zeros(1, 6); ones(1, 6); ones(1, 6)], 1, 24);       %����ѵ������
loc = 2 * kron(loc, ones(1, N_sample_rcv)) - 1;                                 %�ϲ���
[xcorr_data, move_num] = xcorr(f_de, [zeros(1, 8.5*N_sample_rcv) loc], 'none'); %�󱾵�ѵ���������źŵĻ���غ���(8.5bit��λ��)
[~, max_num] = max(xcorr_data);                                                 %����غ������ֵ�±�
delay_num = move_num(max_num);                                                  %����ʱ�ӵĲ�������
delay_est = delay_num * dt_rcv;                                                 %ʱ�ӹ���ֵ
f_de = f_de(delay_num:end);

%% ------------------------------�����о�-----------------------------
if length(f_de) >= b_num * N_sample_rcv
    f_de = f_de(1:b_num * N_sample_rcv);
else
    f_de = [f_de f_de(end) * ones(1, b_num*N_sample_rcv-length(f_de))];
end
AIS_out = f_de(N_sample_rcv:N_sample_rcv:end) > 0;                      %����0��Ϊ1��������Ϊ0