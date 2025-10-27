function[xRotoTrasl] = rotoTrasla(x, rototranslation)
    xRotoTrasl = zeros(size(x));
    [num,dim] = size(x);
    for i = 1:num
        xRotoTrasl(i,1:3) = (rotz(rototranslation(6)) * (roty(rototranslation(5)) * (rotx(rototranslation(4)) * x(i,1:3)')))'; % per ora il corpo non ruota, ma trasla soltanto
%         xRotoTrasl(i,1:3) = (rotx(rototranslation(4)) * x(i,1:3)')';
        %     xRotoTrasl(1:3) = xRotoTrasl(1:3) + rototranslation(1:3);
        
        %bisogna fare ruotare anche i versori dei magneti
        %poiché la funzione viene usata anche per la posizione dei sensori,
        %bisogna specificare che la rotazione dei versori va fatta sse x ha
        %6 colonne (ossia, se si tratta di un magnete)
        if dim == 6
            xRotoTrasl(i, 4:6) = (rotz(rototranslation(6)) * (roty(rototranslation(5)) * (rotx(rototranslation(4)) * x(i,4:6)')))';
        end
    end
    
%     traslazione
    xRotoTrasl(:,1:3) = xRotoTrasl(:,1:3) + rototranslation(1:3);

end