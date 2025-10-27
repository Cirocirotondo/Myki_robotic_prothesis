function [] = plot_mags(x, DoFs, mag_color, north_color, south_color)
%plot_mags plots magnets in space
  nMag = size(x,1);
  vect_mult = 1/120;  % increases vectors dimensions
  xVis = vec2mat(x, DoFs);
  scatter3(xVis(1:nMag,1),xVis(1:nMag,2),xVis(1:nMag,3), 10, mag_color, 'filled')
  if DoFs == 5
    [Rx_vis,Ry_vis,Rz_vis] = sph2cart(xVis(1:nMag,5) + pi, xVis(1:nMag,4) + pi/2, vect_mult);
  else
    Rx_vis = xVis(1:nMag,4)*vect_mult;
    Ry_vis = xVis(1:nMag,5)*vect_mult;
    Rz_vis = xVis(1:nMag,6)*vect_mult;
  end
  quiver3(xVis(1:nMag,1), xVis(1:nMag,2), xVis(1:nMag,3), Rx_vis, Ry_vis, Rz_vis, north_color,'LineWidth', 1.5, 'AutoScale','off')
  quiver3(xVis(1:nMag,1), xVis(1:nMag,2), xVis(1:nMag,3), -Rx_vis, -Ry_vis, -Rz_vis, south_color, 'LineWidth',1.5 , 'AutoScale','off')
end