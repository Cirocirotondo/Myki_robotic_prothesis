function [fail] = set_serial(s, oc, baud)
%set_serial Opens or close the serial port selected by nCOM depending on oc.
%   nCOM is an integer.
%   oc is a boolean: 1 opens and 0 closes the port.
if oc
    set(s,'BaudRate',baud);
    try
        fopen(s);
    catch err
        fclose(instrfind);
        error('Make sure you select the correct COM Port.');
        fail = 1;
    end
else
    fclose(s);
    delete(s)
    clear s
end
fail = 0;
end
