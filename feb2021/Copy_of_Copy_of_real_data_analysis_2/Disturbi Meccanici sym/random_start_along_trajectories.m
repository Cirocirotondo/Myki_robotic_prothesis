function [x,tVector] = random_start_along_trajectories(trajectories, nMag)
% %random_start_along_trajectories places magnets in a point of the trajctory
%   x = rand(nMag,6);
%   tVector = rand(nMag, 1);
%   for i=1:nMag
%     t = rand(1);
%     tVector(i) = t;
% %     x(i,1) = t * trajectories(i,1) + (1-t) * trajectories(i,2); %x
% %     x(i,2) = t * trajectories(i,3) + (1-t) * trajectories(i,4); %y
% %     x(i,3) = t * trajectories(i,5) + (1-t) * trajectories(i,6); %z
%     x(i,1:3) = t * trajectories(i,1:2:5) + (1-t) * trajectories(i,2:2:6);   %questo comando fa da solo le tre righe precedenti
%     %rotazioni
%     rot = rand(1,3);
%     x(i, 4:6) = rot/norm(rot);
%   end

% MOVIMENTI CONSEQUENZIALI
    
    x = rand(nMag,6);
    tVector = zeros(nMag,1);
    t = 0;
    for i = 1:nMag
        x(i,1:3) = t * trajectories(i,1:2:5) + (1-t) * trajectories(i,2:2:6);
        %rotazioni
         rot = rand(1,3);
         x(i, 4:6) = rot/norm(rot);
    end
    
end