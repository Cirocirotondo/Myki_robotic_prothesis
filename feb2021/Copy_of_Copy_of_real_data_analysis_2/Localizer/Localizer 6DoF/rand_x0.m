function [x] = rand_x0(nMag,sPos, h)
%rand_x0 Genera delle condizioni iniziali casuali per i magneti.

    x0 = ((rand(nMag, 6).*[(max(sPos(:,1)) - min(sPos(:,1))), (max(sPos(:,2)) - min(sPos(:,2))), 0, 2, 2, 2])+[min(sPos(:,1)), min(sPos(:,2)), h/1000, -1, -1, -1])';
    x = x0(:)';
    x = vec2mat(x,6);
    for i = 1:size(x,1)
        x(i,4:6) = x(i,4:6)/norm(x(i,4:6));
    end
end
