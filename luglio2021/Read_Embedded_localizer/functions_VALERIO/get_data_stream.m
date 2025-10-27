function [acq, sens2ignore, fs_extended] = get_data_stream(s, nBrds, offset)
  %get_data_stream Restituisce l'acquisizione (senza offset se fornito) dalla board s in
  %una matrice.
  %acquisisce i dati che vengono gia streammati.
  if nargin <1
      MAIN
  end
  flush(s);
%   tic
  header = read(s, 4, "char");
  for i = 1:nBrds
    field(i*60-59:i*60) = read(s, 60, "int16");
    remote(i, 1:3) = read(s, 3, "int16");
    fs{i} = read(s, 5, "uint8");
    tail_int{i} = read(s, 2, "char");
  end
  field = swapbytes(int16(field));
  remote = swapbytes(int16(remote));
  tail_ext = read(s, 3, "char");

  integrity_check(1) = strcmp(header, 'MAG3');
  integrity_check(2) = strcmp(tail_ext, 'END');
  for i = 1:nBrds
    integrity_check(2+i) = strcmp(tail_int{i}, strcat('B', string(i-1)));
  end
  if(min(integrity_check) == 0)
    error('ERROR: Unrecognized input string.')
  end
  fs_extended = get_fs(fs);
  fs3 = [fs_extended'; fs_extended'; fs_extended'];
  fs3 = fs3(:);
  acq = (double(field)/32768).*double(fs3');
  ind2ignore = find(field == -32768);
  acq(ind2ignore) = NaN;
  sens2ignore = (ind2ignore(3:3:size(ind2ignore,2)))/3;
%   acq = (vec2mat(acq,3))';
  acq = (vec2mat(acq,3));
%   toc
  if nargin > 2
    acq = (acq - offset);   % il fattore di scala � per la conversione in Gauss
  end
end
