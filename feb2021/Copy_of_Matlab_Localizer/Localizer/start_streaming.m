function [] = start_streaming(s)
%start_streaming fa partire lo streaming da tutte le board connesse.

nBrds = size(s,2);
command_streaming = '@MAGMAP00:S100000*';
  for i = 1:nBrds
    fprintf(s{1,i}, '%s\r' ,command_streaming);
  end
end
