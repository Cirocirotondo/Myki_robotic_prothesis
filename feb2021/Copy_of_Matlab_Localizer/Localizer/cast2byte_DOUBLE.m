function [x] = cast2byte_DOUBLE(x)
%cast2byte converte x in bytes per essere inviato su seriale.
x = typecast(x,'uint8');
end
