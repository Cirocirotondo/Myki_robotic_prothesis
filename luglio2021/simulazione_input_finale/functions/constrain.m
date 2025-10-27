function[c,ceq] = constrain(Mag,rot_transl)

    global errMax
    global trajectories
    
    
    xRotoTrasl = rotoTrasla(Mag, rot_transl);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(xRotoTrasl,trajectories);
    
    c = distances - errMax;    %questo valore deve diventare <= 0
    ceq = [];
end