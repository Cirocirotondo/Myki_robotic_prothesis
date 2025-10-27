clear all
first_run = 1;
close all
clc

addpath('..');

if first_run
  clear all
  first_run = 1;
  delete(instrfind());
end

%% Variabili
variables;

%% Inizializzazione
if first_run
  s = create_serials(nCOM, true, 115200);   % serials for board communication
  p = create_serials(40, true, 921600);   % serial for Processing communication
end
try
    offset = acquire_offset(s, 10);
catch
  clear all
  first_run = 1;
  delete(instrfind());
  variables;
  s = create_serials(nCOM, true, 115200);   % serials for board communication
%   p = create_serials(40, true, 921600);   % serial for Processing communication
  offset = acquire_offset(s, 10);
end

% start_streaming(s);

useProcessing = 0;

figure('units','normalized','outerposition',[0 0 1 1])
Tabs = tic;
Tloc_stp_old = 0;
count = 0;
while (count < 300)
    pause(0.01)
Tacq_srt = toc(Tabs);
try
  acq = (get_data(s, offset, nCOM));
  for b = 1:nBoards
    acq(32*(b-1)+1:32*b,:) = rotateMat(acq(32*(b-1)+1:32*b,:), boardsPose(b, 4), boardsPose(b, 5), boardsPose(b, 6));
  end
%   acq = removeGMF(acq, [8,32]);
catch
  delete_serials(s);
  s = create_serials(nCOM, true, 115200);   % serials for board communication
  if useProcessing
    delete_serials(p);
    p = create_serials(40, true, 921600);   % serial for Processing communication
  end
end
Tacq_stp = toc(Tabs);
Tacq = Tacq_stp-Tacq_srt;
Tloc_srt = toc(Tabs);
% x = localize_magnets(x, acq, nMag, 0.0237, sPos, sens2ignore);
x = localize_magnets(x, acq, nMag, 0.015, sPos, sens2ignore);
Tloc_stp = toc(Tabs);
Ttot = Tloc_stp - Tloc_stp_old;
disp(['Fequenza output:', num2str(round(1/Ttot,2)), ' Hz. #iterazione: ', num2str(count), '.'])
Tloc_stp_old = Tloc_stp;
Tloc = Tloc_stp-Tloc_srt;
time = [Tloc_srt, Tloc_stp];
if useProcessing
    Tsend = send_to_Processing(p, x, acq, time, sPos, boardsPose, sens2ignore);
else
    xVis = vec2mat(x, 6);
    scatter3(xVis(1:nMag,1)*1000,xVis(1:nMag,2)*1000,xVis(1:nMag,3)*1000, 10, 'k', 'filled')
    hold on
    quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, xVis(1:nMag,4)*5, xVis(1:nMag,5)*5, xVis(1:nMag,6)*5, 'r', 'AutoScale','off')
    quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, -xVis(1:nMag,4)*5, -xVis(1:nMag,5)*5, -xVis(1:nMag,6)*5, 'b', 'AutoScale','off')
%     plot_board(boardsPose, sPos);
    plot_multiple_boards(sPos, acq);
    if(nMag == 1)
      xVisold(2:end,:) = xVisold(1:end-1,:);
      xVisold(1,:) = xVis;
      plot3(xVisold(:,1)*1000, xVisold(:,2)*1000, xVisold(:,3)*1000, '-k');
    end
    axis equal
    axis(bounds*1000)
    hold off
    pause(0.01);
end

acquisitions{count+1} = acq;
localizations{count+1} = x;
% acquisitions{mod(count,100)+1} = acq;
% localizations{mod(count,100)+1} = x;
count = count +1;

x = are_positions_acceptable(x, bounds, 0.008, sPos);
end
% set_serial(s, 0);

% save('static_localization_9MM_marta.mat', 'acquisitions', 'localizations', 'sPos', 'sens2ignore', 'actualPositions')
% save('Disturbs/070--Moving elevator.mat', 'acquisitions', 'localizations', 'sPos', 'sens2ignore', 'actualPositions')
save('DistMeaccanici_4MM_confMokup_8.mat', 'acquisitions', 'localizations', 'sPos', 'sens2ignore', 'actualPositions', 'bounds')
