function [offset] = acquire_offset(s, n)
%acquire_offset media n acquisizioni per ricavare l'offset della board s.

nBrds = size(s,2);

offset = get_data(s);
for j = 1:n-1
  offset = offset + get_data(s);
end
offset = offset / n;
end
