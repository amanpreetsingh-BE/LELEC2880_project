function X_noisy = add_awgn(X, EbNodB, M)


EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*log2(M)*EbNo));

dim = size(X);
rows = dim(1,1);
cols = dim(1,2);
X_noisy = zeros(rows,cols);

for i = 1:rows
    for l = 1:cols
        I = sigma*randn();
        Q = sigma*randn();
        X_noisy(i,l) = X(i,l) + I+1i*Q;
    end
end

    
end

