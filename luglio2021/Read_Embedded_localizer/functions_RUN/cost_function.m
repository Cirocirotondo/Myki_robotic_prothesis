function[cost] = cost_function(rot_transl, sys)

    %calcolo le distanze con la posizione stimata dei sensori
    MagRotoTrasl = rotoTrasla(rot_transl,sys);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(MagRotoTrasl,sys);
        
    %Funzione costo: lineare e quadratica, ma senza punti di discontinuità
    cost = 0;
    for i = 1:sys.nMag
        cost = cost + distances(i);
        if distances(i) > sys.errMax
           cost = cost + (distances(i)-sys.errMax)^2; 
        end
    end
    
end