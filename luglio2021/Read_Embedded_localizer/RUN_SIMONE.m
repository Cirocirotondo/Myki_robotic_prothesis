%% RUN
% Questo script prende in input la matrice "trajectories", generata dallo
% script "SETUP". 
% Dopodiché, prende nuovi dati e li analizza: se i magneti si trovano sulle
% loro traiettorie (a meno di errori di misurazione), allora nessun 
% problema, viene calcolata subito la posizione lungo la traiettoria.
% Se invece si trovano fuori dalla traiettoria (a causa di una 
% rototraslazione della protesi), viene eseguito l'algoritmo di 
% annullamento degli errori dovuti alla rototraslazione.
% Così, possono essere calcolate le posizioni corrette da mandare in
% output.

clc
close all
clear

addpath('functions_RUN');
addpath("functions_VALERIO");


variables
load('trajectories.mat')
sys.trajectories = trajectories;
clear trajectories


%% Connessione con la board
clear s
pause(1)
try
    s = serialport('COM9', 921600);
    fprintf("Connected to COM9\n")
catch
    error("Unable to connect to COM9")
end

flush(s);
write(s, "A0", "char"); % stop acquisitions streaming
write(s, "B0", "char"); % stop boards position streaming
for i = 1:15            % azzera il numero di magneti
    pause(0.1)
    write(s, "M-", "char"); % remove a magnet
end
pause(0.2)
for i = 1:sys.nMag
  pause(0.1)
  write(s, "M+", "char"); % add a magnet
end
flush(s)
pause(1)
flush(s)
disp('Fine setup')


%% riordino traiettorie 
[sys.X,~,~,~,sys.nMag] = get_data3(s, sys.nMag);
sys.trajectories = reorder_trajectories(sys.X,sys);

%% Inizio Run

%-----------
num = 1;
nPos = 30;
positions = cell(1,nPos);
positions_corrected = cell(1,nPos);
num_correzioni_successo = 0;
num_correzioni_fallite = 0;
failures = zeros(1,nPos);
%--------------

tic
while(toc < 30 && num <= nPos)     % 10 sec di rilevazioni
    try
        [sys.X,~,~,~,sys.nMag] = get_data3(s, sys.nMag);
        positions{num} = sys.X; %%%
    catch
        warning("Missed data")
        flush(s)
        continue 
    end
    
    sys.prev_rotTransl = sys.rotTransl;
    if everyoneInTrajectory(sys.X, sys) == 1
        disp("Rilevazione n." + num +": Everyone in Trajectory!!")
        sys.rotTransl = zeros(1,6);
        sys.XCorrected = sys.X;
        positions_corrected{num} = sys.XCorrected; %%%
    else
        % CORREZIONE ERRORI
        disp("Rilevazione n." + num + ": Starting correction")
        sys.rotTransl = findRototranslation(sys);
        sys.XCorrected = rotoTrasla(sys.rotTransl, sys);
        positions_corrected{num} = sys.XCorrected; %%%
        if everyoneInTrajectory(sys.XCorrected, sys) == 1
            disp("Correzione avvenuta con successo!")
            num_correzioni_successo = num_correzioni_successo+1;
        else
            disp("Correzione fallita...")
            num_correzioni_fallite = num_correzioni_fallite+1;
            failures(num) = num;
        end
    end
    
    % ELIMINA ERRORI EVIDENTEMENTE ERRATI (Serve davvero? Nel caso, aggiungere questa parte)
    
    %------------------------------------------------------
    
    if enablePlot_in_run
       plotFunction(sys) 
       pause(0.5)
    end
     
     num = num+1;            %%%
end
num = num-1;
disp("Num rilevazioni totali = " + num)
disp("Numero correzioni = " + (num_correzioni_fallite + num_correzioni_successo))
disp("Numero successi = " + num_correzioni_successo + "; Numero fallimenti = " + num_correzioni_fallite)
disp(failures)


disp("Press a key to continue and plot the results")
pause()

%% plot
figure(1)
for i = 1:4
    subplot(2,2,i)
    hold on
    plot3(sys.trajectories(i,1:2), sys.trajectories(i,3:4), sys.trajectories(i,5:6), 'r-','LineWidth', 3)
    plot3(positions{1}(i,1),positions{1}(i,2),positions{1}(i,3),'o')
end

figure(2)
for i = 1: num
    disp("numero rilevazione = " + i)
    sys.X = positions{i};
    sys.XCorrected =  positions_corrected{i};
    plotFunction(sys); 
    pause(0.2)
end