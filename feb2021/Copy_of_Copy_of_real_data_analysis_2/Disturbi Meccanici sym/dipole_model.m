function [output] = dipole_model(x, Bact, nMag, M, sPos, sens2ignore)
%dipole_model calcola il campo magnetico nelle posizioni dei sensori sfruttando
%il modello di dipolo.
%   x: condizioni iniziali
%   nMag: numero magneti
%   sPos: posizioni dei sensori
%   M: magnitude of magnetic moment

%% Variabili
% M = 0.0237;   %magnitude of magnetic moment
% mu = 4* PI /(10^3);   %medium permeability [Gauss]
% K = M*mu/(4*PI);
K = M/1000; %0.0000237;
nSens = size(sPos,1);
x = vec2mat(x, 6);
xRel = ones(nSens*nMag, 6);   % x ripetuto
for n = 1:nMag
  xRel((n-1)*nSens+1:n*nSens,:) = xRel((n-1)*nSens+1:n*nSens,:).*x(n,:);
  xRel((n-1)*nSens+1:n*nSens,1:3) = xRel((n-1)*nSens+1:n*nSens,1:3) - sPos;
end
R = vecnorm(xRel(:,1:3)')';    % norma di x
dProd = dot(xRel(:,1:3), xRel(:,4:6), 2);   % dot product between x and m
xRel(:,1:3) = xRel(:,1:3).*dProd;   % prodotto scalare * x
xRel(:,1:3) = 3*K*xRel(:,1:3)./(R.^5);    % primo termine
xRel(:,4:6) = K*xRel(:,4:6)./(R.^3);    % secondo termine
Bsm = xRel(:,1:3) - xRel(:,4:6);   % campo stimato dovuto ai singoli magneti
Best = sum(vec2mat(Bsm,nSens*3),1);    % campo stimato totale
Bact = vec2mat(Bact,nSens*3);
res = Bact - Best;

if nargin > 5 && size(sens2ignore, 1) > 0
    ind = 96*(sens2ignore(:,1)-1)+3*(sens2ignore(:,2)-1)+1;
    ind = [ind, ind+1, ind+2]';
    ind = ind(:)';
    ind = ind(size(ind, 2):-1:1);
    for i = ind
      if i <= size(res,2)
        res(i) = [];
    %     res(i) = 0;    %HACK XXX
      end
    end
end
% orinorm = ones(1,nMag) - vecnorm(x(:,4:6)');
output = [res];% (orinorm)'];

if true % controllo su lunghezza vettore: serve ad evitare che la norma esploda. Il coefficiente "valRel" determina quanto ottimizzare questo è importante rispetto al resto
  valRel = 1;   % ATTENZIONE TOMMASO, SE PUOI METTI QUESTO VALORE COME PARAMETRO ESTERNO
  for i = 1:nMag
    temp(i) = valRel*(norm(x(i,4:6))-1);
  end
  output = [output, temp];
end

end
