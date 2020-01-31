%% ------------------------------��������-----------------------------
para = {'��ϢID', 'ת��ָʾ��', '�û�ID', '����״̬', '��ת����', '���溽��', 'λ��׼ȷ��',...
    '����', 'γ��', '���溽��', 'ʵ�ʺ���', 'ʱ��', '�ض�����ָʾ��', 'RAIM��־', 'ͨ��״̬'};

value = struct;  %��ʼ���ṹ��value
%��ϢID
if(isequal([1 1 0 0 0 1], data_out(1:6)))
    value.msg_id = '1';
elseif (isequal([1 1 0 0 1 0], data_out(1:6)))
    value.msg_id = '2';
elseif (isequal([1 1 0 0 1 1], data_out(1:6)))
    value.msg_id = '3';
else
    value.msg_id = '0';
end

%ת��ָʾ��������ĳ����Ϣ��ת���˶��ٴ�
 switch 2.^([1 0])*(data_out(7:8))'
     case 0
         value.retran_ind = 'Ĭ��';
     case 3
         value.retran_ind = '����ת��';
     otherwise
         value.retran_ind = num2str(2.^([1 0])*(data_out(7:8))');
 end
 
 %�û�ID��Ψһ��ʶ��
 value.user_id = num2str(2.^(29:-1:0)*(data_out(9:38))');
 
 %����״̬
 switch 2.^(3:-1:0)*(data_out(39:42))'
     case 0
         value.navi_state = '������ʹ����';
     case 1
         value.navi_state = 'ê��';
     case 2
         value.navi_state = 'δ����';
     case 3
         value.navi_state = '�����ʺ���';
     case 4
         value.navi_state = '�ܴ�����ˮ����';
     case 5
         value.navi_state = 'ϵ��';
     case 6
         value.navi_state = '��ǳ';
     case 7
         value.navi_state = '���²���';
     case 8
         value.navi_state = '������';
     case {9, 10}
         value.navi_state = '����������������״̬';
     case {11, 12, 13}
         value.navi_state = '����������';
     case 14
         value.navi_state = 'AIS-SART';
     case 15
         value.navi_state = 'δ�涨';
 end
 
 %��ת����ROTAIS
 switch data_out(43)
     case 0
         if(data_out(44:50)==ones(1, 7))
             value.rotais = '��ÿ30s��������5�ȵ�������ת��TI�����ã�';
         else
             value.rotais = 'ÿ�����������708�Ȼ����';
         end
     case 1
         if(data_out(44:50)==[0 0 0 0 0 0 1])
             value.rotais = '��ÿ30s��������5�ȵ�������ת��TI�����ã�';
         elseif(data_out(44:50)==zeros(1, 7))
             value.rotais = 'û�п��õ���ת��Ϣ';
         else
             value.rotais = 'ÿ�����������708�Ȼ����';
         end
 end
 
 %���溽��SOG
  switch 2.^(9:-1:0)*(data_out(51:60))'
      case 1023
          value.sog = '������';
      otherwise
          value.sog = [num2str(2.^(9:-1:0)*(data_out(51:60))'/10) '��'];
  end
  
  %λ��׼ȷ��
  switch data_out(61)
      case 0
          value.pa = '��';
      case 1
          value.pa = '��';
  end
  
  %����
  switch data_out(62)
      case 0
          longtitude = 2.^(26:-1:0)*(data_out(63:89))'*60/10000;
          sec = mod(longtitude, 60);  %��
          minute = mod(floor(longtitude/60), 60);  %��
          deg = floor(floor(longtitude/60)/60);  %��
          if(longtitude < 648000)
              value.lon = ['����' num2str(deg) '��' num2str(minute) '��'...
                        num2str(sec) '��'];
          else
              value.lon = '������';
          end
      case 1
          longtitude = (2^28 - 1 - ((2.^(27:-1:0)*(data_out(62:89))')-1))*60/10000;
          sec = mod(longtitude, 60);  %��
          minute = mod(floor(longtitude/60), 60);  %��
          deg = floor(floor(longtitude/60)/60);  %��
          if(longtitude <= 648000)
              value.lon = ['����' num2str(deg) '��' num2str(minute) '��'...
                        num2str(sec) '��'];
          else
              value.lon = '������';
          end
  end
  
  %γ��
  switch data_out(90)
      case 0
          latitude = 2.^(25:-1:0)*(data_out(91:116))'*60/10000;
          sec = mod(latitude, 60);  %��
          minute = mod(floor(latitude/60), 60);  %��
          deg = floor(floor(latitude/60)/60);  %��
          if(latitude < 324000)
              value.la = ['��γ' num2str(deg) '��' num2str(minute) '��'...
                        num2str(sec) '��'];
          else
              value.la = '������';
          end
      case 1
          latitude = (2^27 - 1 - ((2.^(26:-1:0)*(data_out(90:116))')-1))*60/10000;
          sec = mod(latitude, 60);  %��
          minute = mod(floor(latitude/60), 60);  %��
          deg = floor(floor(latitude/60)/60);  %��
          if(latitude <= 324000)
              value.la = ['��γ' num2str(deg) '��' num2str(minute) '��'...
                        num2str(sec) '��'];
          else
              value.la = '������';
          end
  end        
  
  %���溽��COG
  if(2.^(11:-1:0)*(data_out(117:128))' < 3600)
      cog = 2.^(11:-1:0)*(data_out(117:128))'/10;
      value.cog = [num2str(cog) '��'];
  else
      value.cog = '������';
  end
  
  %ʵ�ʺ���
  if(2.^(8:-1:0)*(data_out(129:137))' < 360)
      dir = 2.^(8:-1:0)*(data_out(129:137))';
      value.dir = [num2str(dir) '��'];
  else
      value.dir = '������';
  end
  
  %ʱ��
  switch 2.^(5:-1:0)*(data_out(138:143))'
      case 60
          value.time = 'ʱ��������';
      case 61
          value.time = '��λϵͳ���˹�����ģʽ';
      case 62
          value.time = '���Ӷ�λϵͳ�ڹ��ƣ��������㣩ģʽ��';
      case 63
          value.time = '��λϵͳ��������';
      otherwise
          value.time = [num2str(2.^(5:-1:0)*(data_out(138:143))') 's'];
  end
  
  %�ض�����ָʾ��
  switch 2.^(1:-1:0)*(data_out(144:145))'
      case 1
          value.ctrl = 'δ�����ض�����';
      case 2
          value.ctrl = '�����ض�����';
      otherwise
          value.ctrl = '������';
  end
  
  %RAIM��־
  if(data_out(149) == 0)
      value.raim = 'RAIMδʹ��';
  else
      value.raim = 'RAIM����ʹ��';
  end
  
  %ͨ��״̬
  if(isequal([1 1 0 0 0 1], data_out(1:6)))
      value.tele = 'SOTDMAͨ��״̬';
  elseif (isequal([1 1 0 0 1 0], data_out(1:6)))
      value.tele = 'SOTDMAͨ��״̬';
  elseif (isequal([1 1 0 0 1 1], data_out(1:6)))
      value.tele = 'ITDMAͨ��״̬';
  else
      value.tele = '��';
  end
  
  %% ------------------------------��Ϣ��ʾ-----------------------------
  value = struct2cell(value); 
  fp = fopen('D:\AIS_demo\matlab_sim\AIS_msg.txt', 'wt');
  for i = 1:length(value)
      fprintf(fp, [char(para(i)), ':', ' ',  char(value(i)), '\n']);
  end
  fclose(fp);
  