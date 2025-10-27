function [errors, ep, Sp] = errorMeasP(M,ref)
%PositionBias calcola il bias rispetto ad una posizione di riferimento

N = size(M,2);
  for i = 1:N
    for j = 1:size(M{1,1},1)
      errors(i,j) = pdist([M{1,i}(j, 1:3); ref(i,1:3)], 'euclidean'); %errore assoluto di localizzazione
    end
  end
  ep = mean(errors');
  Sp = std(errors');
end
