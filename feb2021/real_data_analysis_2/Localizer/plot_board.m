function [] = plot_board(pose, sPos)

nBoards = size(sPos,1)/32;
for n = 1: nBoards
%   plot3( 1000*([0 0.038 0.038 0 0] + pose(n,1)), 1000*([0 0 0.1215 0.1215 0] + pose(n,2)), 1000*([0 0 0 0 0] + pose(n,3)), 'k' )
%   plot3( 1000*([0.0045 0.038-0.0045 0.038-0.0045 0.0045 0.0045] + pose(n,1)), 1000*([0.003 0.003 0.068 0.068 0.003] + pose(n,2)), 1000*([0 0 0 0 0] + pose(n,3)), 'k' )
end
scatter3(sPos(:,1)*1000,sPos(:,2)*1000,sPos(:,3)*1000, 'k', '.')
axis equal
% axis([-0.01 0.06 -0.02 0.1215 0 0.06]) % 3D plat con sens
% xlim(1000*[-0.015 0.06])
% ylim(1000*[-0.005 0.1215])
% zlim(1000*[0 0.06])
set_camera_std();
end
