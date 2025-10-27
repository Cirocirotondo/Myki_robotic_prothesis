function [rot_trasl] = find_rototranslation(x6Mod, trajectories, nMag,errMax, rot_trasl_precedente)
    %la funzione calcola la rototraslazione dei sensori sfruttando
    %l'algoritmo di minimizzazione "Levemberg-Marquardt" applicato alla
    %funzione "cost_function" (tale funzione sfrutta le distanze tra i
    %magneti e la loro traiettoria)
    
    %rot_trasl = zeros(1,6);   %rototraslazione contiene 6 valori: x(traslazione), y(trasl), z(trasl), x(torazione) , y(rot), z(rot)
    
    options = optimset('Algorithm','Levenberg-Marquardt','Display','iter-detailed', 'UseParallel', false,'TolFun', 1e-08, 'TolX', 1e-08);    %per ora, ho tolto " 'MaxFunEvals', 2000 "  %a fine debug, impostare "Display = off"
    fun = @(rototranslation) cost_function_vect(rototranslation, x6Mod, trajectories, nMag, errMax);
    rot_trasl = lsqnonlin(fun,rot_trasl_precedente,[],[],options);    %la posizione iniziale è la rototraslazione nulla -> zeros(1,6)
    
end