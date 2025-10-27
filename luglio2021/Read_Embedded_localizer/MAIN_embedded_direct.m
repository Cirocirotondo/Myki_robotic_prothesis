% CON QUESTO CODICE SI LEGGE IL LOCALIZZATORE EMBEDDED

% PARTI MODIFICATE: "SETUP TRAIETTORIE" E "CORREZIONE MECHANICAL DISTURBANCES"
% aggiunto il path "function_SETUP"

clear all
close all
clc
% addpath("..");
addpath("functions_SETUP");

%% Variabili
nMag = 1;
N_acquisitions_train = 20; % se 0 va a dritto
plot_graph = true;
salvalo = true;
fmo = [0 0 0 0 0]; %finger motors order
motorder = [2 3 4 1 0];
mov_dir = [0 0 0 0 0]; % 1 inverts the direction of the movement
dof_name = {'Index finger';'Middle finger';'Ring and pinky fingers';'Thumb Flexion';'Thumb abduction'}; %dof = degrees of freedom
y_num = 2;

%% Inizializzazione
clear s
pause(1)
try
    s = serialport('COM9', 921600);
catch
    s = serialport('COM14', 921600);
end

try
    s_hand = serialport('COM10', 115200);
    write(s_hand, 70, "uint8"); %fast calibration
catch
%     error("Unable to connect to hand")
    warning("Hand not connected")
end

flush(s);
write(s, "A0", "char"); % stop acquisitions streaming
write(s, "B0", "char"); % stop boards position streaming
for i = 1:nMag
  pause(0.1)
  write(s, "M-", "char"); % add a magnet
end
pause(3)
for i = 1:nMag
  pause(0.1)
  write(s, "M+", "char"); % add a magnet
end

pause(1)
% if plot_graph
% %   figure('units','normalized','outerposition',[0 0 1 1])
% end

flush(s);
pause(1)
flush(s);

count = 1;

 %% qui inizia la calibrazione del guanto, ignorala
fprintf(['Calibration starts in: \n'])
pause(0.2)
fprintf('3 \n')
pause(1)
fprintf('2 \n')
pause(1)
fprintf('1 \n')
pause(1)
while ((count <= N_acquisitions_train) || (N_acquisitions_train == 0))
  pause(0.01)
  try
    [localizations{count}, t_loc(count), t_iter(count), t_abs(count), nMag] = get_data3(s, nMag);
    for ii = 1:6
      X{ii}(count, 1:nMag) = localizations{count}(:,ii)';
    end

  %% visualizzazione
  if plot_graph
      xVis = localizations{count};
      scatter3(xVis(1:nMag,1)*1000,xVis(1:nMag,2)*1000,xVis(1:nMag,3)*1000, 10, 'k', 'filled')
      hold on
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, xVis(1:nMag,4)*5, xVis(1:nMag,5)*5, xVis(1:nMag,6)*5, 'r', 'AutoScale','off')
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, -xVis(1:nMag,4)*5, -xVis(1:nMag,5)*5, -xVis(1:nMag,6)*5, 'b', 'AutoScale','off')
    axis equal
    hold off
    pause(0.01);
  end
  count = count +1;
  catch
  warning("I missed one...")
  flush(s);
  end
end

y_bounds(1,1:nMag) = min(X{y_num});
y_bounds(2,1:nMag) = max(X{y_num});
y_bounds = y_bounds';
pos_ref = localizations{N_acquisitions_train}(:,1:3);

fprintf(['Calibration ended. \n'])
write(s_hand, 70, "uint8"); %fast calibration

%% qui collega ogni DoF del guanto ad un movimento della mano, ignora 
% Inserisce a fmo (finger motor order) i motori relativi a ciascun dito

for nn = 1:nMag
  clear localizations
  fprintf(['Move ' dof_name{nn} '.\n'])
  pause(1)
  count = 1;
  while (count < 100)
    pause(0.01)
    try
      [localizations{count}, t_loc(count), t_iter(count), t_abs(count), nMag] = get_data3(s, nMag);
      for ii = 1:6
        temp{ii}(count, 1:nMag) = localizations{count}(:,ii)';
      end
  %% visualizzazione
  if plot_graph
      xVis = localizations{count};
      scatter3(xVis(1:nMag,1)*1000,xVis(1:nMag,2)*1000,xVis(1:nMag,3)*1000, 10, 'k', 'filled')
      hold on
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, xVis(1:nMag,4)*5, xVis(1:nMag,5)*5, xVis(1:nMag,6)*5, 'r', 'AutoScale','off')
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, -xVis(1:nMag,4)*5, -xVis(1:nMag,5)*5, -xVis(1:nMag,6)*5, 'b', 'AutoScale','off')
    axis equal
    hold off
    pause(0.01);
  end
    count = count +1;
    catch
    warning("I missed one...")
    flush(s);
    end
  end
  absdiff = max(temp{y_num})-min(temp{y_num});
  motN = find(absdiff==max(absdiff));
  fprintf([dof_name{nn}  'is on magnet' num2str(motN) '.\n'])
  pause(1)
  fmo(motN) = motorder(nn);
end

fmo
close all

% keyboard

%% SETUP TRAIETTORIE  ------------------------------------------------------------------------------------------------------------------------------
% Nota: questa parte si dovrà inserire nella corretta fase di setup: la
% cell "localizations" deve contenere sia le rilevazioni a mano totalmente
% chiusa che le rilevazioni a mano totalmente aperta (Ossia: devono essere
% presenti le rilevazioni alle loro massime escursioni)

localizations = cell(1,100);
for count = 1:100
    try
        [localizations{count}, t_loc(count), t_iter(count), t_abs(count), nMag] = get_data3(s, nMag);
    catch
        warning("Missed localizations n."+count)
    end
end

trajectories = setup_trajectories(localizations, 1, 100);


% ----------------------------------------------------------------------------------------------------------------------------------------------------------



%% Fase di RUN
ff = 5; % FIR filter lenght -> filtro per eliminare le fluttuazioni nelle rilevazioni dei sensori -> media pesata degli ultimw 5 rilevazioni -> il peso di ciascuna misurazione cala in modo logaritmico
perc = zeros(ff, nMag); 
fir_coeff = logspace(1,0,ff);
fir_coeff = fir_coeff/sum(fir_coeff);
first_iter = true;
dist_max = [0 0 0 0 0];
count= 1;
while (1)
  pause(0.01)
  try
    [localizations{count}, t_loc(count), t_iter(count), t_abs(count), nMag] = get_data3(s, nMag);

    % QUA INFILI TUTTE LE CORREZIONI CHE RITIENI NECESSARIE SU LOCALIZATIONS
    

    perc = [zeros(1, nMag); perc];
    for m = 1:nMag
      % perc(1,m) = (localizations{count}(m,2)-y_bounds(m,1))/(y_bounds(m,2)-y_bounds(m,1));
      tempdist = pdist([localizations{count}(m,1:3); pos_ref(m,1:3)]);
      if (dist_max(m) < tempdist)
        dist_max(m) = tempdist;
      end
      perc(1,m) = tempdist/dist_max(m);
    end
    perc(find(perc > 1)) = 1;
    perc(find(perc < 0)) = 0;

    % perc_filt = mean(perc(1:ff, :));
    perc_filt = fir_coeff*perc(1:ff, :);


    for pp = 1:min([5, nMag])
      if(first_iter && (perc(pp) > 0.5))
        mov_dir(pp) = 1;
      end
      if(mov_dir(pp) ~= 0)
        perc_filt(pp)= 1-perc_filt(pp);
        perc(pp)= 1-perc(pp);
      end
      perc_filt
      comando = [68, fmo(pp), round(perc_filt(pp)*255)];  %questo è il comando da mandare alla scheda di controllo dei motori della mano
%       comando = [68, fmo(pp), round(perc(1, pp)*255)];
      write(s_hand, comando, "uint8");    % qui lo manda
    end
    first_iter = false;
    count = count +1;
  if size(perc,1) > 300
      perc(end,:) = [];
  end
  subplot(1,2,1)
  plot(perc)
  ylim([-0.1 1.1])
  xlim([0 300])
  subplot(1,2,2)
  %% visualizzazione
  if plot_graph
      xVis = localizations{count-1};
      scatter3(xVis(1:nMag,1)*1000,xVis(1:nMag,2)*1000,xVis(1:nMag,3)*1000, 10, 'k', 'filled')
      hold on
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, xVis(1:nMag,4)*5, xVis(1:nMag,5)*5, xVis(1:nMag,6)*5, 'r', 'AutoScale','off')
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, -xVis(1:nMag,4)*5, -xVis(1:nMag,5)*5, -xVis(1:nMag,6)*5, 'b', 'AutoScale','off')
    axis equal
    hold off
    pause(0.01);
  end
  end
end


if salvalo
  filename = ['Savings/N', num2str(size(dir('Savings'),1)-1), '_', num2str(nMag), 'magnets_', num2str(N_acquisitions_train), 'iterations.mat'];
  save(filename);
end

write(s_hand, 70, "uint8"); %fast calibration
