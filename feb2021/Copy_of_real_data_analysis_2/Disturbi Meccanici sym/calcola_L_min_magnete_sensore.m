function[min_distanza] = calcola_L_min_magnete_sensore(X, sPos)

    
    distances = X' - sPos';
    dist = bsxfun(@dot, distances, distances);
    dist = sqrt(dist);
    min_distanza = min(dist);
    
end