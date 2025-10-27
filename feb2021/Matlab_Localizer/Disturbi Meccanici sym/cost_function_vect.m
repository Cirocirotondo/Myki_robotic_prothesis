function[cost] = cost_function_vect(rototranslation, x6Mod,trajectories,nMag,errMax)
    %calcolo le distanze con la posizione stimata dei sensori
    xRotoTrasl = rotoTrasla(x6Mod, rototranslation);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(xRotoTrasl,trajectories, nMag);
    
    cost = distances;
    for i = 1:nMag
        if distances(i) > errMax
            cost(i) = cost(i) +(distances(i)-errMax)^2; 
        end
    end
end