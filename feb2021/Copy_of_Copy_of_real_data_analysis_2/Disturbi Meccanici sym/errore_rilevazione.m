function[is_error] = errore_rilevazione(x6_prec, x6,boardsPoseMOKUP, SPOST_MAX)
% L'obiettivo di questa funzione è eliminare gli errori di misurazione che
% rischiano di propagare l'errore anche alle successive rilevazioni. 
% Una misurazione si considera errata se c'è almeno un magnete che si muove
% rispetto alla misurazione precedente di più di SPOST_MAX cm (il mockup lavora a
% 20 Hz...) oppure se almeno un magnete cade fuori dal mockup (tranne che
% per le y!)

    [nMag,~] = size(x6);
    is_error = 0;
    
    % controllo salto eccessivo
    dist = zeros(1,nMag);
    for i = 1:nMag
        dist(i) = norm(x6(i,1:3) - x6_prec(i,1:3));
    end
    dist_max = max(dist);
    
    if dist_max > SPOST_MAX          %se lo spostamento rispetto alla posizione precedente è > di SPOST_MAX m, ritorno errore.
        is_error = 1;
    else
        is_error = 0;
    end
    
    % controllo boundaries
    for i = 1:nMag
        if x6(i,1) < boardsPoseMOKUP(3,1)/1000 || x6(i,1) > boardsPoseMOKUP(4,1)/1000 || x6(i,3) < boardsPoseMOKUP(1,3)/1000 || x6(i,3) > boardsPoseMOKUP(2,3)/1000
            is_error = 1;
        end
    end

end