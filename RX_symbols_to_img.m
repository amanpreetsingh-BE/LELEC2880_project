function I_out = RX_symbols_to_img(Y, dim)

I_out = zeros(dim(1,1),dim(1,2),'uint8');

index = 1;
for i = 1:dim(1,1)
    for j = 1:dim(1,2)
        byte_c = Y(index:index+3,:);
        temp = '';
        for w = 1:4
            if (real(byte_c(w,:)) <=0 && imag(byte_c(w,:)) >=0)
                temp = strcat(temp,'00');
                
            elseif(real(byte_c(w,:)) <=0 && imag(byte_c(w,:)) <=0)
                temp = strcat(temp,'01');
                
            elseif(real(byte_c(w,:)) >=0 && imag(byte_c(w,:)) >=0)
                temp = strcat(temp,'10');
                
            elseif(real(byte_c(w,:)) >=0 && imag(byte_c(w,:)) <=0)
                temp = strcat(temp,'11');
            end
        end
        index = index+4;
        I_out(j,i) = bin2dec(temp);
    end
end


end

