function varargout = AIS_gui(varargin)
% AIS_GUI MATLAB code for AIS_gui.fig
%      AIS_GUI, by itself, creates a new AIS_GUI or raises the existing
%      singleton*.
%
%      H = AIS_GUI returns the handle to a new AIS_GUI or the handle to
%      the existing singleton*.
%
%      AIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AIS_GUI.M with the given input arguments.
%
%      AIS_GUI('Property','Value',...) creates a new AIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AIS_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AIS_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AIS_gui

% Last Modified by GUIDE v2.5 10-Dec-2019 17:16:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AIS_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @AIS_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AIS_gui is made visible.
function AIS_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AIS_gui (see VARARGIN)

% Choose default command line output for AIS_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AIS_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AIS_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global f_sample fc dt N_sample b_num I_t Q_t t
% ------------------------------数字下变频-----------------------------
f_dpl = 4000 * (2*rand-1);                  %多普勒频移，范围一般在4kHz以内
gmsk_dpl = I_t.*cos(2*pi*(fc+f_dpl)*t)...
           - Q_t.*sin(2*pi*(fc+f_dpl)*t);   %卫星相对接收机运动产生多普勒频移
gmsk_rcv = awgn(gmsk_dpl, str2double(get(handles.edit1, 'string')), 'measured');  %信号经过AWGN信道的信噪比
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


% ------------------------------1bit差分解调-----------------------------
delay = str2double(get(handles.edit3, 'string'))/1000;                                                  %信号传输过程的时延（ms转换为s）
dt_rcv = dt * 25 * 25;
ave_dist = sum(sqrt(I_de0.^2 + Q_de0.^2)) / length(I_de0);                  %相位图上的点到原点的平均距离
I_de = [2*rand(1, round(delay/dt_rcv))-1, I_de0];                           %抽取滤波后的同相信号分量
Q_de = [2*rand(1, round(delay/dt_rcv))-1, Q_de0];                           %抽取滤波后的正交信号分量
I_de = I_de/ave_dist;                                                       %归一化
Q_de = Q_de/ave_dist;                                                       %归一化
N_sample_rcv = 8;                                                           %抽取滤波后的每码元采样点数
f_de0 = [zeros(1, N_sample_rcv) I_de(1:end-N_sample_rcv)] .* Q_de -...
        [zeros(1, N_sample_rcv) Q_de(1:end-N_sample_rcv)] .* I_de;           %1bit差分法求频率点

% ------------------------------时延估计-----------------------------
loc = reshape([zeros(1, 6); zeros(1, 6); ones(1, 6); ones(1, 6)], 1, 24);       %本地训练序列
loc = 2 * kron(loc, ones(1, N_sample_rcv)) - 1;                                 %上采样
[xcorr_data, move_num] = xcorr(f_de0, [zeros(1, 8*N_sample_rcv) loc], 'none');   %求本地训练序列与信号的互相关函数
[~, max_num] = max(xcorr_data);                                                 %互相关函数最大值下标
delay_num = move_num(max_num);                                                  %估计时延的采样点数
delay_est = delay_num * dt_rcv;                                                 %时延估计值
f_de = f_de0(delay_num:end);

% ------------------------------抽样判决-----------------------------
if length(f_de) >= b_num * N_sample_rcv
    f_de = f_de(1:b_num * N_sample_rcv);
else
    f_de = [f_de f_de(end) * ones(1, b_num*N_sample_rcv-length(f_de))];
end
AIS_out = f_de(N_sample_rcv:N_sample_rcv:end) > 0;                      %大于0判为1，否则判为0

% ------------------------------数据提取-----------------------------
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

%反填充
m=[];
for i = 6:length(data_out)
    if(prod(data_out(i-5:i-1))==1 && data_out(i)==0)
        m = [m i];                              %存储填充0码的下标信息
    end
end
data_out(m) = [];                               %删去填充的0码

% ------------------------------CRC校验-----------------------------
global generator
data_final = data_out(1:168);                   %取数据位
temp = [data_final zeros(1, 16)];               %将数据位移位
[divid_out, remainder_out] = deconv(temp, generator);     
remainder_out = mod(remainder_out(end-15:end),2);
if isequal(remainder_out, data_out(169:184))    %求得的余式与校验序列比较，若相同则解调正确
    msgbox('解调正确！', 'Success', 'modal');
else
    msgbox('解调错误，产生误码 :-(', 'Error', 'error');
end


% ------------------------------参数解译-----------------------------
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
  
  % ------------------------------信息显示-----------------------------
  value = struct2cell(value); 
  str_print = [];
  for i = 1:length(value)
      str_print = [str_print, char(para(i)), ':', ' ',  char(value(i)), 10];
  end
  set(handles.edit4, 'string', str_print)
  
  
  % ------------------------------波形绘制-----------------------------
%set(handles.text14, 'string', '解调过程信号波形');
axes(handles.axes1);
plot(1000*t(1:25*25:end), I_de(1:length(t(1:25*25:end))), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text8, 'string', '解调出的I路');
axes(handles.axes2);
plot(1000*t(1:25*25:end), Q_de(1:length(t(1:25*25:end))), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text9, 'string', '解调出的Q路');
axes(handles.axes3);
plot(1000*t(1:25*25:end), f_de0(1:length(t(1:25*25:end))), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text10, 'string', '差分解调后');
axes(handles.axes4);
plot(1000*t(1:25*25:end), f_de, 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text11, 'string', '时延纠正后');
axes(handles.axes5)
plot(1000*t, kron(AIS_out, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text12, 'string', '抽样判决后');
axes(handles.axes7)
plot(1000*t, kron(AIS_out_denrzi, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text15, 'string', 'NRZI解码后');
axes(handles.axes8)
plot(1000*t(1:length(data_out)*N_sample), kron(data_out, ones(1, N_sample)), 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-0.2 1.2]);  
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text16, 'string', '反填充后');
axes(handles.axes6)
plot(1000*t(1:168*N_sample), kron(data_out(1:168), ones(1, N_sample)), 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-0.2 1.2]);  xlabel('时间/ms');
set(gca, 'Ytick', [0 1], 'Xtick', [0 5 10 15 20 25],  'fontsize', 7);  
set(handles.text13, 'string', '解调出的数据');


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ------------------------------生成信号-----------------------------
rising_edge = zeros(1, 8);                                   %8bit上升沿
training_seq = reshape([zeros(1, 12); ones(1, 12)], 1, 24);  %24bit训练序列“0101…”
start_flag = [0 ones(1, 6) 0];                               %8bit开始标志（01111110）
switch get(handles.popupmenu1, 'value')
    case 1
        prefix = [1 1 0 0 0 1];
    case 2
        prefix = [1 1 0 0 1 0];
    case 3
        prefix = [1 1 0 0 1 1];
end
data_in = [prefix (randsrc(1, 162) + 1) / 2];                %随机产生168bit数据
frame_check = zeros(1, 16);                                  %初始化帧校验序列
end_flag = start_flag;                                       %结束标志（与开始标志相同）
buffer = zeros(1, 24);                                       %24bit缓冲位

% ------------------------------添加CRC校验码-----------------------------
global generator
generator = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];  %生成多项式1+x^5+x^12+x^16
data = [data_in frame_check];                     %数据向左移16位，以计算帧校验序列并添加在末尾
[divid, remainder] = deconv(data, generator);     %移位后的数据除以生成多项式，得到商和余式
remainder = mod(remainder(end-15:end),2);         %取余式后16位并模2处理，得到帧校验序列
data(end-15:end) = remainder;                     %将帧校验序列添加在数据末尾
data_crc = data;                                  %存储添加CRC校验码后的数据

% ------------------------------AIS信息帧-----------------------------
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

% ------------------------------参数设置-----------------------------
global Tb BTb B fc N_sample f_sample b_num dt t I_t Q_t
Tb = 1/9600;                                        %码元宽度为1/9600s
BTb = 0.4;                                          %归一化带宽B*Tb为0.4
B = BTb/Tb;                                         %3dB带宽
fc = 161.975e6;                                     %载波频率为161.975MHz
N_sample = 5000;                                    %每码元采样点数
f_sample = N_sample/Tb;                             %采样频率为64倍码速率
b_num = 256;                                        %基带信号为256个码元
dt = 1/f_sample;                                    %采样间隔
t = 0:dt:b_num*Tb-dt;                               %仿真离散时间
data_sample = kron(2*AIS_in-1, ones(1, N_sample));  %码元扩展(上采样)
alpha = sqrt(log(2))/2/B;                           %高斯滤波器的参数
h = 0.5;                                            %调制指数为0.5

% ------------------------------高斯滤波-----------------------------
t_gauss = -3*Tb:dt:3*Tb;                                %滤波器冲激响应函数截断后的时间范围
h_gauss = sqrt(pi)/alpha*exp(-(pi*t_gauss/alpha).^2);   %滤波器冲激响应函数
gi = conv(data_sample/Tb, h_gauss) * dt;                %计算卷积产生高斯脉冲信号

% ------------------------------MSK调制-----------------------------
gi = gi(3*N_sample+1:end-3*N_sample)';              %将高斯脉冲信号截取在仿真的时间范围
phi = pi*h*dt*cumsum(gi)';                          %求和代替积分，求相位函数
I_t = cos(phi);                                     %信号的同相分量
Q_t = sin(phi);                                     %信号的正交分量
gmsk = I_t.*cos(2*pi*fc*t) - Q_t.*sin(2*pi*fc*t);   %GMSK调制信号
msgbox('调制成功！', 'Success', 'modal');
set(handles.edit4, 'string', []);                   %清空消息内容

% ------------------------------波形绘制-----------------------------
%set(handles.text14, 'string', '调制过程信号波形');
axes(handles.axes1);
plot(1000*t(1:length(data_in)*N_sample), kron(data_in, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text8, 'string', '原始数据');
axes(handles.axes2);
plot(1000*t(1:length(data_crc)*N_sample), kron(data_crc, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text9, 'string', 'CRC校验后');
axes(handles.axes3)
plot(1000*t, kron(AIS1, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text10, 'string', 'HDLC打包后');
axes(handles.axes4)
plot(1000*t, kron(2*AIS_in-1, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.3 1.3]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text11, 'string', 'NRZI编码后');
axes(handles.axes5)
plot(1000*t, gi, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([1.5*min(gi) 1.5*max(gi)]);  set(gca, 'YtickLabel', '0');
set(gca, 'xtick', -inf:inf:inf, 'Ytick', 0, 'fontsize', 7);  
set(handles.text12, 'string', '高斯滤波后');
axes(handles.axes7)
plot(1000*t, I_t, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-1.3 1.3]);  
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text15, 'string', 'I支路');
axes(handles.axes8)
plot(1000*t, Q_t, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-1.3 1.3]);  
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text16, 'string', 'Q支路');
axes(handles.axes6)
plot(1000*t, gmsk, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-1.3 1.3]);  xlabel('时间/ms')
set(gca, 'Ytick', [-1 0 1], 'Xtick', [0 5 10 15 20 25], 'fontsize', 7);  
set(handles.text13, 'string', 'GMSK调制后');



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
