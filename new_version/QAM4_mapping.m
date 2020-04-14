function [C,X] = QAM4_mapping(D,dim,M,N)

    N_ofdm = ((dim(1,1)*dim(1,2)*8)/(N*2)); %number of OFDM symbols 
                                            %(depending on the size of OFDM 
                                            %symbol and number of pixels)

    X = zeros(N,N_ofdm);

    C = [-1+1i -1-1i 1+1i 1-1i]; % Constellation of a M=4-QAM hardcoded 
                                 % for simplicity
    
    % Normalizing the average energy of the transmitted symbols to 1
    E = 0;
    for i = 1:M
        E = E + abs(C(i))^2;
    end
    Eavg = E/M;
    normalizing_factor = 1/sqrt(Eavg);
    C = C*normalizing_factor;
    
    % Mapping 2 bits to a symbol
    byte_index = 1;
    for n = 1:N_ofdm
        k = 1;
        while (k < N)
            for i = 2:2:8
                switch D(byte_index,i-1:i)
                  case '00'
                      X(k,n) = C(1);
                  case '01'
                      X(k,n) = C(2);
                  case '10'
                      X(k,n) = C(3);
                  case '11'
                      X(k,n) = C(4);
                end
                k = k +1;
            end
            byte_index = byte_index+1;
        end
    end
    
end
