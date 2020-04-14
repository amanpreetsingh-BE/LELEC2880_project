function X_noisy = add_awgn(X, EbNodB, M)


EbNo = 10^(EbNodB/10);
% sigma = sqrt(1/(2*log2(M)*EbNo));
Eb = X'*X/(log2(M)*length(X));
variance = Eb/(EbNo); %%% MODIFICATION
sigma = sqrt(variance); %%% MODIFICATION

dim = size(X);
rows = dim(1,1);
cols = dim(1,2);
X_noisy = zeros(rows,cols);

for i = 1:rows
    for l = 1:cols
        I = sigma*randn();
        Q = sigma*randn();
        X_noisy(i,l) = X(i,l) + I+1j*Q; %%% Modification i en j
    end
end

    
end

