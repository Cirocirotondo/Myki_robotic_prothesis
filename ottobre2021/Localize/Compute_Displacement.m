function [displ] = Compute_Displacement(x0, nb_mag)

% POSITION

displ = zeros(size(x0,1),nb_mag);

for k = 1:size(x0,1)
    for h = 1:nb_mag
        displ(k,h)=norm([x0(k,(h-1)*6+1)-x0(1,(h-1)*6+1) x0(k,(h-1)*6+2)-x0(1,(h-1)*6+2) x0(k,(h-1)*6+3)-x0(1,(h-1)*6+3)]);
    end
end

end