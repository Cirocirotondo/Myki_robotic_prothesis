function [s] = create_serials(nCOM, open, baud)
%create_serials crea gli oggetti porta seriale e li restituisce in un cell
%array. Se open � vero, le apre anche.

for i = 1: size(nCOM,2)
    s(i) = {serial(strcat('COM', string(nCOM(i))))};
    if open
        set_serial(s{1,i}, 1, baud);
    end
    disp(sprintf('Serial port COM%i opened.', nCOM(i)))
end
