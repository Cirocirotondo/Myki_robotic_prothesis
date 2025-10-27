function [num] = find_nearest_trajectory (k,X,sys)
% distanze del magnete k da tutte le varie traiettorie

distances = zeros(1,sys.nMag);
    for i = 1:sys.nMag
        A = [sys.trajectories(i,1) sys.trajectories(i,3) sys.trajectories(i,5)];
        B = [sys.trajectories(i,2) sys.trajectories(i,4) sys.trajectories(i,6)];
        a = A - B;
        b = B - X(k, 1:3);
        d = norm(cross(a,b))/norm(a);       %distanza = area / base
        distances(i) = d;
        
        %verifica P oltre gli estremi
        c = A - X(1, 1:3);
        
        cosAlpha = (a*a' + c*c' - b*b')/(2*norm(a)*norm(c));                    %teorema di Carnot, per ottenere gli angoli interni del triangolo
        cosBeta = (a*a' + b*b' - c*c')/(2*norm(a)*norm(b));
        if cosAlpha < 0 || cosBeta < 0                                          % P va oltre gli estremi se uno dei due angoli è ottuso <-> cos(angolo) < 0
            distances(i) = min(norm(X(k,1:3) - A), norm(X(k,1:3) - B));         
        end
   
    end
   distances
   num =find(distances == min(distances));
   
end