function[c,ceq] = constrain(errMax,x6Mod,trajectories,rototranslation,nMag,boardsPoseMOKUP)
    
    xRotoTrasl = rotoTrasla(x6Mod, rototranslation, boardsPoseMOKUP);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(xRotoTrasl,trajectories, nMag);
    
    c = distances - errMax; %questo valore deve diventare <= 0
    ceq = [];
end