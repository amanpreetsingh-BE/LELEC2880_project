function Xhat = detect(R,C)

Xhat = zeros(length(R),1);
% detection maximum likelihood euclidean distance 
for s = 1:length(R)
    if(real(R(s,:)) >= 0 && imag(R(s,:)) >= 0)
        Xhat(s,:) = C(1,3);
    elseif(real(R(s,:)) >= 0 && imag(R(s,:)) < 0)
        Xhat(s,:) = C(1,4);
    elseif(real(R(s,:)) < 0 && imag(R(s,:)) >= 0)
        Xhat(s,:) = C(1,1);
    elseif(real(R(s,:)) < 0 && imag(R(s,:)) < 0)
        Xhat(s,:) = C(1,2);
    end
       
end

end

