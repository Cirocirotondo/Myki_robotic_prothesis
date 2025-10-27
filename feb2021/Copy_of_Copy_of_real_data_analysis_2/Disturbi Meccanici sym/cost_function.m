function[cost] = cost_function(rototranslation, x6Mod,trajectories,nMag,errMax,boardsPoseMOKUP)
    %calcolo le distanze con la posizione stimata dei sensori
    xRotoTrasl = rotoTrasla(x6Mod, rototranslation,boardsPoseMOKUP);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(xRotoTrasl,trajectories, nMag);
    
%     cost = sum(distances) + 10000*sum(distances(distances > errMax));   %MODO 1: combinazione di lineari
%     cost = sum(1000000*distances .* distances .* distances);    %MODO 2: solo quadratica
%     cost = sum(distances) + 1000000*sum(distances .* distances .* (distances > errMax));    %MODO 3: lineare e quadratica, con punto di discontinuità di salto in errMax
    
    %MODO 4: lineare e quadratica, ma senza punti di discontinuità
    cost = 0;
    for i = 1:nMag
        cost = cost + distances(i);
        if distances(i) > errMax
           cost = cost + (distances(i)-errMax)^2; 
        end
    end
    
end