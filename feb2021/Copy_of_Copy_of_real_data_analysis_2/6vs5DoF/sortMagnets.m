function [M] = sortMagnets(M, sort_axis)
%sortMagnets ordina i magneti in modo da averli tutti ordinati allo stesso
%modo

  N = size(M,1);
  for i = 1:N
    Y(i) = M(i,sort_axis);
  end

  Ysorted = sort(Y);
  if sum(~(Y == Ysorted))
    temp = M;
    for i = 1:N
      M(i,:) = temp(find(Y == Ysorted(i)),:);
    end
  end

end
