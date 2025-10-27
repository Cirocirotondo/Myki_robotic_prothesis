function [corrected, MagCorrected] = compensate_mechanical_disturbances(trajectories,sensors, )
% sensor_dist = sensori a cui è stato applicato il disturbo meccanico
% Reading_dist = rilevazioni del campo magnetico compiute dai sensori disturbati
nb_CK = size(S,1);
rototransl_prec = zeros(1,6);
Localization_dist = [];
Loc_prec = Localization(1,:);
errMax = 0.0015; % 1.5 mm ~ 10% della traiettoria

% traiettorie dei magneti
trajectories = find_trajectories(S);

%
for m = 1:numMag
    for ff = 1:size(S,1)    %% nb of checkpoints
        fprintf('m= %4.2f; ff = %4.2f; iterazione n. %4.2f',m,ff,(m-1)*nb_CK + ff)
        % applico il disturbo
    
        %sensors_dist = disturb_trasly(sensors,m,ff, size(S,1));
        %sensors_dist = disturb_roty(sensors, m,ff,nb_CK);
        %sensors_dist = disturb_rotx(sensors, m,ff,nb_CK);
        sensors_dist = disturb_rotz(sensors, m,ff,nb_CK);

        
        % ottengo dalla matrice x00 la posizione dei magneti all'{(m-1)*nb_CK+ff}-esimo passaggio
        x = x00( (m-1)*nb_CK + ff,: );
        x = reshape(x, [6,4])';
        % leggo le rilevazioni fatte dai sensori
        Reading_dist = GenerateReadings(x, sensors',...
                                          ones(size(x,1),1).*M,...
                                          ones(size(x,1),1).*D,...
                                          ones(size(x,1),1).*L);
        toIgnore = find(isnan(Reading_dist));
        Reading_dist = Reading_dist.*1e4;
        Reading_dist = Reading_dist + randn(size(Reading_dist,1),size(Reading_dist,2))./1e3 +0.001; % Random Gaussian noise
        
        % localizzazione dei magneti sulla base dei valori restituiti dai
        % sensori.
        [Loc_dist] = localize_magnets_sym(Loc_prec, Reading_dist, numMag, 0.0254/8, sensors_dist', [toIgnore(toIgnore<=size(sensors,2))]);

        Localization_dist = [Localization_dist; Loc_dist];
        Loc_prec = Loc_dist;
        
        Loc_dist = reshape(Loc_dist, [6,4])';
        
        % If needed, remove disturbances
        check = everyoneInTrajectory(Loc_dist,trajectories, errMax)
        if check == 0
            rototransl = findRototranslation(Loc_dist,rototransl_prec,trajectories,errMax);
            MagCorrected = rotoTrasla(Loc_dist, rototransl);
        else
            MagCorrected = Loc_dist;
            rototransl = zeros(1,6);
        end
        
        rototransl_prec = rototransl;
        
        %plot
        figure(2);clf; hold on
        scatter3(MagCorrected(:,1),MagCorrected(:,2),MagCorrected(:,3),'MarkerEdgeColor','m')   %con correzione
        scatter3(Loc_dist(:,1),Loc_dist(:,2),Loc_dist(:,3),'MarkerEdgeColor','c')               %senza correzione

        for i = 1:numMag
            %scatter3(Localization_dist(:,(i-1)*6+1),Localization_dist(:,(i-1)*6+2),Localization_dist(:,(i-1)*6+3))
            scatter3(x00(:,(i-1)*6+1),x00(:,(i-1)*6+2),x00(:,(i-1)*6+3),'.','MarkerEdgeColor','k')
        end
        scatter3(sensors(1,:),sensors(2,:),sensors(3,:),'MarkerEdgeColor','r')
        scatter3(sensors_dist(1,:),sensors_dist(2,:),sensors_dist(3,:),'MarkerEdgeColor','g')
        xlabel('x')
        ylabel('y')
        zlabel('z')

        axis equal
        view(185,25)
    end
end

% Plot 
figure; hold on
for m = 1:numMag
    scatter3(Localization_dist(:,(m-1)*6+1),Localization_dist(:,(m-1)*6+2),Localization_dist(:,(m-1)*6+3))
    scatter3(x00(:,(m-1)*6+1),x00(:,(m-1)*6+2),x00(:,(m-1)*6+3),'.','MarkerEdgeColor','k')
end
scatter3(sensors(1,:),sensors(2,:),sensors(3,:))
xlabel('x')
ylabel('y')
zlabel('z')

axis equal