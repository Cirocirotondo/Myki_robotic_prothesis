function[min_distance] = calcola_L_min_inter_magneti(index, X)
    [nMag,~] = size(X);
    distances = zeros(1,nMag-1);      %distanze degli nMag magneti dall' index-esimo magnete
    for i = 1:nMag
        if i < index
            distances(i) = norm(X(index,1:3)- X(i,1:3));
        elseif i > index
            distances(i-1) = norm(X(index,1:3) - X(i,1:3));
        end
    end
    
    min_distance = min(distances);
        
end