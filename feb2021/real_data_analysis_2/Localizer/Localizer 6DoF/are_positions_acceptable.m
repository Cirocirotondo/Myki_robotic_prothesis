function [x, err] = are_positions_acceptable(x, bounds, min_dist, sPos)
%are_positions_acceptable checks if the positions of the magnets are
%acceptable and eventually resets them. Unacceptable positions are those
%out of bounds or those where magnets are overimposed.
%x0 are reset values for x.

err = 0;
x = vec2mat(x, 6);
% x0 = vec2mat(x0, 6);
nMag = size(x, 1);

for n1 = 1:nMag
  if sum([x(n1, 1:3) < bounds(1, 1:2:5), x(n1, 1:3) > bounds(1, 2:2:6)])
    x0 = rand_x0(nMag,sPos, 20);
    x0 = vec2mat(x0, 6);
    x(n1,:) = x0(n1,:);
    err = err+1;
  end
  for n2 = n1+1:nMag
    if norm(x(n1,1:3) - x(n2,1:3)) < min_dist
      x0 = rand_x0(nMag,sPos, 20);
      x0 = vec2mat(x0, 6);
      x(n1,:) = x0(n1,:);
      x(n2,:) = x0(n2,:);
      err = err+1;
    end
  end
end
end
