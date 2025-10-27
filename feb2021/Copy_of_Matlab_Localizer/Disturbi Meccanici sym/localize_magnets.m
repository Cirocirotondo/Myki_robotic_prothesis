function [y] = localize_magnets(x0, Bact, nMag, M, sPos, sens2ignore)
%localize_magnets Utilizzando il LMA minimizza il residuo tra campo stimato
%e campo attuale sui sensori modificando x.

if nargin < 6
  sens2ignore = [];
end

options = optimset('Algorithm','Levenberg-Marquardt','Display','off', 'UseParallel', false);
fun = @(x) dipole_model(x, Bact, nMag, M, sPos, sens2ignore);
y = lsqnonlin(fun,x0,[],[],options);

end
