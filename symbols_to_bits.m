function out = symbols_to_bits(Y,M)

number_bits = length(Y)*sqrt(M);
out = zeros(number_bits,1);

index = 1;
for i = 1:length(Y)
    if (real(Y(i,:)) <=0 && imag(Y(i,:)) >=0)
        out(index,1) = 0;
        out(index+1,1) = 0;

    elseif(real(Y(i,:)) <=0 && imag(Y(i,:)) <=0)
        out(index,1) = 0;
        out(index+1,1) = 1;

    elseif(real(Y(i,:)) >=0 && imag(Y(i,:)) >=0)
        out(index,1) = 1;
        out(index+1,1) = 0;

    elseif(real(Y(i,:)) >=0 && imag(Y(i,:)) <=0)
        out(index,1) = 1;
        out(index+1,1) = 1;
    
    end
    index = index+2;

end

end

