function [acq] = get_data(s, offset, nCOM)
%get_data Restituisce l'acquisizione (senza offset se fornito) dalla board s in
%una matrice

if nargin <1
    MAIN
end

nBrds = size(s,2);
command_singleData = '@MAGMAP00:s100000*';
tic
for i = 1:nBrds
  fprintf(s{1,i}, '%s\r' ,command_singleData);
end
for i = 1:nBrds
% lastwarn('')
    data(i) = {(fread(s{1,i}, 253))};
%     [warnMsg, warnId] = lastwarn;
%     if ~isempty(warnMsg)
%       disp(['Communication problem on COM', num2str(nCOM(i)), '.'])
%       set_serial(s{1,i}, 0);
%       s(i) = {serial(strcat('COM', string(nCOM(i))))};
%       set_serial(s{1,i}, 1);
%       data(i) = {(fread(s{1,i}, 253))};
%     end
end
for i = 1:nBrds
%   cdata(i) = {char(data{1,i})};   %solo per debug
  try
    acq((i-1)*32+1:i*32,1:3) = interpret_data(data{1,i});
  catch
    return
  end
end
if nargin > 1
  acq = (acq - offset)/1000;   % il fattore di scala � per la conversione in Gauss
end
end
