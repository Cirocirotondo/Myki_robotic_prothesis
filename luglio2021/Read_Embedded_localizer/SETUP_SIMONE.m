%% CODICE PER IL SETUP DELLE TRAIETTORIE, OTTENUTE DAL LOCALIZZATORE EMBEDDED
% Lo script apre il collegamento con la board del mockup e quella dei motori. 
% Poi, fa muovere i magneti lungo le traiettorie e nel frattempo legge le
% posizioni.
% Quindi, chiama la funzione "setup_trajectories" per ottenere le
% traiettorie. Il risultato viene salvato nel file "trajectories.mat", in
% modo che poi possa essere utilizzato dal programma di RUN.

% a differenza del codice di Valerio, questo è più brutto e
% sfigatino. Mi serve per fare le prove della parte di codice che poi
% andranno aggiunte al programma principale


clear 
close all
clc
addpath("functions_SETUP");
addpath("functions_VALERIO");
addpath("../Controllo_mockup");


nMag = 4;
num = 100;      % numero di frazionamenti del movimento

disp("ports: "); disp(serialportlist);

%% Connessione alla board del mockup
clear s
pause(1)
try
    s = serialport('COM9', 921600);
    fprintf("Connected to COM9 (mockup)\n")
catch
    error("Unable to connect to COM9 (mockup)")
end 

%--------------------------------------------------------------------------
flush(s);
write(s, "A0", "char"); % stop acquisitions streaming
write(s, "B0", "char"); % stop boards position streaming
for i = 1:nMag
    pause(0.1)
    write(s, "M-", "char"); % remove a magnet
end
pause(0.2)
for i = 1:nMag
  pause(0.1)
  write(s, "M+", "char"); % add a magnet
end
flush(s)
pause(1)
flush(s)

%--------------------------------------------------------------------------

%% Connessione alla board dei servo

clear servo_port
pause(1)
try
    servo_port = serialport('COM8', 9600);
    fprintf("Connected to COM8 (servo)\n")
catch
    error("Unable to connect to COM8 (servo)")
end

mot_num = [0,5,6,7];    % questi sono i 4 servo relativi ai 4 magneti che vengono mossi


% tutti i motori in posizione di start
disp("Bringing the magnets to position 0")

for i = 1:length(mot_num)
        moveServo(mot_num(i), 0, servo_port);
end


%% Starting the SETUP
% disp("press a key to start") 
% pause()

fprintf(['Calibration starts in: \n'])
pause(0.2)
fprintf('3 \n')
pause(1)
fprintf('2 \n')
pause(1)
fprintf('1 \n')
pause(1)

localizations = cell(1,num);

for i = 1:num
    for m = 1:nMag
        moveServo(mot_num(m), i/num, servo_port);
    end
    try
        [localizations{i},~, ~,~, nMag] = get_data3(s, nMag);
        disp("localizations"); disp(localizations{i});
    catch
        warning("Missed data")
        localizations{i} = localizations{i-1};  %nota: in media un 2% dei lavlori viene perso. Riempio tali celle con le posizioni precedenti giusto per non fare andare in errore la funzione "setup_trajectories"
        flush(s)
    end
   
end


%% FIND TRAJECTORIES

val_start = 1;             %[val_start, val_end] = intervallo preso in considerazione per la fase di setup
val_end = size(localizations,2);

trajectories = setup_trajectories(localizations, val_start,val_end);
disp("trajecotires: "); disp(trajectories);
save('trajectories.mat','trajectories')

