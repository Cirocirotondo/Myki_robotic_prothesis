function [y] = localize_magnets(x0, Bact, nMag, m, sPos, sens2ignore)
%localize_magnets Utilizzando il LMA minimizza il residuo tra campo stimato
%e campo attuale sui sensori modificando x.

% x0 = starting point dell'algoritmo di minimizzazione
% Bact = campo magnetico -> matrice nMag*3;
% nMag = numero di magneti
% m = magnetizzazione dei magneti -> m = M*((D/2)^2*pi*H);
% sPos = posizione dei sensori -> matrice nSens*3
% sens2ignore = sensori non funzionanti, da ignorare

    if nargin < 6
      sens2ignore = [];
    end

    options = optimset('Algorithm','Levenberg-Marquardt','Display','off', 'UseParallel', false);
    fun = @(x) dipole_model(x, Bact, nMag, m, sPos, sens2ignore);
    y = lsqnonlin(fun,x0,[],[],options);

end