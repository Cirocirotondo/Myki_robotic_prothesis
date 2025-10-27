function[cost] = cost_function(rot_transl, Mag)

    global trajectories
    global errMax
    global nMag

    
    %calcolo le distanze con la posizione stimata dei sensori
    MagRotoTrasl = rotoTrasla(Mag, rot_transl);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(MagRotoTrasl,trajectories);
        
    %Funzione costo: lineare e quadratica, ma senza punti di discontinuità
    cost = 0;
    for i = 1:nMag
        cost = cost + distances(i);
        if distances(i) > errMax
           cost = cost + (distances(i)-errMax)^2; 
        end
    end
    
end