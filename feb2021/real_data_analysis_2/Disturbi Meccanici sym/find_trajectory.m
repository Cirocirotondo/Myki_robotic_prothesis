function[r0, V, trajectories] = find_trajectory(X_cell)
%Questa funzione ottiene le traiettorie dei magneti a partire dalle
%posizioni sperimentali acquisite con le misurazioni sperimentali

    [~,num_points] = size(X_cell);      %num_points equivale a nPos. Però sono stupido e allora gli ho dato un nome diverso, creando inutilmente fonti di confusione
    [nMag,~] = size(X_cell{1});
    X = cell(1, nMag);          %X{i} = matrice num_points*3
    
    for k = 1:nMag                                %per ogni magnete
        for i = 1:num_points
            X{k}(i,:) = X_cell{i}(k,1:3);         %salvo i valori xyz delle posizioni assunte dal k-esimo magnete
        end
    end

    r0 = zeros(nMag,3);
    V = zeros(nMag,3);
    
%%  r0 e V
    for k = 1:nMag
        % retta espressa come "r(t) = r0 + t * V(:,1)"
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
        trajectories(k, 1:2:5) = r0(k,:) + V(k,:)*length(k,1);
        trajectories(k, 2:2:6) = r0(k,:) + V(k,:)*length(k,2);
    end 
    
    
end