function[cost] = cost_function_vect(rototranslation, x6Mod,trajectories,direction_mean,nMag,errMax,boardsPoseMOKUP,x6Prec)
    %calcolo le distanze con la posizione stimata dei sensori
%      rototranslation(1:4) = [0 0 0 0];     %Togliere alla fine!!
    
    xRotoTrasl = rotoTrasla(x6Mod, rototranslation, boardsPoseMOKUP);    %questa è la posizione dei magneti ottenuta contando la rototraslazione dei sensori
    distances = calculate_distances(xRotoTrasl,trajectories, nMag);
    
%     cost = distances.^2;
    cost = distances;
    for i = 1:nMag
        if distances(i) > errMax
            cost(i) = cost(i) +(distances(i)-errMax)^2;
            %cost(i) = cost(i) + norm(xRotoTrasl(i,1:3) - x6Prec(i,1:3))^2;
        end
    end
    
    %costo dovuto all'orientazione
    cos_ang = zeros(1,nMag);  %coseno dell'angolo compreso tra il vettore attuale ed il vettore direction_mean (che è quello ottenuto in fase di setup)
    for k = 1:nMag
        cos_ang(k) = dot(direction_mean(k,:), xRotoTrasl(k, 4:6)) / (norm(direction_mean(k,:))*norm(xRotoTrasl(k, 4:6)));
    end
    ang = acos(cos_ang)*180/pi;
    cost = cost + sum(ang)*10^(-3)/3;
    
end