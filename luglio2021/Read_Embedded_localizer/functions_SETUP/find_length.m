function[max, min] = find_length(X, r0, V)
% L'obiettivo di questa funzione è trovare il tratto della linea da far
% diventare traiettoria del magnete.
% Questa funzione trova le distanze tra r0 ed ogni punto. Tale distanza
% avrà segno positivo o negtivo in base al fatto che il punto si trovi
% prima o dopo r0 (il verso è dato dal verso di V)
% PERCHE'? Perché così la traiettoria sarà la linea compresa tra i
% punti A = [r0 + V*d_max] e B = [r0 + V*d_min]

% NOTA: C'è un'approssimazione! Per essere precisi, avrei dovuto usare come
% d_max e d_min la distanza tra r0 e la proiezione dei punti sulla retta.
% Per semplificare i calcoli, ho deciso di utilizzare invece la distanza
% lineare tra r0 e i punti. In sostanza, ho assunto che i magneti siano
% tutti abbastanza vicini alla traiettoria (approssimazione accettabile, 
% dal momento che siamo in fase di setup, ed in fase di setup tutto 
% dovrebbe andare abbastanza bene), così che la distanza da un
% punto o la sua proiezione fossero considerabili simili.
% Tale approssimazione può andare bene sia perché nella realtà lo
% scostamento dalla traiettoria non dovrebbe essere troppo, sia perché
% comunuqe l'errore si ripercuote solamente nella lunghezza totale della
% traiettoria, che risulterà leggermente più lunga: non è un grande
% problema, anzi! Permette di assorbire parzialmente i successivi errori 
% di misurazione
        


    
    [num_points,~] = size(X);
    
    max = 0;
    min = 0;
    for i = 1:num_points
        %distanza
        d = norm(X(i,:) - r0);
        
        %dò il segno alla distanza
        p1 = r0 + d*V;
        p2 = r0 - d*V;
        d1 = norm(X(i,:) - p1);
        d2 = norm(X(i,:) - p2);
        if d2 < d1
            d = -d;
        end
        
        %mantengo salvata la distanza massima e minima (NOTA: nè "max" nè
        %"min" rimarranno invariati: infatti c'è almeno un punto che sta
        %davanti a r0 e almeno uno dietro di lui, dato che r0 è il punto medio)
        if d > max
            max = d;
        elseif d < min
            min = d;
        end
        
    end

end