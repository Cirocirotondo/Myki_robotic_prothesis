function [pos_err, ang_err] = Compute_95_percentile_nMMs(x0, y, Nb_MM)

%% Input
% x0 real position
% y estimated position
%% Output
% position error
% orientation error

%% POSITION

estimated_displ = zeros(size(y,1),Nb_MM);
for k = 1:size(y,1)
    for h = 1:Nb_MM
        estimated_displ(k,h)=norm([y(k,(h-1)*6+1)-y(1,(h-1)*6+1) y(k,(h-1)*6+2)-y(1,(h-1)*6+2) y(k,(h-1)*6+3)-y(1,(h-1)*6+3)]);
    end
end

real_displ = zeros(size(y,1),Nb_MM);

for k = 1:size(y,1)
    for h = 1:Nb_MM
        real_displ(k,h)=norm([x0(k,(h-1)*6+1)-x0(1,(h-1)*6+1) x0(k,(h-1)*6+2)-x0(1,(h-1)*6+2) x0(k,(h-1)*6+3)-x0(1,(h-1)*6+3)]);
    end
end

% compute the error
% ------> Use the absolute value to caclulate the error
% ------> Take the overall 95th percentile

pos_err = abs((estimated_displ - real_displ))*1e3; % in mm
% err(1,:) = []; % first value is always zero
% pos_err_array = err(:);
% pos_err = prctile(pos_err_array, 95);

%% ANGULAR RELATIVE (NEW!)

ang = zeros(size(y,1),Nb_MM*3);

for k = 1:Nb_MM
    ang(:,(k-1)*3+1:(k-1)*3+3) = y(:, (k-1)*6+4:(k-1)*6+6);
end
clear k

% Normalize all the angles before computing the cosine

for h = 1:size(ang,1)
    for k = 1:Nb_MM
        ang(h,(k-1)*3+1:(k-1)*3+3) = ang(h,(k-1)*3+1:(k-1)*3+3)./norm(ang(h,(k-1)*3+1:(k-1)*3+3));
    end
end
clear h k

Estim_Rotation = zeros(size(y,1),Nb_MM);
Real_Rotation = zeros(size(y,1),Nb_MM);
for h = 1:size(y,1)
    for k = 1:Nb_MM
        Estim_Rotation(h,k) = acos(dot(([ang(h,(k-1)*3+1),ang(h,(k-1)*3+2),ang(h,(k-1)*3+3)]),[ang(1,(k-1)*3+1),ang(1,(k-1)*3+2),ang(1,(k-1)*3+3)]))*180/pi; 
        
        Real_Rotation(h,k) = acos((dot([x0(h,(k-1)*6+4),x0(h,(k-1)*6+5),x0(h,(k-1)*6+6)],[x0(1,(k-1)*6+4),x0(1,(k-1)*6+5),x0(1,(k-1)*6+6)])))*180/pi; 
    end
end

Estim_Rotation = real(Estim_Rotation); % the imaginary part is always zero thanks to the normalization
Real_Rotation = real(Real_Rotation);
ang_err = abs((Estim_Rotation - Real_Rotation));


end