function [x, new_movement] = randomly_move_magnets(x, dist, alpha, previous_movement)
%randomly_move_magnets moves magnets of a distance ?dist? in a random
%direction
  n = size(x,2);
  for i=1:n
    if size(previous_movement{i},1) == 0
      previous_movement{i} = rand(3,1)*2-1;
    end
    new_movement{i} = rand(3,1)*2-1;
    new_movement{i} = alpha*previous_movement{i}/dist + (1-alpha)*new_movement{i};
    new_movement{i} = new_movement{i}/norm(new_movement{i})*dist;
    x(1:3,i) = x(1:3,i) + new_movement{i};
  end
end
