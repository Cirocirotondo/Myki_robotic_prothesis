% This script first generates the field on the sensors using the analytical
% model (that we assume comparable to the COMSOL model), then use those
% data to localize the magnets using the 6 and the 5 DoFs dipole model.

clc
close all
clear all

addpath('../Mathworks Fede Thesis');
addpath('../Localizer');
addpath('../Localizer/Localizer 5DoF');
addpath('../Localizer/Localizer 6DoF');

variables_for_generator
clear boardsPose mrg nBoards

%% Magnets parameters
D = 0.004; % Diameter of the magnets
H = 0.002; % Height of the magnets
M = 1.2706/(4*pi*1e-7); % Magnetization of the magnets [A/m]
m = M*((D/2)^2*pi*H);

%% Magnets trajectories generation
% X{1} = [0.0210572820620418,0.0477118865659122,0.0380913456584975,0.0455024437693301,0.945666745950912,-0.321937778481545;0.0293404956897113,0.0242490820138775,0.0622691495745998,0.830581625896749,0.0760889005537881,0.551674398477243;0.0160364326384485,0.0628167118850397,0.0676144317042448,0.216606229521388,0.610712355428865,0.761650943844394;0.0281891678092055,0.0324867215690577,0.0393323790103808,-0.658428464854838,0.538708531648503,-0.525609241355225;0.0297115035491751,0.0357082140882732,0.0630670313821781,0.370279004358944,0.570702940916689,-0.732933565993529]';
X{1} = x';
for i = 1:nMag
  prev_dir{i} = [];
%   prev_dir{i} = [0; 1; 0];
end
for i = 2:nPos
%   [X{i}] = X{i-1};
  [X{i}, prev_dir] = randomly_move_magnets(X{i-1}, dist, alpha, prev_dir);
end

%% Field (B) generation
Tgen = tic;
for i = 1:nPos
  noise = normrnd(0, noise_sd, 3, size(sPos,1));
  B{i} = (ParallelGenerateReadings(D,H,M,X{i},sPos'))*10000 + noise;    % multiplication is for converting from tesla to gauss
end
B_generation_time = toc(Tgen);
disp(['Contemporary computation of the magnetic field done in ', num2str(round(B_generation_time*1000)), ' ms.'])
for i = 1:nPos
  X{i} = X{i}';
end


%% Magnets localization
Tabs = tic;
Tloc_stp_old = 0;
figure('units','normalized','outerposition',[0 0 1 1])
for k = 1:nPos
  pause(0.01)
  %% loc 6 DoF
  Tloc_srt = toc(Tabs);
  if k > 1
    x6{k} = localize_magnets(x6{k-1}, B{k}', nMag, m, sPos);
  else
    x6{1} = localize_magnets(X{1}, B{k}', nMag, m, sPos);     %first localization, starting from ground thruth
  end
  Tloc_run6(k) = toc(Tabs) - Tloc_srt;
  %% loc 5 DoF
  Tloc_srt = toc(Tabs);
  if k > 1
    x5{k} = localize_magnets_5DoF(x5{k-1}, B{k}', nMag, m, sPos);
  else
    x5{1} = localize_magnets_5DoF(from6to5DoFs(X{1}), B{k}', nMag, m, sPos);  %   //
  end
  Tloc_run5(k) = toc(Tabs) - Tloc_srt;
  Tloc_stp = toc(Tabs);
  Ttot = Tloc_stp - Tloc_stp_old;
  Tloc_stp_old = Tloc_stp;
  disp(['Fequenza output:', num2str(round(1/Ttot,2)), ' Hz. #iterazione: ', num2str(k), '.     T_loc_6DoF: ',  num2str(round(Tloc_run6(k)*1000,2)) , 'ms     T_loc_5DoF: ',  num2str(round(Tloc_run5(k)*1000,2)), 'ms'])

  %% Compute error
  X_sort = sortMagnets(X{k}, sort_axis);
  x6_sort = sortMagnets(x6{k}, sort_axis);
  x5_sort = sortMagnets(x5{k}, sort_axis);
  ep6(k,:) = point2pointDist(x6_sort, X_sort);  % position error in the 6 DoFs algorithm
  ep5(k,:) = point2pointDist(x5_sort, X_sort);  % position error in the 5 DoFs algorithm
  eo6(k,:) = vec2vecAngle(x6_sort, X_sort);  % orientation error in the 6 DoFs algorithm
  eo5(k,:) = vec2vecAngle(x5_sort, X_sort);  % orientation error in the 5 DoFs algorithm


  %% visualizzazione
  if plotta_grafici_3D
    if grafici_sovrapposti
      clf
      hold  on
      plot_mags(X{k}, 6, 'r', 'g', 'y');      % original
      plot_mags(x6{k}, 6, 'k', 'r', 'b');      % 6 DoF
      plot_mags(x5{k}, 5, 'k', 'm', 'c');      % 5 DoF
      plot_multiple_boards(sPos, B{k}');
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
      pause(0.01);
    else
      clf
      % 6 DoF
      subplot(1,2,1);
      hold on
      title(['6 DoF localizer', newline, 'computation time: ', num2str(round(Tloc_run6(k)*1000,2)), ' ms']);
      plot_mags(X{k}, 6, 'r', 'g', 'y');      % original
      plot_mags(x6{k}, 6, 'k', 'r', 'b');      % 6 DoF
      plot_multiple_boards(sPos, B{k}');
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
      % 5 DoF
      subplot(1,2,2);
      hold on
      title(['5 DoF localizer', newline, 'computation time: ', num2str(round(Tloc_run5(k)*1000,2)), ' ms']);
      plot_mags(X{k}, 6, 'r', 'g', 'y');      % original
      plot_mags(x5{k}, 5, 'k', 'm', 'c');      % 5 DoF
      plot_multiple_boards(sPos, B{k}');
      axis equal
      if blocco_vista
        axis(bounds*1000)
      end
      hold off
      pause(0.01);
    end
  end

  [x6{k}, fails6(k)] = are_positions_acceptable(x6{k}, bounds, min_dist, sPos);
  [x5{k}, fails5(k)] = are_positions_acceptable_5DoF(x5{k}, bounds, min_dist, sPos);
end

if plot_computation_times
  figure('units','normalized','outerposition',[0 0 1 1])
  hold on
  plot(Tloc_run6)
  plot(Tloc_run5)
  title('Computation time');
  legend('6 DoFs C.T.', '5 DoFs C.T.');
  hold off
end

if plot_fails
  figure('units','normalized','outerposition',[0 0 1 1])
  hold on
  plot(fails6)
  plot(fails5)
  N_fails6 = sum(fails6);
  N_failed_iterations6 = size(find(fails6),2);
  N_fails5 = sum(fails5);
  N_failed_iterations5 = size(find(fails5),2);
  title(['Fails', newline, num2str(N_fails6), ' fails leading to ', num2str(N_failed_iterations6), ' missed iterations in the 6 DoFs localizer', newline, num2str(N_fails5), ' fails leading to ', num2str(N_failed_iterations5), ' missed iterations in the 5 DoFs localizer']);
  legend('6 DoFs fails', '5 DoFs fails');
  hold off
end

if plot_errors
  figure('units','normalized','outerposition',[0 0 1 1])
  subplot(1,2,1);
  N_unacceptable_dist6 = size(find(ep6 > max_acceptable_dist),1);
  N_unacceptable_dist5 = size(find(ep5 > max_acceptable_dist),1);
  N_unacceptable_ang6 = size(find(eo6 > max_acceptable_ang),1);
  N_unacceptable_ang5 = size(find(eo5 > max_acceptable_ang),1);
  hold on
  title(['Position error (mm)', newline, '\color{red}5 DoFs  \color{black}vs \color{blue}6 DoFs', ...
  newline, '\color{red}', num2str(N_unacceptable_dist5), ' \color{black}vs \color{blue}', num2str(N_unacceptable_dist6), ...
  ' \color{black}errors above \color{green}threshold \color{black}(', num2str(max_acceptable_dist*1000), ' mm)'])
  plot(ep5*1000, 'r', 'DisplayName', '5 DoFs');
  plot(ep6*1000, 'b', 'DisplayName', '6 DoFs');
  xlabel('# iteration')
  line([0, size(ep5,1)],[max_acceptable_dist ,max_acceptable_dist]*1000, 'Color', 'green')
  ylim([0, max_acceptable_dist*2*1000])
  hold off
  subplot(1,2,2);
  hold on
  title(['Orientation error (deg)', newline, '\color{red}5 DoFs  \color{black}vs \color{blue}6 DoFs', ...
  newline, '\color{red}', num2str(N_unacceptable_ang5), ' \color{black}vs \color{blue}', num2str(N_unacceptable_ang6), ...
  ' \color{black}errors above \color{green}threshold \color{black}(', num2str(max_acceptable_ang), ' deg)'])
  plot(eo5, 'r', 'DisplayName', '5 DoFs');
  plot(eo6, 'b', 'DisplayName', '6 DoFs');
  xlabel('# iteration')
  line([0, size(ep5,1)],[max_acceptable_ang ,max_acceptable_ang], 'Color', 'green')
  ylim([0, max_acceptable_ang*2])
  hold off
end


filename = ['Savings/N', num2str(size(dir('Savings'),1)-1), '_5vs6DoFs_', num2str(nMag), 'Magnets_', num2str(nPos), 'iterations.mat'];
save(filename, 'x5', 'x6', 'X', 'B', 'nMag', 'nPos', 'dist', 'alpha', 'min_dist', 'sPos', 'bounds', 'Tloc_run6', 'Tloc_run5', 'ep6', 'ep5', 'eo6', 'eo5');
