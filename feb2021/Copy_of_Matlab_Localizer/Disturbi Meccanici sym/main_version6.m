%Version6: 



% This script first generates the field on the sensors using the analytical
% model (that we assume comparable to the COMSOL model), then use those
% data to localize the magnets using the 6 and the 5 DoFs dipole model.

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

%% Magnets trajectories generation
% X{1} = [0.0210572820620418,0.0477118865659122,0.0380913456584975,0.0455024437693301,0.945666745950912,-0.321937778481545;0.0293404956897113,0.0242490820138775,0.0622691495745998,0.830581625896749,0.0760889005537881,0.551674398477243;0.0160364326384485,0.0628167118850397,0.0676144317042448,0.216606229521388,0.610712355428865,0.761650943844394;0.0281891678092055,0.0324867215690577,0.0393323790103808,-0.658428464854838,0.538708531648503,-0.525609241355225;0.0297115035491751,0.0357082140882732,0.0630670313821781,0.370279004358944,0.570702940916689,-0.732933565993529]';
%X{1} = x';
for i = 1:nMag
   prev_dir{i} = [];
%  prev_dir{i} = [0; 1; 0];
end
% for i = 2:nPos
% %   [X{i}] = X{i-1};
%   %[X{i}, prev_dir] = randomly_move_magnets(X{i-1}, dist, alpha, prev_dir);
%   X{i} = X{1};      %per ora, considero i magneti fermi. Ricorda di rimettere a posto questa sezione, alla fine!!
% end

X = cell(1,nPos);  %preallocation
for i = 1:nPos
    X{1,i} = ones(nMag,6);
end

[X{1}, tVector] = random_start_along_trajectories(trajectories, nMag);
X{1} = X{1}';

for i = 2:nPos
    [X{i}, tVector] = randomly_move_magnets_along_trajectories(trajectories, nMag, tVector);
    X{i} = X{i}';
end

% per ora è solo questa che conta!! Togliere alla fine!!
for i = 1:nPos
    for n = 1:nMag
         t = stepper_positions(i,n);
         X{i}(1:3,n) = (trajectories(n,1:2:5)*t + trajectories(n,2:2:6)*(1-t))';
         X{i}(4:6,n) = [0 0 -1]';
    end
end





%% SC: Rototrasla i sensori (sPos)
sPosMod = cell(1,nPos);     %sPosMod{i} è la cell contenente le posizioni dei sensori nel tempo
sPosMod{1} = sPos;          %al primo istante, i sensori sono fermi
rototraslazione_sensori = cell(1,nPos);
rototraslazione_sensori{1} = [0 0 0 0 0 0];
for i = 2:nPos
%     [sPosMod{i}, rototraslazione_sensori{i}] = randomly_move_sensors(sPosMod{i-1});
     [sPosMod{i}, rototraslazione_sensori{i}] = randomly_move_sensors(sPos, rototraslazione_sensori{i-1});     %la traslazione avviene rispetto alla posizione iniziale!!!! O, per lo meno, se lo fai rispetto alla posizione precedente, tienine conto!!!!
end
  



%% Field (B) generation
Tgen = tic;
B = cell(1,nPos);
B1 = cell(1, nPos);
for i = 1:nPos
  noise = normrnd(0, noise_sd, 3, size(sPos,1));
  B{i} = (ParallelGenerateReadings(D,H,M,X{i},sPos'))*10000 + noise;    % multiplication is for converting from tesla to gauss
  
  %SC: creo B1{i}, che è la cell contenente le rilevazioni fatte dai sensori
  %che si sono spostati
  B1{i} = (ParallelGenerateReadings(D,H,M,X{i},sPosMod{i}'))*10000 + noise;
end
B_generation_time = toc(Tgen);
disp(['Contemporary computation of the magnetic field done in ', num2str(round(B_generation_time*1000)), ' ms.'])
for i = 1:nPos
  X{i} = X{i}';
end

%per ora è solo questa che conta! togliere alla fine!
B1_temp = B_generated.B;
for i = 1:nPos
    B1{i} = B1_temp{i};
    B1{i}(:,1:32) = B1_temp{i}(:,65:96);
    B1{i}(:,65:96) = B1_temp{i}(:,1:32);
end

%% Magnets localization
Tabs = tic;
Tloc_stp_old = 0;
figure('units','normalized','outerposition',[0 0 1 1])

%rototranslation = zeros(1,6);       %inizializzo "rototranslation" con zeri, perché c'è bisogno della condizione iniziale per il primo giro
x6Corrected = cell(1,nPos);
x6 = cell(1, nPos);
x6Mod = cell(1, nPos);
x6Riord = cell(1, nPos);
x6ModRiord = cell(1,nPos);
x6CorrectedRiord = cell(1,nPos);
rototranslation = cell(1,nPos);
R = zeros(1,nPos);
errore_da_stampare = zeros(1,nPos);
for k = 1:nPos
    rototranslation{k} = zeros(1,6);
end
boxPlotData = zeros(nPos, nMag*2);
costo = zeros(1,nPos);
costo_not_riordered = zeros(1,nPos);
for k = 1:nPos
  pause(0.01)
  %% loc 6 DoF
  Tloc_srt = toc(Tabs);

  if k > 1
    numero_ciclo = k
%     x6{k} = localize_magnets(x6{k-1}, B{k}', nMag, m, sPos);
    x6{k} = localize_magnets(X{k-1}, B{k}', nMag, m, sPos);
    x6Riord{k} = riordina_magneti(x6{k}, trajectories);         %nota: a programma terminato, si può risparmiare memoria togliendo una delle due matrici
    %SC: la matrice x6Mod contiene la posizione predetta dal sistema avente i
    %sensori spostati (sPosMod) -> per questo il valore del campo magnetico
    %passato è B1{i}. N.B: Viene comunque passato "sPos" anziché "sPosMod{i}",
    %poiché il sistema non sa di essersi spostato rispoetto al SR (fisso) 
    %del braccio: pensa ancora di trovarsi in sPos!
%     x6Mod{k} = localize_magnets(x6Mod{k-1}, B1{k}', nMag, m, sPos);
    x6Mod{k} = localize_magnets(X{k-1}, B1{k}', nMag, m, sPos);
    
%     x6ModRiord{k} = riordina_magneti(x6Mod{k}, trajectories);      %per ora, questa riga non serve a niente %nota: a programma terminato, si può risparmiare memoria togliendo una delle due matrici
    
  else
    x6{1} = localize_magnets(X{1}, B{k}', nMag, m, sPos);     %first localization, starting from ground thruth
    x6Mod{1} = x6{1};       %SC: x6Pos{i} = x6{i}, dal momento che nel nostro modello, all'istante 0, il sistema non si è ancora spostato
    x6Riord{1} = x6{1};
    x6ModRiord{1} = x6{1};
  end
  
% NORMALIZZAZIONE & CHECK NORMALIZED  
%   for i = 1:nMag
%     x6{k}(i, 4:6) = x6{k}(i, 4:6)/norm(x6{k}(i,4:6));
%   end
%   
%   normalized = ones(nMag, 1)
%     for i = 1:nMag
%         if norm(x6{k}(i,4:6)) ~= 1
%             normalized(i) = 0;
%         end
%     end
%     normalized = normalized
  
  Tloc_run6(k) = toc(Tabs) - Tloc_srt;
  Tloc_stp = toc(Tabs);
  Ttot = Tloc_stp - Tloc_stp_old;
  Tloc_stp_old = Tloc_stp;
  disp(['Fequenza output:', num2str(round(1/Ttot,2)), ' Hz. #iterazione: ', num2str(k), '.     T_loc_6DoF: ',  num2str(round(Tloc_run6(k)*1000,2)) , 'ms'])
  
  
  
  %% Compute error
%   X_sort = sortMagnets(X{k}, sort_axis);
%   x6_sort = sortMagnets(x6{k}, sort_axis);
%   ep6(k,:) = point2pointDist(x6_sort, X_sort);  % position error in the 6 DoFs algorithm
%   eo6(k,:) = vec2vecAngle(x6_sort, X_sort);  % orientation error in the 6 DoFs algorithm
  

  
  %% SC: Parte tosta
distances = calculate_distances(x6Mod{k},trajectories, nMag)

everyone_in_trajectory = 1;
for i = 1:nMag
    if distances(i) > errMax
        everyone_in_trajectory = 0;
    end
end
everyone_in_trajectory             % togliere riga a fine debug
x6Corrected{k} = x6Mod{k};
x6CorrectedRiord{k} = x6Corrected{k};

if everyone_in_trajectory == 0
    if k > 1
        rototranslation{k} = find_rototranslation(x6Mod{k}, trajectories, nMag,errMax, rototranslation{k-1});
        Rototranslation = rototranslation{k}                %riga di debug
    else 
        rototranslation{1} = find_rototranslation(x6Mod{k}, trajectories, nMag,errMax, zeros(1,6));
        Rototranslation = rototranslation{1}                %riga di debug
    end
    traslazione_reale_sensori = rototraslazione_sensori{k}      %riga di debug
    x6Corrected{k} = rotoTrasla(x6Mod{k}, rototranslation{k});
%    x6CorrectedRiord{k} = riordina_magneti(x6Corrected{k}, trajectories);         %nota: a programma terminato, si può risparmiare memoria togliendo una delle due matrici
    costo_not_riordered(k) = cost_function(rototranslation{k}, x6Corrected{k}, trajectories, nMag, errMax);
    costo(k) = cost_function(rototranslation{k}, x6CorrectedRiord{k}, trajectories, nMag, errMax);   
    Costo = costo(k)            %riga di debug
    
end


%% Eliminazione rilevamenti evidentemente errati
%Nel caso ci sia un errore evidente, la rilevazione viene trascurata, e i
%dati rimangono invariati rispetto al passo precedente (= la protesi rimane
%ferma)
%CostoMax = 1.5 se nMag = 4; = 0.2 se nMag = 5
num_rilevazioni_radiate = 0;
if costo(k) > 0.15       
    costo(k) = costo(k-1);
    x6Corrected{k} = x6Corrected{k-1};
    disp('Rilevazione Radiata!')
    num_rilevazioni_radiate = num_rilevazioni_radiate + 1;
end


%% Calcolo errore
[pos_err, ang_err] = calcola_errore(X{k},x6CorrectedRiord{k}, nMag);

errore_da_stampare(k) = max(pos_err);

errori = [pos_err', ang_err']

boxPlotData(k,:) = [pos_err, ang_err];

R(k) = calcola_R(X{k},sPosMod{k});




%% visualizzazione
  if plotta_grafici_3D
    figure(1)
    clf
    hold  on
    title("Iterazione n." + k + " di " + nPos);
    plot_mags(X{k}, 6, 'r', 'g', 'y');      % original
    plot_mags(x6Riord{k}, 6, 'k', 'r', 'b');      % 6 DoF
    plot_mags(x6Mod{k}, 6, 'c', 'c', 'c');   % dove vengono visti i magneti dal sistema traslato
    plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
    
    %SC: stampa traiettorie
    for j = 1:nMag
        plot3(trajectories(j, 1:2)*1000, trajectories(j,3:4)*1000, trajectories(j, 5:6)*1000, "LineWidth", 3)
    end
 
    plot_multiple_boards(sPosMod{k}, B1{k}', 'g') %stampa sensori rototraslati
    plot_multiple_boards(sPos, B{k}','k');

    axis equal
    if blocco_vista
      axis(bounds*1000)
    end
    hold off
    
    figure(2)
    hold on
    plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
    %SC: stampa traiettorie
    for j = 1:nMag
        plot3(trajectories(j, 1:2)*1000, trajectories(j,3:4)*1000, trajectories(j, 5:6)*1000, "LineWidth", 3)
    end
    
    plot_multiple_boards_without_vectors(sPos,'k');

    hold off

    pause(0.01);
    
  end

  [x6{k}, fails6(k)] = are_positions_acceptable(x6{k}, bounds, min_dist, sPos);
end

figure(3)
title("Errori di traslazione (in 'mm', a destra) e di rotazione (in '°', a sinistra)");
subplot(1,2,1)
boxplot(boxPlotData(:,1:nMag)*1000)         %il fattore moltiplicativo "x1000" serve a usare il millimetro come unità di misura
    
subplot(1,2,2)
boxplot(boxPlotData(:,nMag+1:2*nMag))

%stampa grafico 4
trasl_tot_sensori  = zeros(1,nPos);
ang_tot_sensori = zeros(1,nPos);
for k = 1:nPos
    trasl_tot_sensori(k) = norm( rototraslazione_sensori{k}(1:3))*1000;    %unità di misura: mm
    ang_tot_sensori(k) = sum(abs( rototraslazione_sensori{k}(4:6) )); 
end

figure(4)

plot3(trasl_tot_sensori, ang_tot_sensori, errore_da_stampare,'o', 'LineStyle', 'none');
xlabel('traslazione totale sensori')
ylabel('somma angoli di rotazione dei sensori')
zlabel('errore della misura')
labels = string(1:nPos);
text(trasl_tot_sensori, ang_tot_sensori, errore_da_stampare, labels, 'FontSize',8 )

figure(5)
plot(R, costo, 'o', 'LineStyle', 'none');
xlabel('R')
ylabel('costo')
labels = string(1:nPos);
text(R, costo, labels, 'FontSize',8 )

num_rilevazioni_radiate = num_rilevazioni_radiate



%% find position along trajectories
pos_along_trajectories = zeros(nPos,nMag);
stepper_positions = zeros(nPos,nMag); %questa è la posizione esatta dei magneti. Il nome della variabile è stato scelto solo per simiglianza con il main di "Real_data_analysis_2"
for k = 1:nPos
    pos_along_trajectories(k,:) = calculate_pos_along_trajectories(x6Corrected{k}(:,1:3),trajectories);
    stepper_positions(k,:) = calculate_pos_along_trajectories(X{k}(:,1:3),trajectories);
end

%% FIGURE3: pos_along_trajectories
    figure(6)
    for i = 1:nMag
        hold on
        subplot(nMag,1, i);
%         if i == 1
              plot(1:nPos, pos_along_trajectories(:,i),'m', 1:nPos, stepper_positions(1:nPos,i),'k');
%         elseif i == 2
%             plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1:nPos,2),'k');
%         elseif i == 3
%             plot(1:nPos, pos_along_trajectories(:,i),'m',1:nPos, pos_along_trajectories_not_modified(:,i), 'c', 1:nPos, stepper_positions(1:nPos,3),'k');
%         end
        titolo = "Posizioni assunte dal magnete " + i;
        title(titolo);
        legend('Posizioni rilevate', 'Posizioni reali');
    end