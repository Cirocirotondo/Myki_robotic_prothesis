function [M] = sortMagnets(M)
%sortMagnets ordina i magneti in modo da averli tutti ordinati allo stesso
%modo

  N = size(M,2);
  for i = 1:N
    Y(i) = M{1,i}(1,2);
  end

  Ysorted = sort(Y);
  if sum(~(Y == Ysorted))
    temp = M;
    for i = 1:N
      M{1,i} = temp{1, find(Y == Ysorted(i))};
    end
  end

end
