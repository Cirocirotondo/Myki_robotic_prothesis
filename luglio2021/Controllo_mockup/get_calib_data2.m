function [b] = get_calib_data2(glove, n_acq, T, dof, plottare)
  if nargin < 3
    plottare = false;
  end
  StartAcquisition(glove)
  last_pack = 0;
  if glove.pack > 0
    data = (glove.raw_acq)';
  end
  fprintf(['Prepare to calibrate ' T.dof_name{dof} '.\n'])
  fprintf(['Please move the ' T.dof_name{dof} ' trying to assume all the possible configurations with the other fingers. \nReady in: \n'])
  pause(0.2)
  fprintf('3 \n')
  pause(1)
  fprintf('2 \n')
  pause(1)
  fprintf('1 \n')
  pause(0.5)
  fprintf('0')
  for i = 1:n_acq-4
    fprintf('-')
  end
  fprintf('100 \n')
  pause(0.5)

  count = 1;
  if (glove.pack > 10)  %scarto le prime
    while(count < n_acq)
      if glove.pack > last_pack
        last_pack = glove.pack;
        data(2:end+1,:) = data(1:end,:);
        data(1,1:19) = (glove.raw_acq)';
        if plottare
          plot(data)
        end
        count = count +1;
        fprintf("|")
      end
      pause(0.001)
    end
  end

  StopAcquisition(glove);

  %% REGRESSORE
  Xr = [ones(n_acq, 1) data(:, T.channels{dof})];
  %   y = linspace(0,1, n_acq)';
  if dof == 2
    data(:, T.channels{dof}(1)) = -data(:, T.channels{dof}(1)); % perchè i canali 7 ed 8 sono discordi
  end
  if size(T.channels{dof},2) > 1
    y = (mean(data(:, T.channels{dof})')'-min(mean(data(:, T.channels{dof})')'))/(max(mean(data(:, T.channels{dof})')') - min(mean(data(:, T.channels{dof})')'));
  else
    y = (data(:, T.channels{dof})-min(data(:, T.channels{dof})))/(max(data(:, T.channels{dof})) - min(data(:, T.channels{dof})));
  end
  b = regress(y,Xr);

end
