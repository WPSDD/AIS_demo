clear   %��չ�����
clc     %��������д���
tic     %��ʼ��ʱ
%% ------------------------------AIS�źŴ�������-----------------------------
transmitting_dsp    %���Ͷ����ݴ���
GMSK_modulator      %GMSK����
GMSK_demodulator    %GMSK���
receiving_dsp       %���ն����ݴ���
msg123              %��Ϣ������ʾ

%% ------------------------------���ƹؼ�����-----------------------------
%AIS�źŴ�������źŲ���
figure(1);
subplot('position', [0.1 0.74 0.8 0.16]);
plot(data_in, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 10);  ylabel('ԭʼ����');
title('AIS�źŴ���������ݲ���');  set(get(gca, 'title'), 'FontSize', 13);
subplot('position', [0.1 0.58 0.8 0.16]);
plot(AIS1, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 10);  ylabel('AIS�ź�֡');
subplot('position', [0.1 0.42 0.8 0.16]);
plot(AIS_out_denrzi, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0 1], 'fontsize', 10);  ylabel('������ź�֡');
subplot('position', [0.1 0.26 0.8 0.16]);
plot(data_final, 'LineWidth', 1);  xlim([0 256]);  ylim([-0.5 1.5]);
set(gca, 'Ytick', [0 1], 'fontsize', 10);  xlabel('λ��/bits');  ylabel('�����������');

%GMSK���ƽ�������źŲ���
figure(2);
subplot('position', [0.1 0.74 0.8 0.16]);
plot(1000*t, data_sample, 'LineWidth', 1);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('NRZI��');
title('GMSK���ƽ�������źŲ���');  set(get(gca, 'title'), 'FontSize', 13);
subplot('position', [0.1 0.58 0.8 0.16]);
plot(1000*t, gi(3*N_sample+1:end-3*N_sample), 'LineWidth', 1);  ylim([1.5*min(gi) 1.5*max(gi)]);
set(gca,'xtick', -inf:inf:inf,'Ytick', 0 , 'fontsize', 10);  
set(gca, 'YtickLabel', '0');
ylabel('��˹�˲���');
subplot('position', [0.1 0.42 0.8 0.16]);
plot(1000*t(1:25*25:end), f_de, 'LineWidth', 1);  ylim([1.5*min(f_de) 1.5*max(f_de)]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('�����');
subplot('position', [0.1 0.26 0.8 0.16]);
plot(1000*t, kron(2*AIS_out-1, ones(1, N_sample)), 'LineWidth', 1);  ylim([-1.5 1.5]);
set(gca, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('�о���');
xlabel('ʱ��/ms');

%���±�Ƶ���̲���
figure(3);
fig_x = 0.1;    fig_y = 0.83;            %��һ����ͼ���Ͻǵ�����
fig_len = 0.8;  fig_hight = 0.125;       %��ͼ�ĳ��Ⱥ͸߶�
subplot('position', [fig_x fig_y fig_len fig_hight]);
plot(1000*t, phi, 'LineWidth', 1.5);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0], 'fontsize', 10);
ylabel('\phi(t)', 'FontSize', 10);
title('���±�Ƶ�����źŲ���');  set(get(gca, 'title'), 'FontSize', 13);
subplot('position', [fig_x fig_y-fig_hight fig_len fig_hight]);
plot(1000*t, I_t, 'b', 1000*t, Q_t, 'r');  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('I��Q����', 'FontSize', 10);
legend('I·', 'Q·');
subplot('position', [fig_x fig_y-2*fig_hight fig_len fig_hight]);
plot(1000*t, gmsk);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('GMSK�ź�', 'FontSize', 10);
subplot('position', [fig_x fig_y-3*fig_hight fig_len fig_hight]);
plot(1000*t, gmsk_rcv);  ylim([-1.5 1.5]);
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [-1 0 1], 'fontsize', 10);
ylabel('AD��', 'FontSize', 10);

subplot('position', [fig_x fig_y-4*fig_hight fig_len fig_hight]);
plot(1000*t, In, 1000*t, Qn); 
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0], 'fontsize', 10);
ylabel('�����±�Ƶ��', 'FontSize', 10); 
legend('I·', 'Q·');

subplot('position', [fig_x fig_y-5*fig_hight fig_len fig_hight]);
plot(1000*t(1:r1:end), In_cic, 1000*t(1:r1:end), Qn_cic); 
set(gca, 'xtick', -inf:inf:inf, 'Ytick', [0], 'fontsize', 10);
ylabel('CIC�˲���', 'FontSize', 10);      
legend('I·', 'Q·');
subplot('position', [fig_x fig_y-6*fig_hight fig_len fig_hight]);
plot(1000*t(1:r1*r2*r3:end), I_de0, 1000*t(1:r1*r2*r3:end), Q_de0);
set(gca,'Ytick', [0], 'fontsize', 10);
xlabel('ʱ��/ms', 'FontSize', 10);
ylabel('FIR�˲���', 'FontSize', 10);      
legend('I·', 'Q·');

%��λ����ͼ����֤GMSK��λÿTb�仯pi/2������
figure(4)
plot(1000*t, phi, 'LineWidth', 1.5);  
title('���Ƶ���λ����');  xlabel('ʱ��/ms');  ylabel('��λ');
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

%GMSK�ź���λͼ
figure(5); plot(I_t, Q_t, 'r.');
hold on;  plot(I_de(delay_num+2:end), Q_de(delay_num+2:end), 'b.');
xlim([-1.2 1.2]);   ylim([-1.2 1.2]);
grid on
legend('����ǰ', '�����');
title('GMSK�ź���λͼ');  
xlabel('I֧·');  ylabel('Q֧·');
axis equal

t_run = toc;    
fprintf('����ʱ�䣺%8fs', t_run);

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
