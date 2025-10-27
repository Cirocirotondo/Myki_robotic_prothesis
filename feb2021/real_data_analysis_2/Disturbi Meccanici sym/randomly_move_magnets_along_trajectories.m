function [x,tVector] = randomly_move_magnets_along_trajectories(trajectories, nMag, t_prec, nPos)
% %randomly_move_magnets places magnets in a point of the trajctory
%   x = rand(nMag,6);
%   tVector = zeros(nMag, 1);
%   for i=1:nMag
%     dt = rand(1)*0.2 - 0.1;     % c'è un dt per ogni magnete. Il modulo di dt è minore di 0.1
%     if t_prec(i) + dt <= 1 && t_prec(i) + dt >= 0
%          tVector(i) = t_prec(i) + dt;
%     else
%         tVector(i) = t_prec(i);
%     end
%   
% %     x(i,1) = t * trajectories(i,1) + (1-t) * trajectories(i,2); %x
% %     x(i,2) = t * trajectories(i,3) + (1-t) * trajectories(i,4); %y
% %     x(i,3) = t * trajectories(i,5) + (1-t) * trajectories(i,6); %z
%      x(i,1:3) = tVector(i) * trajectories(i,1:2:5) + (1-tVector(i)) * trajectories(i,2:2:6);   %questo comando fa da solo le tre righe precedenti
% 
% %   rotazioni
%     rot = rand(1,3);
%     x(i, 4:6) = rot/norm(rot);
%   end

    
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
