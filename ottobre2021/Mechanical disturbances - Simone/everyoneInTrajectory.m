function [check] = everyoneInTrajectory(Mag, trajectories, errMax)
% INPUT: 
%   Mag = matrice nMag*6, contenente le posizioni dei magneti da
%   controllare
%   trajectories = matrice numMag*6 contenente per ogni magnete la sua
%   traiettoria nella forma [xi, xf, yi,yf, zi, zf]

% OUTPUT
%    check = 0 -> c'è almeno un magnete fuori dalla sua traiettoria
%    check = 1 -> tutti i magneti sono nelle loro traiettorie -> non
%    occorre runnare l'algoritmo di correzione dei disturbi

    numMag = size(Mag,1);

    distances = calculate_distances(Mag,trajectories);
    
    check = 1;
    for i = 1:numMag
        if distances(i) > errMax
            check = 0;
            break
        end
    end
end