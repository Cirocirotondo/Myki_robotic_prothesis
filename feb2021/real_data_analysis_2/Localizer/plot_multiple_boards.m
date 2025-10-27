function [] = plot_multiple_boards(SP, B,colour)
%plot_multiple_boards plotta le boards con i sensori in 3D

  % plot3( 1000*([0 0.038 0.038 0 0]), 1000*([0 0 0.1215 0.1215 0]), 1000*([0 0 0 0 0]), 'k' )
  % plot3( 1000*([0.0045 0.038-0.0045 0.038-0.0045 0.0045 0.0045]), 1000*([0.003 0.003 0.068 0.068 0.003]), 1000*([0 0 0 0 0]), 'k' )
  quiver3(1000*SP(:,1), 1000*SP(:,2), 1000*SP(:,3), B(:,1), B(:,2), B(:,3), colour);  %plotta campo sui sensori
  scatter3(1000*SP(:,1),1000*SP(:,2),1000*SP(:,3), colour, '.')
  axis equal
  % axis([-0.01 0.06 -0.02 0.1215 0 0.06]) % 3D plat con sens
  % xlim(1000*[-0.015 0.06])
  % ylim(1000*[-0.005 0.1215])
  % zlim(1000*[0 0.06])
  set_camera_std();
end
