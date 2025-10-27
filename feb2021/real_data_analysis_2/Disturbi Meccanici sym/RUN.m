%Real Data Analysis

%Questo script prende in input la matrice "trajectories_detected" dallo
%script "SETUP". 
%Dopodiché, prende nuovi dati e li analizza: se i magneti si trovano sulle
%loro traiettorie (a meno di errori di misurazione), allora nessun 
%problema, viene calcolata subito la posizione lungo la traiettoria.
%Se invece si trovano fuori dalla traiettoria (a causa di una 
%rototraslazione della protesi), viene eseguito l'algoritmo di 
%annullamento degli errori dovuti alla rototraslazione.
%Così, possono essere calcolate le posizioni corrette da mandare in output.

%NOTA: questo script lavora "a posteriori": riceve tutti i dati in ingresso
%all'inizio (e non uno alla volta, come invece succederebbe nella realtà).
%Comunque non è un grande problema perché lo script ne elabora uno alla
%volta, quindi può essere facilmente cambiato in modo da prendere un dato
%per volta.

%NOTA2: per ora, ho tolto tutta la parte riguardante il riordinamento dei
%magneti: infatti si è visto sperimentalmente che, se le traiettorie sono
%sufficientemente distanti, non c'è rischio di switch: nella matrice con
%le posizioni dei magneti, ogni magnete manterrà sempre la stessa riga.
%Ho tolto anche la parte riguardante gli errori (ang_max, boxPlotData, etc.) (infatti: errore rispetto a
%cosa? Non abbiamo più infatti un modello software con cui paragonare i
%nostri risultati, abbiamo solo i valori sperimentalmente misurati! ->NOTA:
%in realtà sappiamo qual è il movimento dei servomotori che simulano i
%muscoli: eventualmente si potranno utilizzare tali valori come termine di
%paragone. Ma comunque, non abbiamo modi precisi per misurare lo
%spostamento del mockup...)

%RICORDA! Alla fine controlla: 1) no "x6Mod" 2) no "trajectories" 3) no
%"costo" 4) "sPosMod" ?  5) pause(0.1) 6) ri-aggiungere parte riguardante
%"rototraslazione_sensori" 7) gestire in automatico il trasferimento di
%informazioni dallo script SETUP a RUN

%NOTA3: Ci sono due controlli dell'errore: il primo si ha immediatamente
%dopo la localizzazione dei magneti: non ce ne freghiamo del fatto che la
%protesi si stia muovendo, la nuova rilevazione deve essere comunque
%vicina alla rilevazione precedente (infatti, anche la protesi si muoverà
%con velocità limitata: se proprio, possiamo passare alla funzione
%"errore_rilevazione" non il valore SPOST_MAX, ma uno più grande - ad
%esempio, il suo doppio).
%Il secondo controllo si ha alla fine della compensazione della
%rototraslazione: la nuova posizione finale deve essere vicina alla
%precedente.
%ATTENZIONE: c'è il problema delle traslazioni lungo le y!!! Le traiettorie
%sono troppo direzionate lungo l'asse y, dunque non è possibile, attraverso
%la funzione di errore, trovare differenze tra una disposizione di magneti
%ed una sua piccola traslazione lungo l'asse y

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

data = load('Data_0305_mockup\data1_16_cut.txt');     

% RIGA PER RILEVAZIONI CON GET TRAIETTORIE INIZIALE Mf = data(1+90:nPos+90,1:end-4);      % nPos acquisizioni; le ultime 4 colonne contengono i tempi di acquisizione -> a noi non interessano
Mf = data(1:nPos,1:end-4);      % nPos acquisizioni; le ultime 4 colonne contengono i tempi di acquisizione -> a noi non interessano

clear data

%% gestione dati
% I valori dei campi magnetici vengono salvati nella cella B (nPos*3*128)

B = cell(1,nPos);
for k = 1:nPos
    current_data = Mf(k,:);         % load k-th line of data
    B{k} = zeros(3,128);            % B = 3*128 matrix -> prendo i dati dalla prima riga e li salvo nella matrice
    for i = 1:4
        B{k}(1,(i-1)*32+1:i*32) = current_data((i-1)*96+1:(i-1)*96+32)';
        B{k}(2,(i-1)*32+1:i*32) = current_data((i-1)*96+33:(i-1)*96+64)';
        B{k}(3,(i-1)*32+1:i*32) = current_data((i-1)*96+65:(i-1)*96+96)';
    end
end



%% Magnets localization
Tabs = tic;
Tloc_stp_old = 0;
figure('units','normalized','outerposition',[0 0 1 1])

%preallocations
    x6 = cell(1, nPos);              %posizioni rilevate
    x6Corrected = cell(1,nPos);      %posizioni finali dopo essere state riportate sulla giusta traiettoria tramite rototraslazione rigida
    rototranslation = cell(1,nPos);
    R = zeros(1,nPos);
    errore_da_stampare = zeros(1,nPos);
    for k = 1:nPos
        rototranslation{k} = zeros(1,6);
    end
    boxPlotData = zeros(nPos, nMag*2);
    costo_not_riordered = zeros(1,nPos);       %la cell "costo" indicava il costo dopo il riordinamento dei magneti. Ora però la parte di riordinamento dei magneti è stata tolta, quindi volendo si potrebbe cambiare il nome da "costo_not_riordered" a "costo"
    num_rilevazioni_radiate = 0;
    pos_along_trajectories = zeros(nPos,nMag);     %questa matrice contiene un numero tra 0 e 1 (ma può anche sforare) che indica la posizione del magnete lungo la traiettoria (0 = punto iniziale; 1 = punto finale)
    pos_along_trajectories_not_modified = zeros(nPos,nMag);

for k = 1:nPos
    pause(0.01)
    %% loc 6 DoF
    Tloc_srt = toc(Tabs);

    if k > 1
        disp(["Numero_ciclo = ", k])     %%riga di debug
        x6{k} = localize_magnets(x6{k-1}, B{k}', nMag, m, sPos);
         if errore_rilevazione(x6{k-1}, x6{k},boardsPoseMOKUP, 4*SPOST_MAX)           %eliminazione errori di rilevazione
            x6{k} = x6{k-1};
            x6Corrected{k} = x6Corrected{k-1};
            pos_along_trajectories(k,:) = pos_along_trajectories(k-1,:);
            pos_along_trajectories_not_modified(k,:) = pos_along_trajectories_not_modified(k-1,:);
            num_rilevazioni_radiate = num_rilevazioni_radiate + 1;
            fprintf('Radiata la misurazione n.%d, ancor prima di fare la rototraslazione', k)
            continue
         end
    else
        x6{1} = localize_magnets(Mag_Position(1:nMag,:), B{k}', nMag, m, sPos);     %first localization, starting from ground thruth
    end
  
  %% Controllo spostamento protesi ed eventuale correzione
    distances = calculate_distances(x6{k},trajectories_detected, nMag)

    everyone_in_trajectory = 1;
    for i = 1:nMag
        if distances(i) > errMax
            everyone_in_trajectory = 0;
        end
    end
    fprintf('everyone_in_trajectory = %d\n', everyone_in_trajectory)    % riga di debug
    x6Corrected{k} = x6{k};

    if everyone_in_trajectory == 0      % se c'è qualche magnete fuori dalla propria traiettoria
            distanze_iniziali = calculate_distances(x6{k},trajectories_detected, nMag);
        if k > 1    
            rototranslation{k} = find_rototranslation(x6{k}, trajectories_detected,direction_mean, nMag,errMax, rototranslation{k-1});
            disp(["Rototranslation = ", rototranslation{k}])       %riga di debug
        else 
            rototranslation{1} = find_rototranslation(x6{k}, trajectories_detected,direction_mean, nMag, errMax, zeros(1,6));
            disp(["Rototranslation = ", rototranslation{k}])       %riga di debug
        end
        x6Corrected{k} = rotoTrasla(x6{k}, rototranslation{k});
        costo_not_riordered(k) = cost_function(rototranslation{k}, x6Corrected{k}, trajectories_detected, nMag, errMax);  
        %righe di debug:
        fprintf('Costo = %s\n',costo_not_riordered(k))                 %riga di debug
        fprintf('distanze_iniziali = [%d, %d, %d]\n', distanze_iniziali(1), distanze_iniziali(2), distanze_iniziali(3));
        distances = calculate_distances(x6Corrected{k},trajectories_detected, nMag);
        fprintf('distanze_finali = [%d, %d, %d]\n', distances(1), distances(2), distances(3));
        everyone_in_trajectory = 1;
        for i = 1:nMag
           if distances(i) > errMax
               everyone_in_trajectory = 0;
           end
        end
        if everyone_in_trajectory == 1
             fprintf('RISLTO! ADESSO "everyone_in_trajectory" = 1!!!\n')    % riga di debug
        elseif everyone_in_trajectory == 0
            fprintf('NOOO! RIMANE "everyone_in_trajectory" = 0...\n')    % riga di debug
        end
        %fine righe di debug
    end


    %% Eliminazione rilevamenti evidentemente errati
    % Nel caso ci sia un errore evidente, la rilevazione viene trascurata, e i
    % dati rimangono invariati rispetto al passo precedente (= la protesi rimane
    % ferma)
    % COME SI DETERMINA SE UNA MISURAZIONE E' ERRATA? 
    % 1) Se il costo è particolarmente superiore alla media
    %   (CostoMax = 1.5 se nMag = 4; = 0.2 se nMag = 5)
    % 2) Se c'è almeno un magnete che si muove rispetto alla misurazione 
    % precedente di più di 2 cm (il mockup lavora a 20 Hz...)
    % 3) Se c'è qualche magnete che viene rilevato fuori dalle boundaries

    
    if costo_not_riordered(k) > 0.15  || (k > 1 && errore_rilevazione(x6Corrected{k-1}, x6Corrected{k},boardsPoseMOKUP, SPOST_MAX))
        costo_not_riordered(k) = costo_not_riordered(k-1);
        x6Corrected{k} = x6Corrected{k-1};
        disp('Rilevazione Radiata!')
        num_rilevazioni_radiate = num_rilevazioni_radiate + 1;
    end


    
    %% CALCOLO POSIZIONE SULLA TRAIETTORIA

    pos_along_trajectories(k,:) = calculate_pos_along_trajectories(x6Corrected{k}(:,1:3),trajectories_detected);
    pos_along_trajectories_not_modified(k,:) = calculate_pos_along_trajectories(x6{k}(:,1:3),trajectories_detected);

    %% Calcolo errore

    %% visualizzazione
   if plotta_grafici_3D
      % FIGURE 1: stampa posizione rilevata e corretta dei magneti
      figure(1)
      clf
      hold on
      title("Iterazione n." + k + " di " + nPos);
      plot_mags(x6{k}, 6, 'c', 'c', 'c');            % dove vengono visti i magneti dal sistema traslato
      plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
      plot_multiple_boards(sPos, B{k}','k');         % stampa sensori e vettori di campo magnetico
      %SC: stampa traiettorie
      for j = 1:nMag
          plot3(trajectories_detected(j, 1:2)*1000, trajectories_detected(j,3:4)*1000, trajectories_detected(j, 5:6)*1000, "LineWidth", 3)
      end
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
    
%       % FIGURE 2: mostra la consequenzialità delle misurazioni, grazie
%       % all'alternanza dei colori (comprensibile e utile solo per nPos 
%       % piccoli) -> utili per capire se la direzione del movimento viene
%       % mantenuta (infatti, se c'è un pò di errore di misurazione, non è di
%       % per sé un grande problema: per ottenere un utilizzo fluido della
%       % protesi, bisgona accertarsi però che se il paziente muove un
%       % muscolo in una direzione, anche la protesi proceda in una sola
%       % direzione, senza fare scatti avanti-indietro)
%       figure(2)
%       hold on
%       if mod(k,3) == 1
%           plot_mags(x6Corrected{k}, 6, 'r', 'r', 'r')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
%       elseif mod(k,3) == 2
%           plot_mags(x6Corrected{k}, 6, 'g', 'g', 'g')
%       elseif mod(k,3) == 0
%           plot_mags(x6Corrected{k}, 6, 'b', 'b', 'b')
%       end
%       plot_multiple_boards_without_vectors(sPos,'k');
%       for j = 1:nMag     %SC: stampa traiettorie
%          plot3(trajectories_detected(j, 1:2)*1000, trajectories_detected(j,3:4)*1000, trajectories_detected(j, 5:6)*1000, "LineWidth", 3)
%       end
%       hold off

    %FIGURE2: stampa di tutte le posizioni rilevate dei magneti
    figure(2)
    hold on
    plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
    for j = 1:nMag          %SC: stampa traiettorie
        plot3(trajectories_detected(j, 1:2)*1000, trajectories_detected(j,3:4)*1000, trajectories_detected(j, 5:6)*1000, "LineWidth", 3)
    end
    plot_multiple_boards_without_vectors(sPos,'k');
    hold off
    
   end
end


% %FIGURE 3,4: per ora non fa nulla. Però, potrò utilizzarla per mostrare la
% %traslazione totalerilevata dei sensori. Giusto per avere qualche
% %termine di paragone
% figure(3)
% trasl_tot_sensori  = zeros(1,nPos);
% ang_tot_sensori = zeros(1,nPos);
% for k = 1:nPos
%     trasl_tot_sensori(k) = norm( rototraslazione_sensori{k}(1:3))*1000;    %unità di misura: mm
%     ang_tot_sensori(k) = sum(abs( rototraslazione_sensori{k}(4:6) )); 
% end
% 
% figure(4)
% 
% plot3(trasl_tot_sensori, ang_tot_sensori, errore_da_stampare,'o', 'LineStyle', 'none');
% xlabel('traslazione totale sensori')
% ylabel('somma angoli di rotazione dei sensori')
% zlabel('errore della misura')
% labels = string(1:nPos);
% text(trasl_tot_sensori, ang_tot_sensori, errore_da_stampare, labels, 'FontSize',8 )
% 
% figure(5)
% plot(R, costo, 'o', 'LineStyle', 'none');
% xlabel('R')
% ylabel('costo')
% labels = string(1:nPos);
% text(R, costo, labels, 'FontSize',8 )

    %% FIGURE3: pos_along_trajectories
    figure(3)
    for i = 1:nMag
        hold on
        subplot(nMag,1, i);
        if i == 1
            plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1+90:nPos+90,1),'k');
%               plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1:nPos,1),'k');
        elseif i == 2
            plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1+90:nPos+90,3),'k');
%             plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1:nPos,3),'k');
        else 
            plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1+90:nPos+90,2),'k');
%             plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1:nPos,2),'k');
        end
        titolo = "Posizioni assunte dal magnete " + i;
        title(titolo);
        legend('Posizioni con correzione', 'Posizioni senza correzione', 'Posizione reale');
    end
num_rilevazioni_radiate = num_rilevazioni_radiate


%% SALVATAGGI
filename = ['Savings/N', num2str(size(dir('Savings'),1)-1), '_6DoFs_', num2str(nMag), 'Magnets_', num2str(nPos), 'iterations.mat'];
% save(filename, 'x6', 'X', 'B', 'nMag', 'nPos', 'dist', 'alpha', 'min_dist', 'sPos', 'bounds', 'Tloc_run6', 'ep6', 'eo6');





