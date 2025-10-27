function [] = delete_serials(s)
%delete_serials elimina gli oggetti porta seriale.

for i = 1: size(s,2)
    set_serial(s{1,i}, 0);
    fprintf('ALL SERIAL PORTS HAVE BEEN DELETED.')
end
