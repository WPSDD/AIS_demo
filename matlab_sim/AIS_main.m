clear   %清空工作区
clc     %清空命令行窗口
tic     %开始计时
%% ------------------------------AIS信号传输流程-----------------------------
transmitting_dsp    %发送端数据处理
GMSK_modulator      %GMSK调制
GMSK_demodulator    %GMSK解调
receiving_dsp       %接收端数据处理
msg123              %消息内容显示

%% ------------------------------绘制关键波形-----------------------------
%AIS信号传输过程信号波形
figure(1);
subplot('position', [0.1 0.74 0.8 0.16]);
plot(data_in, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 10);  ylabel('原始数据');
title('AIS信号传输过程数据波形');  set(get(gca, 'title'), 'FontSize', 13);
subplot('position', [0.1 0.58 0.8 0.16]);
plot(AIS1, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 10);  ylabel('AIS信号帧');
subplot('position', [0.1 0.42 0.8 0.16]);
plot(AIS_out_denrzi, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 10);  ylabel('解调后信号帧');
subplot('position', [0.1 0.26 0.8 0.16]);
plot(data_final, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'Ytick', [0 1], 'fontsize', 10);  xlabel('位数/bits');  ylabel('解调出的数据');

%GMSK调制解调过程信号波形
figure(2);
subplot('position', [0.1 0.74 0.8 0.16]);
plot(1000*t, data_sample, 'LineWidth', 1);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('NRZI后');
title('GMSK调制解调过程信号波形');  set(get(gca, 'title'), 'FontSize', 13);
subplot('position', [0.1 0.58 0.8 0.16]);
plot(1000*t, gi(3*N_sample+1:end-3*N_sample), 'LineWidth', 1);  ylim([1.5*min(gi) 1.5*max(gi)]);
set(gca,'xtick', -inf:inf:inf,'Ytick', 0 , 'fontsize', 10);  
set(gca, 'YtickLabel', '0');
ylabel('高斯滤波后');
subplot('position', [0.1 0.42 0.8 0.16]);
plot(1000*t(1:25*25:end), f_de, 'LineWidth', 1);  ylim([1.5*min(f_de) 1.5*max(f_de)]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('解调后');
subplot('position', [0.1 0.26 0.8 0.16]);
plot(1000*t, kron(2*AIS_out-1, ones(1, N_sample)), 'LineWidth', 1);  ylim([-1.5 1.5]);
set(gca, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('判决后');
xlabel('时间/ms');

%上下变频过程波形
figure(3);
fig_x = 0.1;    fig_y = 0.83;            %第一个子图左上角的坐标
fig_len = 0.8;  fig_hight = 0.125;       %子图的长度和高度
subplot('position', [fig_x fig_y fig_len fig_hight]);
plot(1000*t, phi, 'LineWidth', 1.5);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0], 'fontsize', 10);
ylabel('\phi(t)', 'FontSize', 10);
title('上下变频过程信号波形');  set(get(gca, 'title'), 'FontSize', 13);
subplot('position', [fig_x fig_y-fig_hight fig_len fig_hight]);
plot(1000*t, I_t, 'b', 1000*t, Q_t, 'r');  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('I、Q分量', 'FontSize', 10);
legend('I路', 'Q路');
subplot('position', [fig_x fig_y-2*fig_hight fig_len fig_hight]);
plot(1000*t, gmsk);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('GMSK信号', 'FontSize', 10);
subplot('position', [fig_x fig_y-3*fig_hight fig_len fig_hight]);
plot(1000*t, gmsk_rcv);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('AD后', 'FontSize', 10);

subplot('position', [fig_x fig_y-4*fig_hight fig_len fig_hight]);
plot(1000*t, In, 1000*t, Qn); 
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0], 'fontsize', 10);
ylabel('正交下变频后', 'FontSize', 10); 
legend('I路', 'Q路');

subplot('position', [fig_x fig_y-5*fig_hight fig_len fig_hight]);
plot(1000*t(1:r1:end), In_cic, 1000*t(1:r1:end), Qn_cic); 
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0], 'fontsize', 10);
ylabel('CIC滤波后', 'FontSize', 10);      
legend('I路', 'Q路');
subplot('position', [fig_x fig_y-6*fig_hight fig_len fig_hight]);
plot(1000*t(1:r1*r2*r3:end), I_de0, 1000*t(1:r1*r2*r3:end), Q_de0);
set(gca,'Ytick', [0], 'fontsize', 10);
xlabel('时间/ms', 'FontSize', 10);
ylabel('FIR滤波后', 'FontSize', 10);      
legend('I路', 'Q路');

%相位网格图，验证GMSK相位每Tb变化pi/2的性质
figure(4)
plot(1000*t, phi, 'LineWidth', 1.5);  
title('调制的相位函数');  xlabel('时间/ms');  ylabel('相位');
hold on;
T = 1000*t;
y1 = zeros(85, 2);
y2 = zeros(85, 2);
for i = 1:85
    y1(i, :) = pi/(2000*Tb)*[T(1) T(end)] + pi/2*(15-i);
    y2(i, :) = - pi/(2000*Tb)*[T(1) T(end)] - pi/2*(15-i);
    plot([T(1) T(end)], y1(i, :), 'g', 'LineWidth', 0.2)
    hold on
    plot([T(1) T(end)], y2(i, :), 'g', 'LineWidth', 0.2)
    hold on
end
xlim([3 6]);  ylim([-15 0]);

%GMSK信号相位图
figure(5); plot(I_t, Q_t, 'r.');
hold on;  plot(I_de(delay_num+2:end), Q_de(delay_num+2:end), 'b.');
xlim([-1.2 1.2]);   ylim([-1.2 1.2]);
grid on
legend('调制前', '解调后');
title('GMSK信号相位图');  
xlabel('I支路');  ylabel('Q支路');
axis equal

t_run = toc;    
fprintf('仿真时间：%8fs', t_run);

% fp = fopen('D:\AIS_demo\modelsim_sim\anti_padding\sim\data_pad.txt', 'wt');
% for i = 1:length(data_pad)
%       fprintf(fp, '%d\n', data_pad(i));
% end
% fclose(fp);
% 
% fp = fopen('D:\AIS_demo\modelsim_sim\de_nrzi\sim\data_demo.txt', 'wt');
% for i = 1:length(AIS_out)
%       fprintf(fp, '%d\n', AIS_out(i));
% end
% fclose(fp);
% 
% fp = fopen('D:\AIS_demo\modelsim_sim\de_hdlc\sim\ais_denrzi.txt', 'wt');
% for i = 1:length(AIS_out_denrzi)
%       fprintf(fp, '%d\n', AIS_out_denrzi(i));
% end
% fclose(fp);
