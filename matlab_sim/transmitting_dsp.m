%% ------------------------------�����ź�-----------------------------
rising_edge = zeros(1, 8);                                   %8bit������
training_seq = reshape([zeros(1, 12); ones(1, 12)], 1, 24);  %24bitѵ�����С�0101����
start_flag = [0 ones(1, 6) 0];                               %8bit��ʼ��־��01111110��
data_in = [[1 1 0 0 1 0] (randsrc(1, 162) + 1) / 2];         %�������168bit����
frame_check = zeros(1, 16);                                  %��ʼ��֡У������
end_flag = start_flag;                                       %������־���뿪ʼ��־��ͬ��
buffer = zeros(1, 24);                                       %24bit����λ

%% ------------------------------���CRCУ����-----------------------------
generator = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];  %���ɶ���ʽ1+x^5+x^12+x^16
data = [data_in frame_check];                     %����������16λ���Լ���֡У�����в������ĩβ
[divid, remainder] = deconv(data, generator);     %��λ������ݳ������ɶ���ʽ���õ��̺���ʽ
remainder = mod(remainder(end-15:end),2);         %ȡ��ʽ��16λ��ģ2�����õ�֡У������
data(end-15:end) = remainder;                     %��֡У���������������ĩβ
data_crc = data;                                  %�洢���CRCУ����������

%% ------------------------------AIS��Ϣ֡-----------------------------
%������䣨HDLCЭ�飩
i = 5;  n = [];
while i < length(data)
    if(prod(data(i-4:i))==1)
        data = [data(1:i) 0 data(i+1:end)];  %�����������г�������5��1�����ں�����0
        n = [n i+1];                         %��¼���0���λ��
    end
    i = i + 1;
end

AIS0 = [rising_edge training_seq start_flag data end_flag buffer];  %AIS��Ϣ֡ƴ��
AIS1 = AIS0(1:256);                                                 %����0��ռ�û���λ

%NRZI����
AIS_in = ones(1, 257);
for i = 2:257
    AIS_in(i) = ~xor(AIS_in(i-1), AIS1(i-1));
end
AIS_in = AIS_in(2:end);


