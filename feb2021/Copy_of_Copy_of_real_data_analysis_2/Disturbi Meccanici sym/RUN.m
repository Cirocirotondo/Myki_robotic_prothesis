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

%RICORDA! Alla fine controlla:  3) no
%"costo" 4) "sPosMod" ?  5) pause(0.1) 7) gestire in automatico il trasferimento di
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

data = load('Data_0305_mockup\data1_17_cut.txt');     

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
    pos_along_trajectories_not_modified = zeros(nPos,nMag); %Stessa cosa, solo che usato per i magneti prima della correzione
    norm_not_modified_mm = zeros(nPos,nMag);

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
            norm_not_modified_mm(k,:) = norm_not_modified_mm(k-1,:);
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
        if k > 1    
            rototranslation{k} = find_rototranslation(x6{k}, trajectories_detected, direction_mean, nMag,errMax, rototranslation{k-1},boardsPoseMOKUP,pos_along_trajectories(k-1,:),x6Corrected{k-1});
            disp(["Rototranslation = ", rototranslation{k}])       %riga di debug
        else 
            rototranslation{1} = find_rototranslation(x6{k}, trajectories_detected,direction_mean, nMag, errMax, zeros(1,6),boardsPoseMOKUP, [0.5, 0.5, 0.5], x6{1});
            disp(["Rototranslation = ", rototranslation{k}])       %riga di debug
        end
        x6Corrected{k} = rotoTrasla(x6{k}, rototranslation{k},boardsPoseMOKUP);
        costo_not_riordered(k) = cost_function(rototranslation{k}, x6Corrected{k}, trajectories_detected, nMag, errMax,boardsPoseMOKUP);  
        %righe di debug:
        fprintf('Costo = %s\n',costo_not_riordered(k))                 
        fprintf('distanze_iniziali = [%d, %d, %d]\n', distances(1), distances(2), distances(3));
        distances_corrected = calculate_distances(x6Corrected{k},trajectories_detected, nMag);
        fprintf('distanze_finali = [%d, %d, %d]\n', distances_corrected(1), distances_corrected(2), distances_corrected(3));
        
%% eventuale forzatura dei magneti sulle traiettorie

        everyone_in_trajectory = 1;
        for i = 1:nMag
           if distances(i) > errMax
               everyone_in_trajectory = 0;
           end
        end
        if everyone_in_trajectory == 1
             fprintf('RISOLTO! ADESSO "everyone_in_trajectory" = 1!!!\n')    % riga di debug
        elseif everyone_in_trajectory == 0
            fprintf('NOOO! RIMANE "everyone_in_trajectory" = 0...\n')    % riga di debug
            %FORZO I MAGNETI LUNGO LA TRAIETTORIA: in questo modo, alla
            %successiva iterazione, l'ottimizzazione parte da un punto che
            %già si trova sulla traiettoria
        end
        
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
    % del mockup
    
    if costo_not_riordered(k) > 0.15  || (k > 1 && errore_rilevazione(x6Corrected{k-1}, x6Corrected{k},boardsPoseMOKUP, SPOST_MAX))
        costo_not_riordered(k) = costo_not_riordered(k-1);
        x6Corrected{k} = x6Corrected{k-1};
        x6{k} = x6{k-1};
        pos_along_trajectories_not_modified(k,:) = pos_along_trajectories_not_modified(k-1,:);
        norm_not_modified_mm(k,:) = norm_not_modified_mm(k-1,:);
        disp('Rilevazione Radiata!')
        num_rilevazioni_radiate = num_rilevazioni_radiate + 1;
    end


%% CALCOLO POSIZIONE SULLA TRAIETTORIA

    pos_along_trajectories(k,:) = calculate_pos_along_trajectories(x6Corrected{k}(:,1:3),trajectories_detected);
    pos_along_trajectories_not_modified(k,:) = calculate_pos_along_trajectories(x6{k}(:,1:3),trajectories_detected);
    norm_not_modified_mm(k,:) = calculate_norm(x6{k},trajectories_detected);        %Questo è il dato che andrà stampato nei grafici
    
    

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
     % plot_mags(x6SaveBeforeMoving, 6, 'g','g','g')
      
      %SC: stampa traiettorie
      for j = 1:nMag
          plot3(trajectories_detected(j, 1:2)*1000, trajectories_detected(j,3:4)*1000, trajectories_detected(j, 5:6)*1000, "LineWidth", 3)
      end
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
      
    %FIGURE2: stampa di tutte le posizioni rilevate dei magneti
%     figure(2)
%     hold on
%     plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
%     for j = 1:nMag          %SC: stampa traiettorie
%         plot3(trajectories_detected(j, 1:2)*1000, trajectories_detected(j,3:4)*1000, trajectories_detected(j, 5:6)*1000, "LineWidth", 3)
%     end
%     plot_multiple_boards_without_vectors(sPos,'k');
%     hold off
    
   end
end

    %% FIGURE3: pos_along_trajectories
    %posizioni in millimetri (ottenute scalando la posizione)
    
%     lunghezze traiettorie
    len_trajectories = zeros(nMag,1);
    for i = 1:nMag
        len_trajectories(i) = norm(trajectories_detected(i,[1,3,5]) - trajectories_detected(i,[2,4,6]))*1000;
    end
    
%     calcolo posizione in millimetri per:
%       1) posizioni dei magneti corrette (pos_along_trajectories)
%       2) Stepper motor
    y = zeros(nPos,nMag);
    y_mm = y;
    stepper_positions_mm = stepper_positions;
    
    for i = 1:nMag
        y(:,i) = smoothdata(pos_along_trajectories(:,i),'SmoothingFactor',0.1);
        y_mm(:,i) = y(:,i) * len_trajectories(i);
    end
   
   stepper_positions_mm(:,1) = stepper_positions(:,1) * len_trajectories(1);    
   stepper_positions_mm(:,2) = stepper_positions(:,2) * len_trajectories(3);        %NB!! LE POSIZIONI DEGLI STEPPER MOTOR SONO SWITCHATE!!
   stepper_positions_mm(:,3) = stepper_positions(:,3) * len_trajectories(2);
    
    
   

% Grafico   
    close all
    figure(3)
    for i = 1:nMag
        hold on
        subplot(nMag,1, i);
        if i == 1
            p = plot(1:nPos, y_mm(:,i),'g',1:nPos, norm_not_modified_mm(:,i), 'c', 1:nPos, stepper_positions_mm(1+90:nPos+90,1),'k');
%             p = plot(1:nPos, y_mm(:,i),'g',1:nPos, norm_not_modified_mm(:,i), 'c', 1:nPos, stepper_positions_mm(1+680:nPos+680,1),'k');
        elseif i == 2
            p = plot(1:nPos, y_mm(:,i),'g',1:nPos, norm_not_modified_mm(:,i), 'c', 1:nPos, stepper_positions_mm(1+85:nPos+85,3),'k');
%             p = plot(1:nPos, y_mm(:,i),'g',1:nPos, norm_not_modified_mm(:,i), 'c', 1:nPos, stepper_positions_mm(1+680:nPos+680,3),'k');

        else 
            p = plot(1:nPos, y_mm(:,i),'g',1:nPos, norm_not_modified_mm(:,i), 'c', 1:nPos, stepper_positions_mm(1+90:nPos+90,2),'k');
%             p = plot(1:nPos, y_mm(:,i),'g',1:nPos, norm_not_modified_mm(:,i), 'c', 1:nPos, stepper_positions_mm(1+680:nPos+680,2),'k');
        end
        p(1).LineWidth = 2;
        p(2).LineWidth = 2;
        p(3).LineWidth = 2;
        titolo = "Posizioni assunte dal magnete " + i;
        title(titolo);
        legend('Posizioni con correzione', 'Posizioni senza correzione', 'Posizione reale');
    end
num_rilevazioni_radiate = num_rilevazioni_radiate


%% SALVATAGGI
filename = ['Savings/N', num2str(size(dir('Savings'),1)-1), '_6DoFs_', num2str(nMag), 'Magnets_', num2str(nPos), 'iterations.mat'];
% save(filename, 'x6', 'X', 'B', 'nMag', 'nPos', 'dist', 'alpha', 'min_dist', 'sPos', 'bounds', 'Tloc_run6', 'ep6', 'eo6');





