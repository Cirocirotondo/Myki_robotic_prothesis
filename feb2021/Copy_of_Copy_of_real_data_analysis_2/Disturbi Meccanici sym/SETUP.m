%Real Data Analysis
%Questa copia serve per fare delle modifiche senza rischiare di mandare a
%puttane il lavoro fatto finora


% This script first loads the data from the sperimental acquisitions. Then
% it calculates the trajectories followed by the magnets and it saves them
% in the matrix "trajectories_detected".

%NOTA: c'è una sottigliezza da risolvere: non so perché ma compare una
%misurazione di un magnete rosso in coordinate [0 0 0]. Però, se faccio
%stampare un'etichetta con il numero della misurazione, mi stampa un
%carattere strano. Comunuqe nel frattempo è un neo benigno: non sballa le
%misurazioni, la sua esistenza non viene minimamente presa in
%considerazione

clc
close all
clear all

addpath('../Mathworks Fede Thesis');
addpath('../Localizer');
addpath('../Localizer/Localizer 6DoF');
addpath('../6vs5DoF');

variables_DMsym 
clear boardsPose mrg nBoards



%% Magnets parameters
D = 0.004; % Diameter of the magnets
H = 0.002; % Height of the magnets
M = 1.2706/(4*pi*1e-7); % Magnetization of the magnets [A/m]
m = M*((D/2)^2*pi*H);

%% load data
% I valori di 'Data1_2' sono stati presi con i motori in movimento ed il
% mockup fermo. Numero magneti = 3.
% Ai dati è già stato sottratto l'offset.

data = load('Data_0412/data1_8.txt');     

Mf = data(1:nPos,1:end-4);      % nPos acquisizioni; le ultime 4 colonne contengono i tempi di acquisizione -> a noi non interessano

clear data

             
%% plot stato iniziale 
figure(1)
hold on
title('Stato iniziale')
plot_multiple_boards_without_vectors(sPos,'k');
plot_mags(Mag_Position(1:nMag,:), 6, 'k', 'r', 'b');


%% gestione dati
% I dati vengono salvati nella cella B (nPos*3*128)

B = cell(1,nPos);
x6 = cell(1,nPos);

% salvataggio campi magnetici
for k = 1:nPos
    current_data = Mf(k,:);         % load k-th line of data
    B{k} = zeros(3,128);            % B = 3*128 matrix -> prendo i dati dalla prima riga e li salvo nella matrice
    for i = 1:4
        B{k}(1,(i-1)*32+1:i*32) = current_data((i-1)*96+1:(i-1)*96+32)';
        B{k}(2,(i-1)*32+1:i*32) = current_data((i-1)*96+33:(i-1)*96+64)';
        B{k}(3,(i-1)*32+1:i*32) = current_data((i-1)*96+65:(i-1)*96+96)';
    end
end 

% otteniamo le posizioni dei magneti
num_misurazioni_radiate = 0;
for k = 1:nPos
    if k == 1
        x6{1} = localize_magnets(Mag_Position(1:nMag,:), B{k}', nMag, m, sPos);
%         if errore_rilevazione(Mag_Position(1:nMag, :),x6{1},boardsPoseMOKUP, SPOST_MAX)  %Questo andrà tolto!! non si può basare tutto su Mag_Position!! Se infatti non è accurato, si ha che il programma non funziona!!!
%             x6{1} = Mag_Position(1:nMag, :);
%         end
    else
        x6{k} = localize_magnets(x6{k-1}, B{k}', nMag, m, sPos);
        
        if errore_rilevazione(x6{k-1}, x6{k},boardsPoseMOKUP, SPOST_MAX)           %eliminazione errori di rilevazione
            x6{k} = x6{k-1};
            num_misurazioni_radiate = num_misurazioni_radiate + 1;
            radiata_misuraz_num = k
        end
    end
end
num_misurazioni_radiate_totali = num_misurazioni_radiate

%% plot posizioni rilevate
figure(2)
for k = 1:nPos
    clf
    hold on
    plot_multiple_boards(sPos, B{k}','k');
    plot_mags(x6{k}, 6, 'r', 'g', 'y');
    msg = "Rilevazione n." + k + " di " + nPos;
    title(msg);
    pause(0.005);
end



%% Group points in nMag groups
%A questa sezione vengono date come input le posizioni tutte le posizioni
%dei magneti rilevate dai sensori. Questa sezione si occupa di dividere
%tutte queste posizioni in nMag gruppi, ognuno dei quali contenente le
%posizioni assunte da un singolo magnete.
%Questa sezione butta fuori come output la matrice x6

% NON SERVE! (per ora...)


%% Find Trajectories
% Trovo le traiettorie utilizzando le posizioni assunte dai magneti. 
% Ciascuna traiettoria è salvata nella matrice "trajectories_detected"
% nella forma [xi, xf, yi, yf, zi, zf].
% La rappresentazione analitica delle rette su cui giacciono le traiettorie
% è "r(t) = r0 + V*t"
% r0 è una matrice nMag*3, contenente il punto base della retta
% V  è una matrice nMag*3, contenente il vettore unitario direzione

valore_da_cui_si_inizia_a_contare = 10;
x6_temp = cell(1,nPos-valore_da_cui_si_inizia_a_contare);
for i = 1:nPos-valore_da_cui_si_inizia_a_contare
    x6_temp{i} = x6{i+valore_da_cui_si_inizia_a_contare};
end

[r0,V, trajectories_detected] = find_trajectory(x6_temp);           %Diamo in input alla funzione il valore x6 (ossia le posizioni rilevate dai sensori nella fase iniziale. Infatti i sensori, nella fase di setup, sono fermi per ipotesi). Togliamo però i valori iniziali, che servono, diciamo, come assestamento

%% Direzione "media"
    direction_mean = zeros(nMag,3);
    for k = 1:nPos
        direction_mean = direction_mean + x6{k}(:,4:6);
    end
    direction_mean = direction_mean /nPos;
    
    for k = 1:nMag
        direction_mean(k,:) = direction_mean(k,:) / norm(direction_mean(k,:)); 
    end
    direction_mean = direction_mean
%% plot risultato

figure(3)

hold on
plot_multiple_boards(sPos, B{k}','k');
x6_plot = cell(1, nMag);      %X6{i} = matrice nPos*3 -> la i-esima matrice contiene tutti i valori assunti dall'i-esimo magnete nel tempo
for k = 1:nMag                              %per ogni magnete
    for i = valore_da_cui_si_inizia_a_contare:nPos
        x6_plot{k}(i,:) = x6{i}(k,1:3);         %salvo i valori xyz delle posizioni assunte dal k-esimo magnete
    end
end
for k = 1:nMag
    plot3(x6_plot{k}(:,1)*1000, x6_plot{k}(:,2)*1000, x6_plot{k}(:,3)*1000,'o')
    plot3(r0(k,1)*1000,r0(k,2)*1000,r0(k,3)*1000, '+') 
    plot3(trajectories_detected(k,1:2)*1000, trajectories_detected(k,3:4)*1000, trajectories_detected(k,5:6)*1000, 'LineWidth', 2)
%     plot_mags([r0(k,1),r0(k,2),r0(k,3),direction_mean(k,:)], 6, 'c', 'c', 'c')
    %     testo = string(1:nPos);
%     text(x6_plot{k}(:,1)*1000, x6_plot{k}(:,2)*1000, x6_plot{k}(:,3)*1000,testo,'FontSize', 8)   
    axis equal
end



 trajectories_detected = trajectories_detected




