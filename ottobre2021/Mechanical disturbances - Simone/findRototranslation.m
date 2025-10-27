function rototranslation = findRototranslation(Mag, rototransl_prec,trajectories,errMax)
%     La funzione calcola la rototraslazione dei sensori sfruttando
%     l'algoritmo di minimizzazione "Levemberg-Marquardt" applicato alla
%     funzione "cost_function" (funzione costo =  distanze tra i
%     magneti e la loro traiettoria)

% INPUT
%   Mag = matrice nMag*6 contenente le posizioni dei magneti di cui bisogna
%   trovare la rototraslazione
%   rototransl_prec = matrice nMag*6 contentente la rototraslazione
%   precedente (o zeros(1,6) se è il primo giro)

%     rot_transl = zeros(1,6);   %rototraslazione contiene 6 valori: x(traslazione), y(trasl), z(trasl), x(torazione) , y(rot), z(rot)


    options2 = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed', 'UseParallel', false,'TolFun', 1e-12, 'TolX', 1e-12,'MaxFunEvals', 2000);
    
    rototranslation = fmincon(@(rot_transl)cost_function(rot_transl, Mag,trajectories, errMax),rototransl_prec,[],[],[],[],[],[],@(rot_transl)constrain(Mag,rot_transl,errMax,trajectories),options2);

end