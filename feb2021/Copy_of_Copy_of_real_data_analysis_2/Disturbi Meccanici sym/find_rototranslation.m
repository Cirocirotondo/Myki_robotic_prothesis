function [rot_trasl] = find_rototranslation(x6Mod, trajectories_detected,direction_mean, nMag,errMax, rot_trasl_precedente, boardsPoseMOKUP,pos_along_trajectories,x6Prec)
    %la funzione calcola la rototraslazione dei sensori sfruttando
    %l'algoritmo di minimizzazione "Levemberg-Marquardt" applicato alla
    %funzione "cost_function" (tale funzione sfrutta le distanze tra i
    %magneti e la loro traiettoria)
    
    %rot_trasl = zeros(1,6);   %rototraslazione contiene 6 valori: x(traslazione), y(trasl), z(trasl), x(torazione) , y(rot), z(rot)
    
%     %utilizzo come traiettoria solo il tratto di traiettoria confinante  
%     %alla posizione precedene (ossia, la sezione della traiettoria compresa
%     %tra t-0.2 e t+0.2)
%     trajectories = zeros(size(trajectories_detected));
%     t1 = pos_along_trajectories - 0.2;
%     t2 = pos_along_trajectories + 0.2;
%     t1(t1<0) = 0;
%     t2(t2>1) = 1;
%     for k = 1:nMag
%         trajectories(k,1:2:5) = trajectories_detected(k,1:2:5)*t1(k) + trajectories_detected(k,1:2:5)*(1-t1(k));
%         trajectories(k,2:2:6) = trajectories_detected(k,2:2:6)*t2(k) + trajectories_detected(k,2:2:6)*(1-t2(k));
%     end
    
    %options = optimset('Algorithm','Levenberg-Marquardt','Display','iter-detailed', 'UseParallel', false,'TolFun', 1e-12, 'TolX', 1e-12,'MaxFunEvals', 2000);    %per ora, ho tolto " 'MaxFunEvals', 2000 "  %a fine debug, impostare "Display = off"
    fun = @(rototranslation) cost_function_vect(rototranslation, x6Mod, trajectories_detected,direction_mean, nMag, errMax,boardsPoseMOKUP,x6Prec);
    %rot_trasl = lsqnonlin(fun,rot_trasl_precedente,[],[],options);    %la posizione iniziale è la rototraslazione nulla -> zeros(1,6)
    
    options2 = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed', 'UseParallel', false,'TolFun', 1e-12, 'TolX', 1e-12,'MaxFunEvals', 2000);
    rot_trasl = fmincon(@(rototranslation)cost_function(rototranslation, x6Mod, trajectories_detected, nMag, errMax,boardsPoseMOKUP),rot_trasl_precedente,[],[],[],[],[],[],@(rot_trasl)constrain(errMax,x6Mod,trajectories_detected,rot_trasl,nMag,boardsPoseMOKUP),options2);
end