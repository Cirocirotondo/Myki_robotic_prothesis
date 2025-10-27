function [x,tVector] = randomly_move_magnets_along_trajectories_consequenziale(trajectories, nMag, t_prec, nPos)
% %randomly_move_magnets places magnets in a point of the trajctory
%   MOVIMENTO CONSEQUENZIALE
    
    x = rand(nMag,6);
    dt = 1/nPos;
    tVector = t_prec + dt;
    for i = 1:nMag
        x(i,1:3) = tVector(i) * trajectories(i,1:2:5) + (1-tVector(i)) * trajectories(i,2:2:6);
        %   rotazioni
        rot = rand(1,3);
        x(i, 4:6) = rot/norm(rot);
    end
    
end
