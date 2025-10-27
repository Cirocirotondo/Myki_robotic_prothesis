function[max, min] = find_length(X, r0, V)
% L'obiettivo di questa funzione è trovare il tratto della linea da far
% diventare traiettoria del magnete.
% Questa funzione trova le distanze tra r0 ed ogni punto. Tale distanza
% avrà segno positivo o negtivo in base al fatto che il punto si trovi
% prima o dopo r0 (il verso è dato dal verso di V)
% PERCHE'? Perché così la traiettoria sarà la linea compresa tra i
% punti A = [r0 + V*d_max] e B = [r0 + V*d_min]
    
    hold on
    plot3(X(:,1), X(:,2), X(:,3),'o');
    plot3(r0(1),r0(2),r0(3), '+');
    quiver3(r0(1),r0(2),r0(3), V(1)/1000, V(2)/1000, V(3)/1000, 'k')
    axis equal
    
    
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
        %davanti a r0 e almeno uno dietro di lui)
        if d > max
            max = d;
        elseif d < min
            min = d;
        end
        
    end

end