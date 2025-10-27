function[MagRotoTrasl] = rotoTrasla(Mag, rot_transl)

% INPUT
%   Mag = matrice nMag*6 -> posizioni dei magneti da rototraslare
%   rot_transl = vettore 1*6 contenente la rototraslazione

    nMag = size(Mag,1);
    
    MagRotoTrasl = Mag;
    
    %rotazione
    for i = 1:nMag
        MagRotoTrasl(i,1:3) = (roty(rot_transl(5)) * MagRotoTrasl(i,1:3)')';
        MagRotoTrasl(i,1:3) = (rotz(rot_transl(6)) * MagRotoTrasl(i,1:3)')';
        MagRotoTrasl(i,1:3) = (rotx(rot_transl(4)) * MagRotoTrasl(i,1:3)')';
        % ruoto anche i versori
        MagRotoTrasl(i,4:6) = (roty(rot_transl(5)) * MagRotoTrasl(i,4:6)')';
        MagRotoTrasl(i,4:6) = (rotz(rot_transl(6)) * MagRotoTrasl(i,4:6)')';
        MagRotoTrasl(i,4:6) = (rotx(rot_transl(4)) * MagRotoTrasl(i,4:6)')';
    end
    
%     traslazione
    MagRotoTrasl(:,1:3) = MagRotoTrasl(:,1:3) + rot_transl(1:3);

end