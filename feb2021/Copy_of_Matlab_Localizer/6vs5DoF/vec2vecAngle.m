function [dist] = vec2vecAngle(x, ref)
%vec2vecAngle compute the angoular distance between several couples of
%vectors
  n = size(x,1);
  for i = 1:n
    if size(x,2) == 6
      dist(i) = rad2deg(atan2(norm(cross(x(i, 4:6),ref(i,4:6))),dot(x(i, 4:6),ref(i,4:6)))); %restituisce l'angolo tra 2 vettori in gradi
    else if size(x,2) == 5
      [x_cart(1), x_cart(2), x_cart(3)] = sph2cart(x(i,5), pi/2 - x(i,4), 1);
      dist(i) = rad2deg(atan2(norm(cross(x_cart,ref(i,4:6))),dot(x_cart,ref(i,4:6)))); %restituisce l'angolo tra 2 vettori in gradi
    end
  end
end
