% LELEC2880 : OFDM simulator with 4-QAM implementation and optimization
% Group B

clear all;
close all;
clc

% OFDM and modulation parameters

N = 128;                     % number of subcarriers 
Fc = 2e9;                    % carrier frequency of 2[GHz]
Fo = 15e3;                   % spacing frequency of 15[KHz] (BW_subcarrier)
L = 16;                      % cyclic prefix length
B = Fo*N;                    % total bandwidth 1.92 [MHz]
M = 4;                       % 4-QAM 
T = N/B;                     % symbol period 

%%%%%%
% TX %
%%%%%%

I = imread('pepers.jpg');        % img to be sended over channel
dim = size(I);                   % img dimensions
D = dec2bin(I);                  % Bytes stream (pixels)
[C,X] = QAM4_mapping(D,dim,M,N); % S2P each entry is a 2 bits symbols
                                 % 4 symbols represent one byte, pixel.
                                 % Average power of symbol is normalized 1
                                 
X_noisy = add_awgn(X,10,M);      % Adds AWGN EbN0dB = 10 
                             
x = ifft(X_noisy);               % IFFT X(k) at each time n  -> x(l,n)
x_cp = [x(end-L+1:end,:);x];     % add CP to each OFDM symbols
x_s = x_cp(:);                   % P2S (parralel to serial) subcarrier

%%%%%%%%%%%%%%%%%%%%%%%%
% ANALOG PART fc = 2e9 %
%%%%%%%%%%%%%%%%%%%%%%%%

% NOT NECESSARY FOR SIMULATION PURPOSE (only digital op) in contrast USRP

%%%%%%%%%%%%%%%%
% AWGN Channel %
%%%%%%%%%%%%%%%%

% already added noises in symbols at TX
 
%%%%%%
% RX %
%%%%%%
y = x_s;                         % received distorted signal in time
y = reshape(y,N+L,[]);           % S2P
y_cpr = y(L+1:N+L,:);            % remove CP's
Y = fft(y_cpr);                  % FFT X(k) at each time n
Y = Y(:);                        % P2S

Yhat = mle(Y,C);                 % MLE detection of received noisy symbols

I_out = RX_symbols_to_img(Yhat,dim); % RX img 
 
% %%%%%%%%
% % PLOT %
% %%%%%%%%
% 
figure;

subplot(1,2,1), imshow(I)         % subplot TX img
title('Sended image')
subplot(1,2,2), imshow(I_out)     % subplot RX img
title('Received image')

% plot constellation of RX symbols (300 for illustation purpose)
figure;
scatter(real(Y(1:200)),imag(Y(1:200)),'filled');
xlim([-2 2]);
ylim([-2 2]);
title('Received 4-QAM symbols over AWGN channel using OFDM')
xlabel('In phase');
ylabel('Quadrature');
