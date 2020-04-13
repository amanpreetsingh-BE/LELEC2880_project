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
                                 
XX = X(:);                       % non noisy version stored for BER calc

EbNodBmax = 5;                  % to simulate 0 -> EbNodBMax

for EbNodB = 0:1:EbNodBmax
    
    X_noisy = add_awgn(X,EbNodB,M);  % Adds AWGN @ EbN0dB

    x = ifft(X_noisy);               % IFFT X(k) at each time n  -> x(l,n)
    x_cp = [x(end-L+1:end,:);x];     % add CP to each OFDM symbols
    x_s = x_cp(:);                   % P2S (parralel to serial) subcarrier

    %%%%%%
    % RX %
    %%%%%%
    
    y = x_s;                         % received distorted signal in time
    y = reshape(y,N+L,[]);           % S2P
    y_cpr = y(L+1:N+L,:);            % remove CP's
    Y = fft(y_cpr);                  % FFT X(k) at each time n
    Y = Y(:);                        % P2S

    Yhat = mle(Y,C);                 % MLE detection of received noisy sym
    err_symbols = sum(Yhat~=XX);     % #symbols error
    
    B = symbols_to_bits(XX,M);       % bits stream TX
    Bhat = symbols_to_bits(Yhat,M);  % bits stream RX detected
    err_bits = sum(Bhat~=B);         % #bits error

    
    SER_th(EbNodB+1) = 2*(1-sqrt(1/M))*erfc(sqrt( (3*log2(M)*(10^(EbNodB/10)))/(2*(M-1)) )); % theoritical SER
    SER_sim(EbNodB+1) = err_symbols/length(XX);             % simulated SER
    BER_th(EbNodB+1) = (1/log2(M))*2*(1-sqrt(1/M))*erfc(sqrt( (3*log2(M)*(10^(EbNodB/10)))/(2*(M-1)) )); % theoritical BER
    BER_sim(EbNodB+1) = err_bits/length(B);                 % simulated BER


    %%%%%%%%
    % PLOT %
    %%%%%%%%

    % img RX vs TX
    figure(1);
    I_out = RX_symbols_to_img(Yhat,dim); % RX img 
    subplot(EbNodBmax+1,2,EbNodB*2+1), imshow(I)         % subplot TX img
    title('Sended image')
    subplot(EbNodBmax+1,2,EbNodB*2+2), imshow(I_out)     % subplot RX img
    title(['Received image $@ \frac{E_b}{N_0} = $',num2str(EbNodB),' [dB]'],'Interpreter','latex')

    % plot constellation of RX symbols (300 for illustation purpose)
    figure(2);
    subplot(EbNodBmax+1,1,EbNodB+1)
    scatter(real(Y(1:300)),imag(Y(1:300)),'filled');
    xlim([-2 2]);
    ylim([-2 2]);
    title(['Received 4-QAM symbols over AWGN channel using OFDM $@ \frac{E_b}{N_0} = $',num2str(EbNodB),' [dB]'],'Interpreter','latex')
    xlabel('In phase');
    ylabel('Quadrature');
    
end
    
 % plot BER theorical vs simulated
 
 figure(3);
 EsN0 = log2(M)*(0:EbNodBmax);
 semilogy(EsN0,BER_sim,'ro-', EsN0,BER_th,'k+-');
 xlabel('Es/N0', 'Interpreter', 'latex');
 ylabel('BER');
 title('Performance of the system')
 grid on;
 legend('Simulated','Theoritical')