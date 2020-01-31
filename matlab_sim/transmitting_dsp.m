%% ------------------------------生成信号-----------------------------
rising_edge = zeros(1, 8);                                   %8bit上升沿
training_seq = reshape([zeros(1, 12); ones(1, 12)], 1, 24);  %24bit训练序列“0101…”
start_flag = [0 ones(1, 6) 0];                               %8bit开始标志（01111110）
data_in = [[1 1 0 0 1 0] (randsrc(1, 162) + 1) / 2];         %随机产生168bit数据
frame_check = zeros(1, 16);                                  %初始化帧校验序列
end_flag = start_flag;                                       %结束标志（与开始标志相同）
buffer = zeros(1, 24);                                       %24bit缓冲位

%% ------------------------------添加CRC校验码-----------------------------
generator = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];  %生成多项式1+x^5+x^12+x^16
data = [data_in frame_check];                     %数据向左移16位，以计算帧校验序列并添加在末尾
[divid, remainder] = deconv(data, generator);     %移位后的数据除以生成多项式，得到商和余式
remainder = mod(remainder(end-15:end),2);         %取余式后16位并模2处理，得到帧校验序列
data(end-15:end) = remainder;                     %将帧校验序列添加在数据末尾
data_crc = data;                                  %存储添加CRC校验码后的数据

%% ------------------------------AIS信息帧-----------------------------
%比特填充（HDLC协议）
i = 5;  n = [];
while i < length(data)
    if(prod(data(i-4:i))==1)
        data = [data(1:i) 0 data(i+1:end)];  %若数据序列中出现连续5个1，则在后面添0
        n = [n i+1];                         %记录填充0码的位置
    end
    i = i + 1;
end

AIS0 = [rising_edge training_seq start_flag data end_flag buffer];  %AIS信息帧拼接
AIS1 = AIS0(1:256);                                                 %填充的0码占用缓冲位

%NRZI编码
AIS_in = ones(1, 257);
for i = 2:257
    AIS_in(i) = ~xor(AIS_in(i-1), AIS1(i-1));
end
AIS_in = AIS_in(2:end);


