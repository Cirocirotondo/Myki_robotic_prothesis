% CON QUESTO CODICE SI LEGGE IL LOCALIZZATORE EMBEDDED
clear all
close all
clc
% addpath("..");
addpath("functions_VALERIO");

%% Variabili
nMag = 0;
N_acquisitions_train = 200; % se 0 va a dritto
plot_graph = true;
salvalo = true;
fmo = [2 3 4 1 0]; %finger motors order
mov_dir = [0 0 0 0 0]; % 1 inverts the direction of the movement

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
    error("Unable to connect to hand")
end

flush(s);
write(s, "A0", "char"); % stop acquisitions streaming
write(s, "B0", "char"); % stop boards position streaming
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

close all

N_filt = 30;
for ii = 1:6
  X_filt{ii} = medfilt1(X{ii}, N_filt);
%   X_filt{ii}(1:5,:) = []; % rimuovo le prime acquisizioni che a volte scazzano
  X_filt_diff{ii} = abs(medfilt1(diff(X_filt{ii}), N_filt));
  f_max(ii, 1:nMag) = max(X_filt_diff{ii});
end
leading_dim = mod((find(max(f_max(1:3, :)) == f_max(1:3, :)))-1,3)+1; % dimensione sulla quale si ha il movimento

for ii = 1:nMag
  temp = find(abs(diff([0; (X_filt_diff{leading_dim(ii)}(:,ii) > f_max(leading_dim(ii),ii)*0.0001); 0])));
  intervallo_corretto = 1;
  if size(temp,1) > 2
    temp1 = find(X_filt_diff{leading_dim(ii)}(:,ii) == f_max(leading_dim(ii),ii));
    while((temp((intervallo_corretto-1)*2+1) > temp1(1) ) || (temp((intervallo_corretto-1)*2+2) < temp1(1) ))
      intervallo_corretto = intervallo_corretto + 1;
    end
    warning("Sono stati identificati %i movimenti per il magnete #%i, ne e' stato preso numero %i.", size(temp,1)/2, ii, intervallo_corretto);
  end
  bounds(1:2, ii) = temp((intervallo_corretto-1)*2+1:(intervallo_corretto-1)*2+2);
end
clear temp temp1 i ii jj intervallo_corretto N_filt

for m = 1:nMag
  n = bounds(2,m)-bounds(1,m)+1;
  Xr{m}(1:n, 1) = ones(n, 1);
  for v = 1:6
    Xr{m}(1:n, v+1) = X{v}(bounds(1,m):bounds(2,m),m);
  end
  y{m} = linspace(0,1, n)';

  b(1:7, m) = regress(y{m},Xr{m});
end
clear m n v

ff = 5; % FIR filter lenght
perc = zeros(ff, nMag);
fir_coeff = logspace(1,0,ff);
fir_coeff = fir_coeff/sum(fir_coeff);
first_iter = true;
while (1)
  pause(0.01)
  try
    [localizations{count}, t_loc(count), t_iter(count), t_abs(count), nMag] = get_data3(s, nMag);
    perc = [zeros(1, nMag); perc];
    for m = 1:nMag
      perc(1,m) = [1 localizations{count}(m,:)] * b(:,m);
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
      comando = [68, fmo(pp), round(perc_filt(pp)*255)];
%       comando = [68, fmo(pp), round(perc(1, pp)*255)];
      write(s_hand, comando, "uint8");
    end
    first_iter = false;
    count = count +1;
  end
  if size(perc,1) > 300
      perc(end,:) = [];
  end
  plot(perc)
  ylim([-0.1 1.1])
  xlim([0 300])
end


if salvalo
  filename = ['Savings/N', num2str(size(dir('Savings'),1)-1), '_', num2str(nMag), 'magnets_', num2str(N_acquisitions_train), 'iterations.mat'];
  save(filename);
end

write(s_hand, 70, "uint8"); %fast calibration
