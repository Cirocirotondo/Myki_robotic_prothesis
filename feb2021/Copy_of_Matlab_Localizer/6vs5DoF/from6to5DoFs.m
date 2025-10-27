function [x5] = from6to5DoFs(x6)
%from6to5DoFs converts magnets poses matrix from cartesian to spherical
%coordinates
  n = size(x6,1);
  x5 = x6(:,1:5);
  for i = 1:n
    [x5(i,5),x5(i,4),r] = cart2sph(x6(i,4), x6(i,5), x6(i,6));
    x5(i,4) = pi/2 - x5(i,4);
  end
end
