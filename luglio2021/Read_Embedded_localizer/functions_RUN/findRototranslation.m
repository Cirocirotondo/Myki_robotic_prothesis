function[rototranslation] = findRototranslation(sys)
%     La funzione calcola la rototraslazione dei sensori sfruttando
%     l'algoritmo di minimizzazione "Levemberg-Marquardt" applicato alla
%     funzione "cost_function" (funzione costo =  distanze tra i
%     magneti e la loro traiettoria)

% INPUT
%   sys = struct di sistema. Viene utilizzato: 
%   Mag = matrice nMag*6 contenente le posizioni dei magneti di cui bisogna
%   trovare la rototraslazione

% OUTPUT
%   rototranslation = matrice nMag*6, ogni riga è della forma: "[x(trasl), y(trasl), z(trasl), x(rot), y(rot), z(rot)]"

  
    options = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed', 'UseParallel', false,'TolFun', 1e-12, 'TolX', 1e-12,'MaxFunEvals', 2000);
   
    rototranslation = fmincon(@(rot_transl)cost_function(rot_transl, sys),sys.prev_rotTransl,[],[],[],[],[],[],@(rot_transl)constrain(rot_transl,sys),options);
    
    
end