%% ------------------------------数据提取-----------------------------
%NRZI解码
AIS_out_denrzi = ~xor(AIS_out, [1 AIS_out(1:end-1)]);

%提取数据和帧校验序列
data_out = AIS_out_denrzi(41:end);              %删去上升沿、训练序列、开始标志
for i = 191:length(data_out)
    if(prod(data_out(i-4:i))==1)
        k = i - 7;                              %结束标志前的下标位置
    end
end
data_out = data_out(1:k);                       %删去结束标志及缓冲位
data_pad = data_out;

%反填充
m=[];
for i = 6:length(data_out)
    if(prod(data_out(i-5:i-1))==1 && data_out(i)==0)
        m = [m i];                              %存储填充0码的下标信息
    end
end
data_out(m) = [];                               %删去填充的0码

%% ------------------------------CRC校验-----------------------------
data_final = data_out(1:168);                   %取数据位
temp = [data_final zeros(1, 16)];               %将数据位移位
[divid_out, remainder_out] = deconv(temp, generator);     
remainder_out = mod(remainder_out(end-15:end),2);
if isequal(remainder_out, data_out(169:184))    %求得的余式与校验序列比较，若相同则解调正确
    msgbox('解调正确！', 'Success', 'modal');
else
    msgbox('解调错误，产生误码 :-(', 'Error', 'error');
end
