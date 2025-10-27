function [dist] = point2pointDist(x,ref)
%point2pointDist compute distance between several couples of points
  n = size(x,1);
  for i = 1:n
    dist(i) = pdist([x(i, 1:3); ref(i,1:3)], 'euclidean'); %errore assoluto di localizzazione
  end
end
