function moveMagnet (k)
    global nMag
    global nPos
    global MagPos
    global trajectories
    mu                  =       0.000;
    sigma               =       0.0001;
   
%------------------------------------------------------------------------

    if nPos == 0
       MagPos{0} = trajectories(1:11, [1,3,5]);
    else
        % MOVIMENTO CONSEQUENZIALE
        t = k/nPos;
        for i = 1:nMag
            MagPos{k}(i,1:3) = t * trajectories(i,[1,3,5]) + (1-t) * trajectories(i,[2,4,6]);
            %   rotazioni
            %   NOTA: per il momento, le orientazioni sono ristrette a 1/8
            %   dell'angolo solido completo (infatti 0<rand<1) -> per ora,
            %   va bene (i magneti si possono muovere, ma non tantissimo)
            %   più avanti: provare a rendere l'angolo solido completo
            %   (puoi usare "rand(1,3)-1/2" )
            rot = rand(1,3);
            MagPos{k}(i,4:6) = rot/norm(rot);
            
            % add noise
            MagPos{k}(1:11, 1:3) = MagPos{k}(1:nMag, 1:3) + randn(nMag,3)*sigma + mu;
        end
    end
    
end