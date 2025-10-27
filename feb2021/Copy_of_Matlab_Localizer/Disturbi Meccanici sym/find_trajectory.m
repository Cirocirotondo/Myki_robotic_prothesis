function[r0, V, trajectories] = find_trajectory(X_cell)

    [~,num_points] = size(X_cell);
    [nMag,~] = size(X_cell{1});
    X = cell(1, nMag);      %X{i} = zeros(num_points,3);
    
    for k = 1:nMag                                %per ogni magnete
        for i = 1:num_points
            X{k}(i,:) = X_cell{i}(k,1:3);         %salvo i valori xyz delle posizioni assunte dal k-esimo magnete
        end
    end
    
    r0 = zeros(nMag,3);
    V = zeros(nMag,3);
    
    for k = 1:nMag
        % retta espressa come "r(t) = r0 + t * V(:,1)"
        %r0 = mean(X);
        r0(k,:) = trova_r0(X{k});       %passo solo la matrice X{k}, relativa al k-esimo magnete
        V(k,:) = trova_V(r0(k,:), X{k}); 
    end
    
    %LUNGHEZZA TRAIETTORIE
    
    length = zeros(nMag,2);     %la matrice contiene per ogni riga(=per ogni magnete) il coefficiente moltiplicativo min e max da moltiplicare per V, ed ottenere così i due estremi della traiettoria 
    for k = 1:nMag
        [length(k,1), length(k,2)] = find_length(X{k},r0(k,:),V(k,:));
    end
    
    %INIZIALIZZAZIONE TRAIETTORIE
    trajectories = zeros(nMag, 6);  %la matrice trajectories ha la forma, per ogni magnete, [xi xf yi yf zi zf]
    for k = 1:nMag
        trajectories(k, 1:2:5) = r0(k,:) + V(k,:)*length(k,1);
        trajectories(k, 2:2:6) = r0(k,:) + V(k,:)*length(k,2);
    end
    
    
    
    
    
    
    
    
    
    
    
    
% Metodo trovato su internet
% ("https://it.mathworks.com/matlabcentral/answers/424591-3d-best-fit-line"
% Non mi funziona, e comunuqe non l'ho capito... che diavolo è "svd"?!?)

%     X = X';
%     %Engine
%     xyz0 = mean(X,2);
%     A = X-xyz0;
%     [U,S,~] = svd(A);
%     d = U(:,1);
%     t = d'*A;
%     t1 = min(t);
%     t2 = max(t);
%     xyz1 = xyz0 + [t1,t2].*d; % size 3x2
% 
%     close all
%     hold on
%     plot3(X(:,1), X(:,2), X(:,3),'o')
%     plot3(xyz1(1,:), xyz1(2,:), xyz1(3,:), 'r')
%     axis equal
%     hold off
    
    
end