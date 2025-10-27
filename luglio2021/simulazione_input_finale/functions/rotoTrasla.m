function[MagRotoTrasl] = rotoTrasla(Mag, rot_transl)

% INPUT
%   Mag = matrice nMag*6 -> posizioni dei magneti da rototraslare
%   rot_transl = vettore 1*6 contenente la rototraslazione

    global nMag
    global x0
    MagRotoTrasl = Mag;
    
    
    %rotazione
    for i = 1:nMag
        MagRotoTrasl(i,:) = rotateY(rot_transl(5), MagRotoTrasl(i,:), x0);      
        MagRotoTrasl(i,:) = rotateZ(rot_transl(6), MagRotoTrasl(i,:), x0);
        MagRotoTrasl(i,:) = rotateX(rot_transl(4), MagRotoTrasl(i,:), x0);
    end
    
%     traslazione
    MagRotoTrasl(:,1:3) = MagRotoTrasl(:,1:3) + rot_transl(1:3);

end