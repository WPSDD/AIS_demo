%% ------------------------------参数解译-----------------------------
para = {'消息ID', '转发指示符', '用户ID', '导航状态', '旋转速率', '地面航速', '位置准确度',...
    '经度', '纬度', '地面航线', '实际航向', '时戳', '特定操作指示符', 'RAIM标志', '通信状态'};

value = struct;  %初始化结构体value
%消息ID
if(isequal([1 1 0 0 0 1], data_out(1:6)))
    value.msg_id = '1';
elseif (isequal([1 1 0 0 1 0], data_out(1:6)))
    value.msg_id = '2';
elseif (isequal([1 1 0 0 1 1], data_out(1:6)))
    value.msg_id = '3';
else
    value.msg_id = '0';
end

%转发指示符，表明某个消息被转发了多少次
 switch 2.^([1 0])*(data_out(7:8))'
     case 0
         value.retran_ind = '默认';
     case 3
         value.retran_ind = '不再转发';
     otherwise
         value.retran_ind = num2str(2.^([1 0])*(data_out(7:8))');
 end
 
 %用户ID，唯一标识符
 value.user_id = num2str(2.^(29:-1:0)*(data_out(9:38))');
 
 %导航状态
 switch 2.^(3:-1:0)*(data_out(39:42))'
     case 0
         value.navi_state = '发动机使用中';
     case 1
         value.navi_state = '锚泊';
     case 2
         value.navi_state = '未操纵';
     case 3
         value.navi_state = '有限适航性';
     case 4
         value.navi_state = '受船舶吃水限制';
     case 5
         value.navi_state = '系泊';
     case 6
         value.navi_state = '搁浅';
     case 7
         value.navi_state = '从事捕捞';
     case 8
         value.navi_state = '航行中';
     case {9, 10}
         value.navi_state = '留做将来修正导航状态';
     case {11, 12, 13}
         value.navi_state = '留做将来用';
     case 14
         value.navi_state = 'AIS-SART';
     case 15
         value.navi_state = '未规定';
 end
 
 %旋转速率ROTAIS
 switch data_out(43)
     case 0
         if(data_out(44:50)==ones(1, 7))
             value.rotais = '以每30s右旋超过5度的速率旋转（TI不可用）';
         else
             value.rotais = '每分钟右旋最多708度或更快';
         end
     case 1
         if(data_out(44:50)==[0 0 0 0 0 0 1])
             value.rotais = '以每30s左旋超过5度的速率旋转（TI不可用）';
         elseif(data_out(44:50)==zeros(1, 7))
             value.rotais = '没有可用的旋转信息';
         else
             value.rotais = '每分钟左旋最多708度或更快';
         end
 end
 
 %地面航速SOG
  switch 2.^(9:-1:0)*(data_out(51:60))'
      case 1023
          value.sog = '不可用';
      otherwise
          value.sog = [num2str(2.^(9:-1:0)*(data_out(51:60))'/10) '节'];
  end
  
  %位置准确度
  switch data_out(61)
      case 0
          value.pa = '低';
      case 1
          value.pa = '高';
  end
  
  %经度
  switch data_out(62)
      case 0
          longtitude = 2.^(26:-1:0)*(data_out(63:89))'*60/10000;
          sec = mod(longtitude, 60);  %秒
          minute = mod(floor(longtitude/60), 60);  %分
          deg = floor(floor(longtitude/60)/60);  %度
          if(longtitude < 648000)
              value.lon = ['东经' num2str(deg) '度' num2str(minute) '分'...
                        num2str(sec) '秒'];
          else
              value.lon = '不可用';
          end
      case 1
          longtitude = (2^28 - 1 - ((2.^(27:-1:0)*(data_out(62:89))')-1))*60/10000;
          sec = mod(longtitude, 60);  %秒
          minute = mod(floor(longtitude/60), 60);  %分
          deg = floor(floor(longtitude/60)/60);  %度
          if(longtitude <= 648000)
              value.lon = ['西经' num2str(deg) '度' num2str(minute) '分'...
                        num2str(sec) '秒'];
          else
              value.lon = '不可用';
          end
  end
  
  %纬度
  switch data_out(90)
      case 0
          latitude = 2.^(25:-1:0)*(data_out(91:116))'*60/10000;
          sec = mod(latitude, 60);  %秒
          minute = mod(floor(latitude/60), 60);  %分
          deg = floor(floor(latitude/60)/60);  %度
          if(latitude < 324000)
              value.la = ['北纬' num2str(deg) '度' num2str(minute) '分'...
                        num2str(sec) '秒'];
          else
              value.la = '不可用';
          end
      case 1
          latitude = (2^27 - 1 - ((2.^(26:-1:0)*(data_out(90:116))')-1))*60/10000;
          sec = mod(latitude, 60);  %秒
          minute = mod(floor(latitude/60), 60);  %分
          deg = floor(floor(latitude/60)/60);  %度
          if(latitude <= 324000)
              value.la = ['南纬' num2str(deg) '度' num2str(minute) '分'...
                        num2str(sec) '秒'];
          else
              value.la = '不可用';
          end
  end        
  
  %地面航线COG
  if(2.^(11:-1:0)*(data_out(117:128))' < 3600)
      cog = 2.^(11:-1:0)*(data_out(117:128))'/10;
      value.cog = [num2str(cog) '度'];
  else
      value.cog = '不可用';
  end
  
  %实际航向
  if(2.^(8:-1:0)*(data_out(129:137))' < 360)
      dir = 2.^(8:-1:0)*(data_out(129:137))';
      value.dir = [num2str(dir) '度'];
  else
      value.dir = '不可用';
  end
  
  %时戳
  switch 2.^(5:-1:0)*(data_out(138:143))'
      case 60
          value.time = '时戳不可用';
      case 61
          value.time = '定位系统在人工输入模式';
      case 62
          value.time = '电子定位系统在估计（航迹推算）模式下';
      case 63
          value.time = '定位系统不起作用';
      otherwise
          value.time = [num2str(2.^(5:-1:0)*(data_out(138:143))') 's'];
  end
  
  %特定操纵指示符
  switch 2.^(1:-1:0)*(data_out(144:145))'
      case 1
          value.ctrl = '未进行特定操纵';
      case 2
          value.ctrl = '进行特定操纵';
      otherwise
          value.ctrl = '不可用';
  end
  
  %RAIM标志
  if(data_out(149) == 0)
      value.raim = 'RAIM未使用';
  else
      value.raim = 'RAIM正在使用';
  end
  
  %通信状态
  if(isequal([1 1 0 0 0 1], data_out(1:6)))
      value.tele = 'SOTDMA通信状态';
  elseif (isequal([1 1 0 0 1 0], data_out(1:6)))
      value.tele = 'SOTDMA通信状态';
  elseif (isequal([1 1 0 0 1 1], data_out(1:6)))
      value.tele = 'ITDMA通信状态';
  else
      value.tele = '无';
  end
  
  %% ------------------------------信息显示-----------------------------
  value = struct2cell(value); 
  fp = fopen('D:\AIS_demo\matlab_sim\AIS_msg.txt', 'wt');
  for i = 1:length(value)
      fprintf(fp, [char(para(i)), ':', ' ',  char(value(i)), '\n']);
  end
  fclose(fp);
  