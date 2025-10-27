function [m] = rotateMat(m, x, y, z)
%rotateMat ruota una matrice su x, y e z
  m = m*rotz(z)*roty(y)*rotx(x);
end

