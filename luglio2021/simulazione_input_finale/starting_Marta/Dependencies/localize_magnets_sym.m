function [y] = localize_magnets_sym(x0, Bact, nMag, M, sPos, sens2ignore)
%localize_magnets Utilizzando il LMA minimizza il residuo tra campo stimato
%e campo attuale sui sensori modificando x.

options = optimset('Algorithm','Levenberg-Marquardt','Display','off');
fun = @(x) dipole_model_sym(x, Bact, nMag, M, sPos, sens2ignore);
y = lsqnonlin(fun,x0,[],[],options);
end
