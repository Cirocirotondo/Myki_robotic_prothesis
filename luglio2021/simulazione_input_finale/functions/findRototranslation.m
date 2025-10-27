function findRototranslation(k, Mag)
%     La funzione calcola la rototraslazione dei sensori sfruttando
%     l'algoritmo di minimizzazione "Levemberg-Marquardt" applicato alla
%     funzione "cost_function" (funzione costo =  distanze tra i
%     magneti e la loro traiettoria)

% INPUT
%   k = numero ciclo
%   Mag = matrice nMag*6 contenente le posizioni dei magneti di cui bisogna
%   trovare la rototraslazione

    
    global rototranslation
%     rot_transl = zeros(1,6);   %rototraslazione contiene 6 valori: x(traslazione), y(trasl), z(trasl), x(torazione) , y(rot), z(rot)

  
    options2 = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed', 'UseParallel', false,'TolFun', 1e-12, 'TolX', 1e-12,'MaxFunEvals', 2000);
    if k > 1
        rototranslation{k} = fmincon(@(rot_transl)cost_function(rot_transl, Mag),rototranslation{k-1},[],[],[],[],[],[],@(rot_transl)constrain(Mag,rot_transl),options2);
    else
        rototranslation{1} = fmincon(@(rot_transl)cost_function(rot_transl, Mag),zeros(1,6),[],[],[],[],[],[],@(rot_transl)constrain(Mag,rot_transl),options2);
    end
    
    
    
end