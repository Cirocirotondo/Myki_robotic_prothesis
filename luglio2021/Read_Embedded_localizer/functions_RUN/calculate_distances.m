function [distances] = calculate_distances(X,sys)
    %la funzione ritorna un vettore 1xnMag contenente le distanze dei
    %magneti dalle rispettive traiettorie
    
%INPUT:
%   X = matrice delle posizioni di cui voglio calcolare le distanze
%   sys = struct contenente tutte le varie variabili utili
     
    distances = zeros(1,sys.nMag);
    for i = 1:sys.nMag
        A = [sys.trajectories(i,1) sys.trajectories(i,3) sys.trajectories(i,5)];
        B = [sys.trajectories(i,2) sys.trajectories(i,4) sys.trajectories(i,6)];
        a = A - B;
        b = B - X(i, 1:3);
        d = norm(cross(a,b))/norm(a);       %distanza = area / base
        distances(i) = d;
        
        %verifica P oltre gli estremi
        c = A - X(i, 1:3);
        
        cosAlpha = (a*a' + c*c' - b*b')/(2*norm(a)*norm(c));                    %teorema di Carnot, per ottenere gli angoli interni del triangolo
        cosBeta = (a*a' + b*b' - c*c')/(2*norm(a)*norm(b));
        if cosAlpha < 0 || cosBeta < 0                                          % P va oltre gli estremi se uno dei due angoli è ottuso <-> cos(angolo) < 0
            distances(i) = min(norm(X(i,1:3) - A), norm(X(i,1:3) - B));         
        end
   
   end
end