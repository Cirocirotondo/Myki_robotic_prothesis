function Best = ParallelDipole(x, nMag, M, sPos)
%dipole_model calcola il campo magnetico nelle posizioni dei sensori sfruttando
%il modello di dipolo.
%   x: condizioni iniziali
%   nMag: numero magneti
%   sPos: posizioni dei sensori
%   M: magnitude of magnetic moment

% K = M/1000; %0.0000237;
K = M*1e-7;
nSens = size(sPos,1);
x = vec2mat(x, 6);
xRel = ones(nSens*nMag, 6);   % x ripetuto
for n = 1:nMag
    xRel((n-1)*nSens+1:n*nSens,:) = xRel((n-1)*nSens+1:n*nSens,:).*x(n,:);
    xRel((n-1)*nSens+1:n*nSens,1:3) = xRel((n-1)*nSens+1:n*nSens,1:3) - sPos;
end
R = vecnorm(xRel(:,1:3)')';                % norma di x
dProd = dot(xRel(:,1:3), xRel(:,4:6), 2);  % dot product between x and m
xRel(:,1:3) = xRel(:,1:3).*dProd;          % prodotto scalare * x
xRel(:,1:3) = 3*K*xRel(:,1:3)./(R.^5);     % primo termine
xRel(:,4:6) = K*xRel(:,4:6)./(R.^3);       % secondo termine
Bsm = xRel(:,1:3) - xRel(:,4:6);           % campo stimato dovuto ai singoli magneti
Best = sum(vec2mat(Bsm,nSens*3),1);        % campo stimato totale
Best = reshape(Best,3,[])';