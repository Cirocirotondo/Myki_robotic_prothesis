function [check] = everyoneInTrajectory(Mag)
% INPUT: 
%   Mag = matrice nMag*6, contenente le posizioni dei magneti da
%   controllare

% OUTPUT
%    check = 0 -> c'è almeno un magnete fuori dalla sua traiettoria
%    check = 1 -> tutti i magneti sono nelle loro traiettorie -> non
%    occorre runnare l'algoritmo di correzione dei disturbi

    global nMag
    global trajectories
    global errMax

    distances = calculate_distances(Mag,trajectories);
    
    check = 1;
    for i = 1:nMag
        if distances(i) > errMax
            check = 0;
            break
        end
    end
end