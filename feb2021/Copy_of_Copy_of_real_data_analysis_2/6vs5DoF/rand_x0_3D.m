function [x] = rand_x0_3D(nMag,sPos,mrg)
%rand_x0 Genera delle condizioni iniziali casuali per i magneti.
  if nargin <3
    mrg = 0;    % mrg is the minimum distance from the boards
  end
  x0 = ((rand(nMag, 6).* ...
  [(max(sPos(:,1))-mrg - (min(sPos(:,1))+mrg)), (max(sPos(:,2))-0 - (min(sPos(:,2))+0)), (max(sPos(:,3))-mrg - (min(sPos(:,3))+mrg)), 2, 2, 2]) ...
  +[min(sPos(:,1))+mrg, min(sPos(:,2))+0, min(sPos(:,3))+mrg, -1, -1, -1])';
  x = x0(:)';
  x = vec2mat(x,6);
  for i = 1:size(x,1)
      x(i,4:6) = x(i,4:6)/norm(x(i,4:6));
  end
  x = vec2mat(x,6);
end
