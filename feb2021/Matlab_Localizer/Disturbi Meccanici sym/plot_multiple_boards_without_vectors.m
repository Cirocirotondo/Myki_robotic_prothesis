function [] = plot_multiple_boards_without_vectors(SP,colour)
%plot_multiple_boards_without_vectors plotta le boards con i sensori in 3D, senza i vettori
%del campo magnetico

  scatter3(1000*SP(:,1),1000*SP(:,2),1000*SP(:,3), colour, '.')
  axis equal
  set_camera_std();
end
