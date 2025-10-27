function[MagRotoTrasl] = rotoTrasla(rot_transl,sys)

% INPUT
%   sys: struct -> vogliamo modificare X = matrice nMag*6 -> posizioni dei magneti da rototraslare
%   rot_transl = vettore 1*6 contenente la rototraslazione

    MagRotoTrasl = sys.X;
    
    %rotazione
    for i = 1:sys.nMag
        MagRotoTrasl(i,:) = rotateY(rot_transl(5), MagRotoTrasl(i,:), sys.x0);      
        MagRotoTrasl(i,:) = rotateZ(rot_transl(6), MagRotoTrasl(i,:), sys.x0);
        MagRotoTrasl(i,:) = rotateX(rot_transl(4), MagRotoTrasl(i,:), sys.x0);
    end
    
%     traslazione
    MagRotoTrasl(:,1:3) = MagRotoTrasl(:,1:3) + rot_transl(1:3);

end