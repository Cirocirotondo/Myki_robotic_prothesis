function [read_to_save,x00] = Add_RandomRot(TrajMag_fit, Matrix_of_sensors, M, DD, LL)

% This function is used to randomly rotate magnets while they are moving 
% NB Only moving magnets rotate

% INPUT
% - TrajMag_fit: actual magnets pose
% - Matrix_of_sensors: matrix of sensors to collect the simulated field
% - M (Nb_MM*1) : magnetic moment
% - DD (Nb_MM*1) : diameters
% - LL (Nb_MM*1) : cylinders height

% OUTPUT
% - x_new : new poses with varied rotation
% - read_to_save : simulated magnetic field


Nb_it = length(TrajMag_fit);
rng(1)
comp = ceil(rand(1,length(TrajMag_fit{end,:}))*3); % which component to rotate
% HOW choose a random component (x y z) and a 0.5 titling

read_to_save = [];

for ee = Nb_it
    
    S = [];
    for i = 1:length(TrajMag_fit{ee,:}) % nb of magnets

            tempD = TrajMag_fit{length(TrajMag_fit),:}{1,i}; 
            S = [S,tempD]; % 11 x (Nb_MM*3)
    end
    
    %% Orienation in the resting point
    [orientation] =  orientation_generator(S(1,:),Matrix_of_sensors); 
    orientation = - orientation;
    %%

    x00 = []; % save real positions 
    
    for ii = 1:length(TrajMag_fit{ee,:}) % Nb of MMs

        for ff = 1:length(TrajMag_fit{ee,:}{1,ii})    %% nb of checkpoints

            x = [reshape(S(1,:),[3,length(TrajMag_fit{ee,:})])'.*0.0254  orientation];
                        
            % variare l'orientazione influisce cosi tanto?
            % si perche' prima stavo girando il magnete dal lato opposto
            % (-orientation2): perche' col meno non fa? cos'e' un monopolo?
            % i picchi servirebbero a adattarsi a questo
            
            % mantenendo la stessa orientazione funziona
            % e sommando 0.5? yesssssssss
            
            orientation2 = orientation(ii,:);
            
            % e.g. 0, +0.5, 0, -0.5,...
            switch(mod(ff+3,4))
                case 0
                    orientation2(comp(ii)) = orientation2(comp(ii)) + 0; 
                case 1
                    orientation2(comp(ii)) = orientation2(comp(ii)) + 0.5;
                    orientation2 = orientation2/norm(orientation2);
                case 2
                    orientation2(comp(ii)) = orientation2(comp(ii)) + 0;
                case 3
                    orientation2(comp(ii)) = orientation2(comp(ii)) - 0.5;
                    orientation2 = orientation2/norm(orientation2);
            end
                                         
            x(ii,:) = [TrajMag_fit{ee,:}{1,ii}(ff,:).*0.0254' orientation2];

            xx = x';
            xx = xx(:);
            x00 = [x00; xx']; % enough to save it one time
            clear xx

            Reading = GenerateReadings(x,(Matrix_of_sensors.*0.0254)',...
                                      ones(size(x,1),1).*M,...
                                      DD,...
                                      LL); % #sensors x 3
                                  
            read_to_save = [read_to_save; Reading*1e4];

        end
    end
end
clear ee ii ff Reading
                                     
%% Verifica di quanto fa ruotare cambiare di 0.5 una componente

for mm = 1:length(DD)
    ang_bef = x00((mm-1)*11+1,(mm-1)*6+4:(mm-1)*6+6);
    ang_05plus = x00((mm-1)*11+2,(mm-1)*6+4:(mm-1)*6+6);
    ang_05less = x00((mm-1)*11+4,(mm-1)*6+4:(mm-1)*6+6);

    rot = acos(dot(([ang_bef(1),ang_bef(2),ang_bef(3)]),[ang_05plus(1),ang_05plus(2),ang_05plus(3)]))*180/pi
    rott = acos(dot(([ang_bef(1),ang_bef(2),ang_bef(3)]),[ang_05less(1),ang_05less(2),ang_05less(3)]))*180/pi
end

end