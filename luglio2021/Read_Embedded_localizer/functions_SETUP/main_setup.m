%% SETUP TRAIETTORIE

% Questo codice trova le traiettorie di movimento di un magnete
% La cell "localizations" deve contenere le rilevazioni dei magneti quando
% questi occupano le posizioni limite

% Questa codice si dovrà inserire (naturalmente modificato correttamente 
% in modo da renderlo una funzione) nel corretto punto del programma
% principale

% PARTI DA COMPLETARE: 
% - valutare se inserire l'eliminazione delle rilevazioni evidentemente errate
% - controllare le unità di misura, eventualmente convertire (ex. m - mm)

clear all
clc


%% GET LOCALIZATIONS
% Qui andrà inserita la sezione che si occupa di ottenere le localizzazioni
% passate dalla scheda embedded

% Per ora, passo delle localizzazioni a mano
load("localizations_workspace.mat")
[nMag,~] = size(localizations{1});


%% FIND TRAJECTORIES
% Trovo le traiettorie utilizzando le posizioni assunte dai magneti. 
% Ciascuna traiettoria è salvata nella matrice "trajectories_detected"
% nella forma [xi, xf, yi, yf, zi, zf].
% La rappresentazione analitica delle rette su cui giacciono le traiettorie
% è "r(t) = r0 + V*t"
% r0 è una matrice nMag*3, contenente il punto base della retta
% V  è una matrice nMag*3, contenente il vettore unitario direzione

val_start = 10;             %[val_start, val_end] = intervallo preso in considerazione per la fase di setup
val_end = 150;
num = val_end - val_start - 1;
X_desired = cell(1,num);       % x_temp contiene le localizzazioni comprese nell'intervallo desiderato
for i = 1:num
    X_desired{i} = localizations{i+val_start};
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


[r0,V, trajectories] = find_trajectory(X);           %Diamo in input alla funzione la cella X (ossia le posizioni rilevate dai sensori nella fase iniziale)

%   PLOT TRAJECTORIES
figure
hold on
for k = 1:nMag
    plot3(X{k}(:,1)*1000, X{k}(:,2)*1000, X{k}(:,3)*1000,'o')
    plot3(r0(k,1)*1000,r0(k,2)*1000,r0(k,3)*1000, '+') 
    plot3(trajectories(k,1:2)*1000, trajectories(k,3:4)*1000, trajectories(k,5:6)*1000, 'LineWidth', 2)
    %     testo = string(1:nPos);
%     text(X{k}(:,1)*1000, X{k}(:,2)*1000, X{k}(:,3)*1000,testo,'FontSize', 8)   
    axis equal
end