%% ------------------------------��������-----------------------------
Tb = 1/9600;                                        %��Ԫ����Ϊ1/9600s
BTb = 0.4;                                          %��һ������B*TbΪ0.4
B = BTb/Tb;                                         %3dB����
fc = 161.975e6;                                     %�ز�Ƶ��Ϊ161.975MHz
N_sample = 5000;                                    %ÿ��Ԫ��������
N_sample_rcv = 8;                                   %��ȡ�˲����ÿ��Ԫ��������
f_sample = N_sample/Tb;                             %����Ƶ��
b_num = 256;                                        %�����ź�Ϊ256����Ԫ
dt = 1/f_sample;                                    %�������
t = 0:dt:b_num*Tb-dt;                               %������ɢʱ��
data_sample = kron(2*AIS_in-1, ones(1, N_sample));  %��Ԫ��չ(�ϲ���)
alpha = sqrt(log(2))/2/B;                           %��˹�˲����Ĳ���
h = 0.5;                                            %����ָ��Ϊ0.5

%% ------------------------------��˹�˲�-----------------------------
t_gauss = -3*Tb:dt:3*Tb;                                %�˲����弤��Ӧ�����ضϺ��ʱ�䷶Χ
h_gauss = sqrt(pi)/alpha*exp(-(pi*t_gauss/alpha).^2);   %�˲����弤��Ӧ����
gi = conv(data_sample/Tb, h_gauss) * dt;                %�������������˹�����ź�

%% ------------------------------MSK����-----------------------------
phi = pi*h*dt*cumsum(gi');                          %��ʹ�����֣�����λ����
phi = phi(3*N_sample+1:end-3*N_sample)';            %����λ������ȡ�ڷ����ʱ�䷶Χ
I_t = cos(phi);                                     %�źŵ�ͬ�����
Q_t = sin(phi);                                     %�źŵ���������
gmsk = I_t.*cos(2*pi*fc*t) - Q_t.*sin(2*pi*fc*t);   %GMSK�����ź�