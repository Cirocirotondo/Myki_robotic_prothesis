function [acq] = interpret_data(data)
%interpret_data Interpreta i dati inviati dalla MagMap2 e ritorna un
%vettore di 32 righe e 3 colonne, contenete le componenti x, y e z per ogni
%sensore.

nSens = 32;
acq = zeros(nSens,3);
temp = uint8(zeros(1, 2));

%% First consistency check
to_compare = ['<', 's', '0', '0', '1', '0', '0', '0', '0', '0', '<', 'M', 'A', 'G', 'M', 'A', 'P', ':', '0', '0', ':', '3', '2', ':', '*'];
try
  differences = sum(char(data(1:10)) - to_compare(1:10)');
  differences = differences + sum(char(data(14:27)) - to_compare(11:24)');
  differences = differences + sum(char(data(252)) - to_compare(25)');
  if max(differences)
    error('Unrecognized data string.');
    return
  end
catch
  error('Unrecognized data string.');
  return
end

%% Acqusitions extraction
for sens = 1:nSens
  if int2str(data(28+(sens-1)*7)) ~= int2str(sens-1)
    error('Unrecognized data string.');
    return
  end
  for i = 1:3
    temp(2:-1:1) = uint8(data(28+(sens-1)*7+2*i-1 : 28+(sens-1)*7+2*i));
    acq(sens, i) = typecast(temp, 'int16');
  end
end
acq(:,3) = -acq(:,3);   % per addrizzare l'asse z
end
