function [trajectories] =  setup_trajectories(localizations, val_start, val_end)
% Questo codice trova le traiettorie di movimento di un magnete
% La cell "localizations" deve contenere le rilevazioni dei magneti quando
% questi occupano le posizioni limite. Di questa cell, si considereranno
% solo le parti comprese tra val_start e val_end

% INPUT
% localizations = cell(1,num): localizations{i} = matrice nMag*6 -> contiene posizioni e orientazioni dei magneti alla i-esima rilevazione
% val_start, val_end = valori della cella da prendere in considerazione (la cella può essere molto grande, seleziono solo la parte che mi interessa)

% OUTPUT
% trajectories = matrice nMag*6: contiene le traiettorie di ogni magnete nella forma [xi, xf, yi, yf, zi, zf]


do_plot = 1;  % porre la variabile a zero se non si vuole il plot
nMag = size(localizations{1},1);


num = val_end - val_start - 1;
X_desired = cell(1,num);       % X_desired contiene le localizzazioni comprese nell'intervallo desiderato
for i = 1:num
    X_desired{i} = double(localizations{i+val_start});
end
            
% Salvo le localizzazioni in un formato più comodo: la cella num contiene una matrice per ciascun magnete.
% X{k} = matrice num*3, dove la i-esima riga contiene la posizione assunta
% dal k-esimo magnete alla rilevazione i

X = cell(1,nMag);
for k = 1:nMag                                %per ogni magnete
    for i = 1:num
        X{k}(i,:) = X_desired{i}(k,1:3);         %salvo i valori xyz delle posizioni assunte dal k-esimo magnete
    end
end


[r0,~, trajectories] = find_trajectory(X);           %Diamo in input alla funzione la cella X (ossia le posizioni rilevate dai sensori nella fase iniziale)

%   PLOT TRAJECTORIES
if do_plot
    figure
    hold on
    for k = 1:nMag
        plot3(X{k}(:,1)*1000, X{k}(:,2)*1000, X{k}(:,3)*1000,'o')
        plot3(r0(k,1)*1000,r0(k,2)*1000,r0(k,3)*1000, '+') 
        plot3(trajectories(k,1:2)*1000, trajectories(k,3:4)*1000, trajectories(k,5:6)*1000, 'LineWidth', 2)
        axis equal
    end
end

end