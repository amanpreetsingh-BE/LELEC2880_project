% LELEC2880 : OFDM simulator with 4-QAM implementation and optimization
% Group B

clear all;
close all;
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM and modulation parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = 4;                       % 4-QAM
Fc = 2e9;                    % carrier frequency of 2[GHz]

% L is determined by symbol period Ts and delay spread of the channel 
% L = delay_spread/Ts 
% Here L = 16 GIVEN in the statement:

L = 16;                      % cyclic prefix length

% The channel h must be cst over 1 OFDM symbol and thus we need that 
% OFDM_duration=(N+L)Ts < coherence_time/10 and take power of 2.
% Here N = 128 GIVEN in the statement : 

N = 128;                     % number of subcarriers 
deltaF = 15e3;               % spacing frequency of 15[KHz] (BW_subcarrier)
B = deltaF*N;                % -> total bandwidth 1.92 [MHz]
Ts = 1/B;                    % -> symbol period in Single Carrier SC
Tfft = 1/deltaF;             % -> symbol period in Multi Carrier MC
OFDM_duration = (N+L)*Ts;    % OFDM_duration need to be < coherence_time/10 
R_MQAM = log2(M)/Ts;         % SC data rate [bps] for a MQAM
coeff = L/(N+L);             % data rate loss due to adding CP in OFDM 
R_OFDM = (1-coeff)*R_MQAM;   % MCM data rate [bps] in OFDM


%%%%%%
% TX %
%%%%%%

I = imread('pepers.jpg');        % img to be sended over channel
dim = size(I);                   % img dimensions
D = dec2bin(I);                  % Bytes stream (pixels)
[C,X] = QAM4_mapping(D,dim,M,N); % S2P each entry is a 2 bits symbols
                                 % 4 symbols represent one byte, pixel.
                                 % Average power of symbol is normalized 1
EbN0dB = -16:2:6;                  % bit to noise ratio to be tested
EsN0dB = EbN0dB+10*log10(log2(M))+10*log10(N/(L+N)); % symbol to noise 
BER_sim = zeros(1,length(EsN0dB));                   % sim BER init
BER_th = zeros(1,length(EsN0dB));                    % th BER init

for i = 1:length(EsN0dB)
    err_symbols = 0;
    err_bits = 0;
    total_symbols = [];
    for j = 1:length(X)              % send every OFDM symbol @ EsNodB(i)
        
        x = sqrt(N)*ifft(X(:,j));    % N pts normalized IDFT(ofdm_symbol i)
        x_cp = [x(end-L+1:end,:);x]; % add CP length L to OFDM symbol i
        x_s = x_cp';                 % P2S (parralel to serial)
        
        %%%%%%%%%%%
        % Channel %
        %%%%%%%%%%%
        
        noise=(1/sqrt(2))*(randn(1,length(x_s))+1i*randn(1,length(x_s))); 
        x_sawgn = sqrt((N+L)/N)*x_s + 10^(-EsN0dB(i)/20)*noise; 

        %%%%%%
        % RX %
        %%%%%%
        
        r_rcp = x_sawgn(L+1:(N+L));  % removing CP from received signal
        r_p = r_rcp';                % S2P 
        R = (1/sqrt(N))*fft(r_p);    % N pts normalized FFT of RX signal
        
        Xhat = detect(R,C);          % detect the symbols maximum likehood
        err_symbols = err_symbols+sum(Xhat~=X(:,i)); % #symbols error

        B = symbols_to_bits(X(:,j),M);      % bits stream TX
        Bhat = symbols_to_bits(Xhat,M);     % bits stream RX detected
        err_bits = err_bits + sum(Bhat~=B); % #bits error
        total_symbols = [total_symbols ; Xhat]; % to recover image and plot constellation
                      
    end
    BER_sim(1,i) = (err_bits)/(8*length(D)); 
    BER_th(1,i) = (2/log2(M))*erfc(sqrt((3*(10.^(EbN0dB(i)/10))*log2(M))/(2*(M-1))));
    
    gamma_b = (10.^(EbN0dB(i)/10)); %EbNo non db scale
    num =sqrt(3*log2(M)*gamma_b/(M-1));      %num of erfc
    BER_th(1,i) = (4/log2(M))*(1-1/sqrt(M))*(1/2)*erfc(num/sqrt(2));
    
    % plot images : comment if needed to faster run
    
    figure(1);
    I_out = RX_symbols_to_img(total_symbols,size(I));      % RX img 
    subplot(length(EbN0dB),2,(i-1)*2+1), imshow(I)         % subplot TX img
    title('Sended image')
    subplot(length(EbN0dB),2,i*2), imshow(I_out)     % subplot RX img
    title(['Received image $@ \frac{E_b}{N_0} = $',num2str(EbN0dB(i)),' [dB]'],'Interpreter','latex')
    
    % plot constellation of RX symbols (300 for illustation purpose)
    figure(2);
    subplot(length(EbN0dB),1,i)
    scatter(real(R),imag(R),'filled');
    xlim([-2 2]);
    ylim([-2 2]);
    title(['Received 4-QAM symbols over AWGN channel using OFDM $@ \frac{E_b}{N_0} = $',num2str(EbN0dB(i)),' [dB]'],'Interpreter','latex')
    xlabel('In phase');
    ylabel('Quadrature');

end
    
 % plot BER theorical vs simulated
 
 figure(3);
 semilogy(EsN0dB,BER_sim,'r-o', EsN0dB,BER_th,'k*');
 xlim([EsN0dB(1) EsN0dB(length(EsN0dB))]);
 xlabel('Es/N0 [dB]', 'Interpreter', 'latex');
 ylabel('BER');
 title('Performance of the system')
 grid on;
 legend('Simulated','Theoritical')