function [acq] = interpret_data(data)
%interpret_data Interpreta i dati inviati dalla MagMap2 e ritorna un
%vettore di 32 righe e 3 colonne, contenete le componenti x, y e z per ogni
%sensore.

nSens = 20;
acq = zeros(nSens,3);
temp = uint8(zeros(1, 2));

%% First consistency check
to_compare = ['M', 'A', 'G', '3', 'X'];
try
  differences = sum(char(data(1:4)) - to_compare(1:4)');
  differences = differences + sum(char(data(133)) - to_compare(5)');
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
  for i = 1:3
    temp(2:-1:1) = uint8(data(4+(sens-1)*7+2*i-1 : 28+(sens-1)*7+2*i));
    acq(sens, i) = typecast(temp, 'int16');
  end
end
acq(:,3) = -acq(:,3);   % per addrizzare l'asse z
end
