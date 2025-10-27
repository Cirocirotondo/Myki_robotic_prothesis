clear all
% first_run = 1;
close all
clc
delete(instrfind());

addpath('Localizer 5DoF', 'Localizer 6DoF');

%% Variabili
variables_5DoF;

%% Inizializzazione
% if first_run
s = create_serials(nCOM, true, 115200);   % serials for board communication
% end
% try
offset = acquire_offset(s, 10);
% catch
%   clear all
%   first_run = 1;
%   delete(instrfind());
%   variables_5DoF;
%   s = create_serials(nCOM, true, 115200);   % serials for board communication
%   offset = acquire_offset(s, 10);
% end

% start_streaming(s);

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
end
Tacq_stp = toc(Tabs);
Tacq = Tacq_stp-Tacq_srt;

%% loc 6 DoF
Tloc_srt = toc(Tabs);
x = localize_magnets(x, acq, nMag, 0.015, sPos, sens2ignore); %old m = 0.0237
Tloc_stp = toc(Tabs);
Tloc_run(count+1) = Tloc_stp - Tloc_srt;
%% loc 5 DoF
Tloc_srt = toc(Tabs);
x5dof = localize_magnets_5DoF(x5dof, acq, nMag, 0.0150, sPos, sens2ignore); %old m = 0.0237
Tloc_stp = toc(Tabs);
Tloc_run_5DoF(count+1) = Tloc_stp - Tloc_srt;

Ttot = Tloc_stp - Tloc_stp_old;

disp(['Fequenza output:', num2str(round(1/Ttot,2)), ' Hz. #iterazione: ', num2str(count), '.  T_loc_6DoF: ',  num2str(round(Tloc_run(count+1)*1000,2)) , 'ms  T_loc_5DoF: ',  num2str(round(Tloc_run_5DoF(count+1)*1000,2)), 'ms'])
Tloc_stp_old = Tloc_stp;
Tloc = Tloc_stp-Tloc_srt;
time = [Tloc_srt, Tloc_stp];

  %% visualizzazione
  if true
  if grafici_sovrapposti
    % 6 DoF
      xVis = vec2mat(x, 6);
      scatter3(xVis(1:nMag,1)*1000,xVis(1:nMag,2)*1000,xVis(1:nMag,3)*1000, 10, 'k', 'filled')
      hold on
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, xVis(1:nMag,4)*5, xVis(1:nMag,5)*5, xVis(1:nMag,6)*5, 'r', 'AutoScale','off')
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, -xVis(1:nMag,4)*5, -xVis(1:nMag,5)*5, -xVis(1:nMag,6)*5, 'b', 'AutoScale','off')
      if(nMag == 1) % scia
        xVisold(2:end,:) = xVisold(1:end-1,:);
        xVisold(1,:) = xVis;
        plot3(xVisold(:,1)*1000, xVisold(:,2)*1000, xVisold(:,3)*1000, '-k');
      end
    % 5 DoF
    xVis_5DoF = vec2mat(x5dof, 5);
    scatter3(xVis_5DoF(1:nMag,1)*1000,xVis_5DoF(1:nMag,2)*1000,xVis_5DoF(1:nMag,3)*1000, 10, 'k', 'filled')
    hold on
    [Rx_vis,Ry_vis,Rz_vis] = sph2cart(xVis_5DoF(1:nMag,5) + pi, xVis_5DoF(1:nMag,4) + pi/2, 5);
    quiver3(xVis_5DoF(1:nMag,1)*1000, xVis_5DoF(1:nMag,2)*1000, xVis_5DoF(1:nMag,3)*1000, Rx_vis, Ry_vis, Rz_vis, 'm', 'AutoScale','off')
    quiver3(xVis_5DoF(1:nMag,1)*1000, xVis_5DoF(1:nMag,2)*1000, xVis_5DoF(1:nMag,3)*1000, -Rx_vis, -Ry_vis, -Rz_vis, 'c', 'AutoScale','off')
    if(nMag == 1) % scia
      xVisold_5DoF(2:end,:) = xVisold_5DoF(1:end-1,:);
      xVisold_5DoF(1,:) = xVis_5DoF;
      plot3(xVisold_5DoF(:,1)*1000, xVisold_5DoF(:,2)*1000, xVisold_5DoF(:,3)*1000, '-r');
    end

      %     plot_board(boardsPose, sPos);
      plot_multiple_boards(sPos, acq);
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
      pause(0.01);
else
    % 6 DoF
    subplot(1,2,1);
      xVis = vec2mat(x, 6);
      scatter3(xVis(1:nMag,1)*1000,xVis(1:nMag,2)*1000,xVis(1:nMag,3)*1000, 10, 'k', 'filled')
      hold on
      title(['6 DoF localizer', newline, 'computation time: ', num2str(round(Tloc_run(count+1)*1000,2)), ' ms']);
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, xVis(1:nMag,4)*5, xVis(1:nMag,5)*5, xVis(1:nMag,6)*5, 'r', 'AutoScale','off')
      quiver3(xVis(1:nMag,1)*1000, xVis(1:nMag,2)*1000, xVis(1:nMag,3)*1000, -xVis(1:nMag,4)*5, -xVis(1:nMag,5)*5, -xVis(1:nMag,6)*5, 'b', 'AutoScale','off')
      if(nMag == 1) % scia
        xVisold(2:end,:) = xVisold(1:end-1,:);
        xVisold(1,:) = xVis;
        plot3(xVisold(:,1)*1000, xVisold(:,2)*1000, xVisold(:,3)*1000, '-k');
      end
      plot_multiple_boards(sPos, acq);
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
    % 5 DoF
    subplot(1,2,2);
    xVis_5DoF = vec2mat(x5dof, 5);
    scatter3(xVis_5DoF(1:nMag,1)*1000,xVis_5DoF(1:nMag,2)*1000,xVis_5DoF(1:nMag,3)*1000, 10, 'k', 'filled')
    hold on
    title(['5 DoF localizer', newline, 'computation time: ', num2str(round(Tloc_run_5DoF(count+1)*1000,2)), ' ms']);
    [Rx_vis,Ry_vis,Rz_vis] = sph2cart(xVis_5DoF(1:nMag,5) + pi, xVis_5DoF(1:nMag,4) + pi/2, 5);
    quiver3(xVis_5DoF(1:nMag,1)*1000, xVis_5DoF(1:nMag,2)*1000, xVis_5DoF(1:nMag,3)*1000, Rx_vis, Ry_vis, Rz_vis, 'm', 'AutoScale','off')
    quiver3(xVis_5DoF(1:nMag,1)*1000, xVis_5DoF(1:nMag,2)*1000, xVis_5DoF(1:nMag,3)*1000, -Rx_vis, -Ry_vis, -Rz_vis, 'c', 'AutoScale','off')
    if(nMag == 1) % scia
      xVisold_5DoF(2:end,:) = xVisold_5DoF(1:end-1,:);
      xVisold_5DoF(1,:) = xVis_5DoF;
      plot3(xVisold_5DoF(:,1)*1000, xVisold_5DoF(:,2)*1000, xVisold_5DoF(:,3)*1000, '-k');
    end
      %     plot_board(boardsPose, sPos);
      plot_multiple_boards(sPos, acq);
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
      pause(0.01);
    end
  end

acquisitions{count+1} = acq;
localizations{count+1} = x;
localizations_5DoF{count+1} = x5dof;

% acquisitions{mod(count,100)+1} = acq;
% localizations{mod(count,100)+1} = x;
count = count +1;

x = are_positions_acceptable(x, bounds, 0.008, sPos);
x5dof = are_positions_acceptable_5DoF(x5dof, bounds, 0.008, sPos);
end
% set_serial(s, 0);

figure
hold on
plot(Tloc_run)
plot(Tloc_run_5DoF)
legend
hold off

% save('static_localization_9MM_marta.mat', 'acquisitions', 'localizations', 'sPos', 'sens2ignore', 'actualPositions')
% save('Disturbs/070--Moving elevator.mat', 'acquisitions', 'localizations', 'sPos', 'sens2ignore', 'actualPositions')
save('DistMeaccanici_5MM_confMokup_5DoF_2.mat', 'acquisitions', 'localizations', 'localizations_5DoF', 'sPos', 'sens2ignore', 'actualPositions', 'bounds')
