function[min_R] = calcola_R(X,sPos)
    [nMag,~] = size(X);
    L_inter_magneti = zeros(1,nMag);
    L_magnete_sensore = L_inter_magneti;
    R = zeros(1,nMag);
    
    for i = 1:nMag
        L_inter_magneti(i) = calcola_L_min_inter_magneti(i, X);
        L_magnete_sensore(i) = calcola_L_min_magnete_sensore(X(i,1:3), sPos);
        R(i) = L_inter_magneti(i)/L_magnete_sensore(i);
    end
    
    min_R = min(R);
end