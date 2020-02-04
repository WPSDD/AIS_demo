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
% ------------------------------�����±�Ƶ-----------------------------
f_dpl = 4000 * (2*rand-1);                  %������Ƶ�ƣ���Χһ����4kHz����
gmsk_dpl = I_t.*cos(2*pi*(fc+f_dpl)*t)...
           - Q_t.*sin(2*pi*(fc+f_dpl)*t);   %������Խ��ջ��˶�����������Ƶ��
gmsk_rcv = awgn(gmsk_dpl, str2double(get(handles.edit1, 'string')), 'measured');  %�źž���AWGN�ŵ��������
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


% ------------------------------1bit��ֽ��-----------------------------
delay = str2double(get(handles.edit3, 'string'))/1000;                                                  %�źŴ�����̵�ʱ�ӣ�msת��Ϊs��
dt_rcv = dt * 25 * 25;
ave_dist = sum(sqrt(I_de0.^2 + Q_de0.^2)) / length(I_de0);                  %��λͼ�ϵĵ㵽ԭ���ƽ������
I_de = [2*rand(1, round(delay/dt_rcv))-1, I_de0];                           %��ȡ�˲����ͬ���źŷ���
Q_de = [2*rand(1, round(delay/dt_rcv))-1, Q_de0];                           %��ȡ�˲���������źŷ���
I_de = I_de/ave_dist;                                                       %��һ��
Q_de = Q_de/ave_dist;                                                       %��һ��
N_sample_rcv = 8;                                                           %��ȡ�˲����ÿ��Ԫ��������
f_de0 = [zeros(1, N_sample_rcv) I_de(1:end-N_sample_rcv)] .* Q_de -...
        [zeros(1, N_sample_rcv) Q_de(1:end-N_sample_rcv)] .* I_de;           %1bit��ַ���Ƶ�ʵ�

% ------------------------------ʱ�ӹ���-----------------------------
loc = reshape([zeros(1, 6); zeros(1, 6); ones(1, 6); ones(1, 6)], 1, 24);       %����ѵ������
loc = 2 * kron(loc, ones(1, N_sample_rcv)) - 1;                                 %�ϲ���
[xcorr_data, move_num] = xcorr(f_de0, [zeros(1, 8*N_sample_rcv) loc], 'none');   %�󱾵�ѵ���������źŵĻ���غ���
[~, max_num] = max(xcorr_data);                                                 %����غ������ֵ�±�
delay_num = move_num(max_num);                                                  %����ʱ�ӵĲ�������
delay_est = delay_num * dt_rcv;                                                 %ʱ�ӹ���ֵ
f_de = f_de0(delay_num:end);

% ------------------------------�����о�-----------------------------
if length(f_de) >= b_num * N_sample_rcv
    f_de = f_de(1:b_num * N_sample_rcv);
else
    f_de = [f_de f_de(end) * ones(1, b_num*N_sample_rcv-length(f_de))];
end
AIS_out = f_de(N_sample_rcv:N_sample_rcv:end) > 0;                      %����0��Ϊ1��������Ϊ0

% ------------------------------������ȡ-----------------------------
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

%�����
m=[];
for i = 6:length(data_out)
    if(prod(data_out(i-5:i-1))==1 && data_out(i)==0)
        m = [m i];                              %�洢���0����±���Ϣ
    end
end
data_out(m) = [];                               %ɾȥ����0��

% ------------------------------CRCУ��-----------------------------
global generator
data_final = data_out(1:168);                   %ȡ����λ
temp = [data_final zeros(1, 16)];               %������λ��λ
[divid_out, remainder_out] = deconv(temp, generator);     
remainder_out = mod(remainder_out(end-15:end),2);
if isequal(remainder_out, data_out(169:184))    %��õ���ʽ��У�����бȽϣ�����ͬ������ȷ
    msgbox('�����ȷ��', 'Success', 'modal');
else
    msgbox('������󣬲������� :-(', 'Error', 'error');
end


% ------------------------------��������-----------------------------
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
  
  % ------------------------------��Ϣ��ʾ-----------------------------
  value = struct2cell(value); 
  str_print = [];
  for i = 1:length(value)
      str_print = [str_print, char(para(i)), ':', ' ',  char(value(i)), 10];
  end
  set(handles.edit4, 'string', str_print)
  
  
  % ------------------------------���λ���-----------------------------
%set(handles.text14, 'string', '��������źŲ���');
axes(handles.axes1);
plot(1000*t(1:25*25:end), I_de(1:length(t(1:25*25:end))), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text8, 'string', '�������I·');
axes(handles.axes2);
plot(1000*t(1:25*25:end), Q_de(1:length(t(1:25*25:end))), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text9, 'string', '�������Q·');
axes(handles.axes3);
plot(1000*t(1:25*25:end), f_de0(1:length(t(1:25*25:end))), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text10, 'string', '��ֽ����');
axes(handles.axes4);
plot(1000*t(1:25*25:end), f_de, 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text11, 'string', 'ʱ�Ӿ�����');
axes(handles.axes5)
plot(1000*t, kron(AIS_out, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text12, 'string', '�����о���');
axes(handles.axes7)
plot(1000*t, kron(AIS_out_denrzi, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text15, 'string', 'NRZI�����');
axes(handles.axes8)
plot(1000*t(1:length(data_out)*N_sample), kron(data_out, ones(1, N_sample)), 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-0.2 1.2]);  
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text16, 'string', '������');
axes(handles.axes6)
plot(1000*t(1:168*N_sample), kron(data_out(1:168), ones(1, N_sample)), 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-0.2 1.2]);  xlabel('ʱ��/ms');
set(gca, 'Ytick', [0 1], 'Xtick', [0 5 10 15 20 25],  'fontsize', 7);  
set(handles.text13, 'string', '�����������');


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
% ------------------------------�����ź�-----------------------------
rising_edge = zeros(1, 8);                                   %8bit������
training_seq = reshape([zeros(1, 12); ones(1, 12)], 1, 24);  %24bitѵ�����С�0101����
start_flag = [0 ones(1, 6) 0];                               %8bit��ʼ��־��01111110��
switch get(handles.popupmenu1, 'value')
    case 1
        prefix = [1 1 0 0 0 1];
    case 2
        prefix = [1 1 0 0 1 0];
    case 3
        prefix = [1 1 0 0 1 1];
end
data_in = [prefix (randsrc(1, 162) + 1) / 2];                %�������168bit����
frame_check = zeros(1, 16);                                  %��ʼ��֡У������
end_flag = start_flag;                                       %������־���뿪ʼ��־��ͬ��
buffer = zeros(1, 24);                                       %24bit����λ

% ------------------------------���CRCУ����-----------------------------
global generator
generator = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];  %���ɶ���ʽ1+x^5+x^12+x^16
data = [data_in frame_check];                     %����������16λ���Լ���֡У�����в������ĩβ
[divid, remainder] = deconv(data, generator);     %��λ������ݳ������ɶ���ʽ���õ��̺���ʽ
remainder = mod(remainder(end-15:end),2);         %ȡ��ʽ��16λ��ģ2�����õ�֡У������
data(end-15:end) = remainder;                     %��֡У���������������ĩβ
data_crc = data;                                  %�洢���CRCУ����������

% ------------------------------AIS��Ϣ֡-----------------------------
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

% ------------------------------��������-----------------------------
global Tb BTb B fc N_sample f_sample b_num dt t I_t Q_t
Tb = 1/9600;                                        %��Ԫ���Ϊ1/9600s
BTb = 0.4;                                          %��һ������B*TbΪ0.4
B = BTb/Tb;                                         %3dB����
fc = 161.975e6;                                     %�ز�Ƶ��Ϊ161.975MHz
N_sample = 5000;                                    %ÿ��Ԫ��������
f_sample = N_sample/Tb;                             %����Ƶ��Ϊ64��������
b_num = 256;                                        %�����ź�Ϊ256����Ԫ
dt = 1/f_sample;                                    %�������
t = 0:dt:b_num*Tb-dt;                               %������ɢʱ��
data_sample = kron(2*AIS_in-1, ones(1, N_sample));  %��Ԫ��չ(�ϲ���)
alpha = sqrt(log(2))/2/B;                           %��˹�˲����Ĳ���
h = 0.5;                                            %����ָ��Ϊ0.5

% ------------------------------��˹�˲�-----------------------------
t_gauss = -3*Tb:dt:3*Tb;                                %�˲����弤��Ӧ�����ضϺ��ʱ�䷶Χ
h_gauss = sqrt(pi)/alpha*exp(-(pi*t_gauss/alpha).^2);   %�˲����弤��Ӧ����
gi = conv(data_sample/Tb, h_gauss) * dt;                %������������˹�����ź�

% ------------------------------MSK����-----------------------------
gi = gi(3*N_sample+1:end-3*N_sample)';              %����˹�����źŽ�ȡ�ڷ����ʱ�䷶Χ
phi = pi*h*dt*cumsum(gi)';                          %��ʹ�����֣�����λ����
I_t = cos(phi);                                     %�źŵ�ͬ�����
Q_t = sin(phi);                                     %�źŵ���������
gmsk = I_t.*cos(2*pi*fc*t) - Q_t.*sin(2*pi*fc*t);   %GMSK�����ź�
msgbox('���Ƴɹ���', 'Success', 'modal');
set(handles.edit4, 'string', []);                   %�����Ϣ����

% ------------------------------���λ���-----------------------------
%set(handles.text14, 'string', '���ƹ����źŲ���');
axes(handles.axes1);
plot(1000*t(1:length(data_in)*N_sample), kron(data_in, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text8, 'string', 'ԭʼ����');
axes(handles.axes2);
plot(1000*t(1:length(data_crc)*N_sample), kron(data_crc, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text9, 'string', 'CRCУ���');
axes(handles.axes3)
plot(1000*t, kron(AIS1, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-0.2 1.2]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 7);  
set(handles.text10, 'string', 'HDLC�����');
axes(handles.axes4)
plot(1000*t, kron(2*AIS_in-1, ones(1, N_sample)), 'LineWidth', 0.7);  xlim([0 27]);  ylim([-1.3 1.3]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text11, 'string', 'NRZI�����');
axes(handles.axes5)
plot(1000*t, gi, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([1.5*min(gi) 1.5*max(gi)]);  set(gca, 'YtickLabel', '0');
set(gca, 'xtick', -inf:inf:inf, 'Ytick', 0, 'fontsize', 7);  
set(handles.text12, 'string', '��˹�˲���');
axes(handles.axes7)
plot(1000*t, I_t, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-1.3 1.3]);  
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text15, 'string', 'I֧·');
axes(handles.axes8)
plot(1000*t, Q_t, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-1.3 1.3]);  
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 7);  
set(handles.text16, 'string', 'Q֧·');
axes(handles.axes6)
plot(1000*t, gmsk, 'LineWidth', 0.7);  
xlim([0 27]);  ylim([-1.3 1.3]);  xlabel('ʱ��/ms')
set(gca, 'Ytick', [-1 0 1], 'Xtick', [0 5 10 15 20 25], 'fontsize', 7);  
set(handles.text13, 'string', 'GMSK���ƺ�');



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
