% Generate an array of 3 x Nb_MM normal vectors that indicate
% the orientation of Nb_MM magnets in the workspace, when oriented towards
% the nearest sensor

% Additional Outputs: 
% min_dist =  distance from the nearest sensor
% inter_dist = distance from the nearest magnet (to veritfy R values are
% correct)

% Input:
% 
% x = vector (Nb_Mag * 3) of magnets position in inches
% e.g. in T1 is 1 x 33
% MatriceSenori is 3 x Nb_sensors, position in inches

function [orientation, min_dist, inter_dist] = orientation_generator(x,MatriceSensori)

    x_coord = 1;
    min_dist = zeros(1, length(x)/3);
    inter_dist = zeros(1, length(x)/3 ); 
    orientation = zeros(length(x)/3, 3);
    
    for i=1:length(x)/3                 
        rep_mag_sensori =  [x(x_coord) x(x_coord+1) x(x_coord+2)]'.*ones(3,size(MatriceSensori,2));     
        % replicate the MM coordinates a Nb of times equal to the Nb of
        % sensors (NB all columns are equal)
        rep_mag_magneti =  [x(x_coord) x(x_coord+1) x(x_coord+2)]'.*ones(3,length(x)/3);     

        s_sensori = bsxfun(@minus,rep_mag_sensori,MatriceSensori);  % bsxfun funziona per colonne   
        norm_quad2 = bsxfun(@dot,s_sensori,s_sensori); % distanza al quadrato (è un vettore)
        norm_quad2 = sqrt(norm_quad2); % distanza in pollici
        norm_quad2 = norm_quad2*2.54; % distanza in cm
        orientation(i,:) = s_sensori(:,find((norm_quad2)== min(norm_quad2)))./norm(s_sensori(:,find((norm_quad2)== min(norm_quad2))));
        % prendo come orientazione il versore che punta in quella direzione
        % (i.e. minima distanza)
    x_coord = x_coord+3;
    min_dist(i) = min(norm_quad2);
    
    clear norm_quad2
    if length(x)/3 > 1
        s_magneti = bsxfun(@minus,rep_mag_magneti,reshape(x,3,length(x)/3));  % bsxfun funziona per colonne   
        s_magneti(:,i) = []; % non considero la distanza con se stesso
        norm_quad2 = bsxfun(@dot,s_magneti,s_magneti); % distanza al quadrato (è un vettore)
        norm_quad2 = sqrt(norm_quad2); % distanza in pollici
        norm_quad2 = norm_quad2*2.54; % distanza in cm
        inter_dist(i) = min(norm_quad2);

        clear norm_quad2
    end
    
    end 
end

