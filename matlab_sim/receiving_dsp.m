%% ------------------------------������ȡ-----------------------------
%NRZI����
AIS_out_denrzi = ~xor(AIS_out, [1 AIS_out(1:end-1)]);

%��ȡ���ݺ�֡У������
data_out = AIS_out_denrzi(41:end);              %ɾȥ�����ء�ѵ�����С���ʼ��־
for i = 191:length(data_out)
    if(prod(data_out(i-4:i))==1)
        k = i - 7;                              %������־ǰ���±�λ��
    end
end
data_out = data_out(1:k);                       %ɾȥ������־������λ
data_pad = data_out;

%�����
m=[];
for i = 6:length(data_out)
    if(prod(data_out(i-5:i-1))==1 && data_out(i)==0)
        m = [m i];                              %�洢���0����±���Ϣ
    end
end
data_out(m) = [];                               %ɾȥ����0��

%% ------------------------------CRCУ��-----------------------------
data_final = data_out(1:168);                   %ȡ����λ
temp = [data_final zeros(1, 16)];               %������λ��λ
[divid_out, remainder_out] = deconv(temp, generator);     
remainder_out = mod(remainder_out(end-15:end),2);
if isequal(remainder_out, data_out(169:184))    %��õ���ʽ��У�����бȽϣ�����ͬ������ȷ
    msgbox('�����ȷ��', 'Success', 'modal');
else
    msgbox('������󣬲������� :-(', 'Error', 'error');
end
