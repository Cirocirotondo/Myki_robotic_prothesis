function [x] = cast2byte(x)
%cast2byte converte x in bytes per essere inviato su seriale.
x = single(x);
x = typecast(x,'uint8');
end
