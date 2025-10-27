function [trajectories] = find_trajectories (S)
    % questa funzione ottinene le traiettorie dei magneti a partire dalla
    % matrice S.
    
    %Input:
    %   S = matrice 11x12 contenente sulle colonne le coordinate x,y,z per
    %   i 4 magneti.
    %   Le 11 righe rappresentano gli 11 step delle traiettorie di ciascun
    %   magnete
    
    % OUTPUT:
    %   trajectories = matrice 4x6, contentente per ogni riga la
    %   traiettoria di un magnete, nella forma [xi, xf, yi,yf, zi, zf]
  
    trajectories = zeros(4,6);
    
    for i = 1:4     %numMag
        trajectories(i,[1,3,5]) = S(1,(i-1)*3+1:(i-1)*3+3);  % riga 1: posizioni iniziali
        trajectories(i,[2,4,6]) = S(11,(i-1)*3+1:(i-1)*3+3); % riga 11: posizioni finali
    end

end