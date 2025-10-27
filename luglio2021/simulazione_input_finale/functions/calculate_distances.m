function [distances] = calculate_distances(x, trajectories)
%     la funzione ritorna un vettore 1xnMag contenente le distanze dei
%     magneti dalle rispettive traiettorie

    global nMag;
    
    
   distances = zeros(1,nMag);
   for i = 1:numMag
        A = [trajectories(i,1) trajectories(i,3) trajectories(i,5)];
        B = [trajectories(i,2) trajectories(i,4) trajectories(i,6)];
        a = A - B;
        b = B - x(i, 1:3);
        d = norm(cross(a,b))/norm(a);       %distanza = area / base
        distances(i) = d;
       
        %verifica P oltre gli estremi
        c = A - x(i, 1:3);
        
        cosAlpha = (a*a' + c*c' - b*b')/(2*norm(a)*norm(c));        %teorema di Carnot, per ottenere gli angoli interni del triangolo
        cosBeta = (a*a' + b*b' - c*c')/(2*norm(a)*norm(b));
        if cosAlpha < 0 || cosBeta < 0                                          % P va oltre gli estremi se un angolo è ottuso <-> cos(angolo) < 0
            distances(i) = min(norm(x(i,1:3) - A), norm(x(i,1:3) - B));         
        end
   
   end
end