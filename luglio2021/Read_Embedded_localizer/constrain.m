function[c,ceq] = constrain(rot_transl,sys)
% constrain per l'algoritmo di minimizzazione: ogni magnete si deve trovare
% all'interno della propria traiettoria.
    
    xRotoTrasl = rotoTrasla(rot_transl,sys);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(xRotoTrasl,sys);
    
    c = distances - sys.errMax;    %questo valore deve diventare <= 0
    ceq = [];
end