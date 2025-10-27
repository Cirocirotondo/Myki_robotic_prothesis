function[r0, V, trajectories] = find_trajectory(X)
%Questa funzione ottiene le traiettorie dei magneti a partire dalle
%posizioni sperimentali acquisite con le misurazioni sperimentali. Viene
%effettuato un algoritmo di linear regression tridimensionale, uno per ogni
%magnete.

%INPUT:
%X = cell(1,nMag): X{k} = matrice num*3 -> contiene tutte le posizioni assunte dal k-esimo magnete

%OUTPUT:
%Ogni traiettoria giace su una retta della forma r0 + t*vett
%r0 = matrice nMag*3 contenente i punti r0 per ogni magnete
%V = matrice nMag*3 contiene le giaciture di ciascuna traiettoria
%trajectories = matrice nMag*6 con ogni riga della forma [xi, xf, yi, yf, zi, zf]

    [~,nMag] = size(X);      

    r0 = zeros(nMag,3);
    V = zeros(nMag,3);
    
%%  r0 e V
    for k = 1:nMag
        % retta espressa come "r_k(t) = r0(k,:) + t * V(k,:)"
        %r0 = mean(X);
        r0(k,:) = trova_r0(X{k});       %passo solo la matrice X{k}, relativa al k-esimo magnete
        V(k,:) = trova_V(r0(k,:), X{k}); 
    end
    
%% LUNGHEZZA TRAIETTORIE
% Ogni traiettoria ha una lunghezza finita. Trovo allora i punti della
% retta che sono estremi del segmento traiettoria.
% COME SONO ESPRESSI TALI PUNTI? Utilizzo la matrice lenght (nMag*2), che
% contiene per ogni riga(=per ogni magnete) il coefficiente moltiplicativo 
% min e max da moltiplicare per V, ed ottenere così i due estremi della
% traiettoria


    length = zeros(nMag,2);     
    for k = 1:nMag
        [length(k,1), length(k,2)] = find_length(X{k},r0(k,:),V(k,:));
    end
    
%% INIZIALIZZAZIONE TRAIETTORIE
    trajectories = zeros(nMag, 6);  %la matrice trajectories ha la forma, per ogni magnete, [xi xf yi yf zi zf]
    for k = 1:nMag
        trajectories(k, [1,3,5]) = r0(k,:) + V(k,:)*length(k,1);
        trajectories(k, [2,4,6]) = r0(k,:) + V(k,:)*length(k,2);
    end    
    
end