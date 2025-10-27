clear all
close all
clc
delete(instrfind)
pause(3)
addpath("Cyberglove\UtilitiesNAS");

N_DOF = 5;
load_calibration = true;
debug_channels = false;

% while(1)
%   for m = 1:5
%     moveServo(mot_num(m), 0, servo_port);
%     pause(1)
% moveServo(mot_num(m), 1, servo_port);
%   pause(1)
%
%   end
%
% end

dof_name = {'Index finger';'Middle finger';'Ring and pinky fingers';'Thumb Flexion';'Thumb abduction'};
channels{1} = [5, 6];
channels{2} = [7, 8];
channels{3} = [10, 11, 13, 14];
channels{4} = [2];
channels{5} = [4];
channels = channels';
T = table(dof_name, channels);
clear dof_name channels

glove = Cyberglove('COM6');

if debug_channels
  StartAcquisition(glove)
  last_pack = 0;
  if glove.pack > 0
    data = (glove.raw_acq)';
  end
  figure
  count = 1;
  while(count < 1000)
    if glove.pack > last_pack
      last_pack = glove.pack;
      data(2:end+1,:) = data(1:end,:);
      data(1,1:19) = (glove.raw_acq)';
      if size(data,1) > 100
        data(end,:) = [];
      end
      for ii = 1:N_DOF
        subplot(2,3,ii)
        plot(data(:,T.channels{ii}))
        legend
        ylim([0 255])
        title(T.dof_name{ii})
      end
  %     for ii = 1:19
  %       subplot(4,5,ii)
  %       plot(data(:,ii))
  %       ylim([0 255])
  %       title(num2str(ii))
  %     end
      count = count +1;
    end
    pause(0.001)
  end
  StopAcquisition(glove);
end

if ~load_calibration
  for d = 1:N_DOF
    b{d} = get_calib_data2(glove, 150, T, d, true);
  end
  close
  delete(glove)
  clear d load_calibration glove
  filename = ['Savings/Calibration_data/N', num2str(size(dir('Savings/Calibration_data'),1)-1), '_calibration.mat'];
  save(filename);
  clear
  filename = ['Savings/Calibration_data/N', num2str(size(dir('Savings/Calibration_data'),1)-2), '_calibration.mat'];
  load(filename);
  glove = Cyberglove('COM6');
else
  filename = ['Savings/Calibration_data/N', num2str(size(dir('Savings/Calibration_data'),1)-2), '_calibration.mat'];
  load(filename);
end



n_acq = inf;
supress_plots = true;
move_motors = true;
mot_num = [0 1 3 2 4];

if move_motors
  servo_port = serialport('COM8', 9600);
  for m = 1:5
    moveServo(mot_num(m), 0, servo_port);       %% 
  end
end

% fprintf(['All the magnets will move on trajectory in: \n'])
% pause(0.2)
% fprintf('3 \n')
% pause(1)
% fprintf('2 \n')
% pause(1)
% fprintf('1 \n')
% pause(1)
% if move_motors
  for m = 1:5
    for perc = 0:0.05:1
      moveServo(mot_num(m), perc, servo_port);
      pause(0.01)
    end
  end
% end

StartAcquisition(glove);
pause(2)
data = (glove.raw_acq)';
count = 0;
last_pack = 1;
ff = 1; % FIR filter lenght
perc = zeros(ff, N_DOF);
fir_coeff = logspace(1,0,ff);
fir_coeff = fir_coeff/sum(fir_coeff);
try
  while(count < n_acq)
    if glove.pack > last_pack
      last_pack = glove.pack;
      data(2:end+1,:) = data(1:end,:);
      data(1,1:19) = (glove.raw_acq)';
      perc = [zeros(1, N_DOF); perc];
      for d = 1:N_DOF
        perc(1,d) = [1 data(1, T.channels{d})] * b{d};
      end
      perc(find(perc > 1)) = 1;
      perc(find(perc < 0)) = 0;
      perc_filt = fir_coeff*perc(1:ff, :);
      fprintf('\n')
      if move_motors
        for m = 1:5%:N_DOF
          moveServo(mot_num(m), perc_filt(m), servo_port);
          fprintf(['Mot-' num2str(mot_num(m)) ': ' num2str(perc_filt(m)) '\n'])
        end
      end
      count = count +1;
      if size(perc,1) > 300
        perc(end,:) = [];
      end
      if ~supress_plots
        dof_name = categorical({T.dof_name{1}, T.dof_name{2}, T.dof_name{3}, T.dof_name{4}, T.dof_name{5}});
        subplot(2,1,1)
        plot(perc)
        ylim([-0.1 1.1])
        xlim([0 300])
        legend(dof_name)
        subplot(2,1,2)
        bar(dof_name, perc(1,:))
        ylim([0 1])
      end
    end
    pause(0.01)
  end

catch
  delete(glove);
end
