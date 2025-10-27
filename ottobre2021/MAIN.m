clear 
clc
close all

%% LOAD T1,T2,T3

addpath('Variables')
addpath('Localize')
addpath('Field')
addpath('Error')
addpath('Mechanical disturbances - Simone')

load('Sensors_Simone.mat')
load('Trajectories_4_magnets_Simone.mat')

M = 1.2706/(4*pi*1e-7); % magnetization magnitude
D = 0.002; 
L = 0.001;
numMag = 4;
numSteps = 11;

Localization = []; % save the localizations
Localization_corrected = [];
x00 = [];


%% Generate the field and localize

S = [];
for m = 1:numMag

        tempD = Traj_final{m};
        S = [S,tempD'];
end
% NOTA: S contiene le posizioni assunte dai magneti durante gli spostamenti

for m = 1:numMag
    for ff = 1:size(S,1)    %% nb of checkpoints
        
        orientation= - orientation_generator(S(1,:),sensors); 
        x = [reshape(S(1,:),[3,numMag])'  orientation];
        orientation2 = orientation_generator(Traj_final{m}(:,ff),sensors);
        x(m,:) = [Traj_final{m}(:,ff)' -orientation2];

        xx = x';
        xx = xx(:); % Nb_mag*6       
        x00 = [x00; xx'];

        % i sensori, se volessi fare l'analisi in batch, li dovrei disturbare qui 
        
        % i sensori leggono il campo magnetico dei magneti
        Reading = GenerateReadings(x, sensors',...
                                          ones(size(x,1),1).*M,...
                                          ones(size(x,1),1).*D,...
                                          ones(size(x,1),1).*L);
        toIgnore = find(isnan(Reading));
        Reading = Reading.*1e4;
        Reading = Reading + randn(size(Reading,1),size(Reading,2))./1e3 +0.001; % Random Gaussian noise

       % localizzazione dei magneti sulla base dei valori restituiti dai
       % sensori.
       [Loc] = localize_magnets_sym(xx', Reading, numMag, 0.0254/8, sensors', [toIgnore(toIgnore<=size(sensors,2))]);

       LLoc = Loc';
       LLoc = LLoc(:); % Nb_mag*6
       Localization = [Localization; LLoc'];

    clear x xx Loc LLoc 
    end
end
%clear S

% Plot 
figure; hold on
for m = 1:numMag
    scatter3(Localization(:,(m-1)*6+1),Localization(:,(m-1)*6+2),Localization(:,(m-1)*6+3))
    scatter3(x00(:,(m-1)*6+1),x00(:,(m-1)*6+2),x00(:,(m-1)*6+3),'.','MarkerEdgeColor','k')
end
scatter3(sensors(1,:),sensors(2,:),sensors(3,:))
xlabel('x')
ylabel('y')
zlabel('z')

axis equal

%% MECHANICAL DISTURBANCES: CORREZIONE ERRORI

%[corrected,MagCorrected] = compensate_mechanical_disturbances(trajectories, sensors);
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
        
        % applico il disturbo -> ATTIVARE UNA DELLE SEGUENTI 4 RIGHE DI
        % CODICE, in base al tipo di disturbo che si vuole esercitare!!!
    
        sensors_dist = disturb_trasly(sensors,m,ff, size(S,1));
        %sensors_dist = disturb_roty(sensors, m,ff,nb_CK);
        %sensors_dist = disturb_rotx(sensors, m,ff,nb_CK);
        %sensors_dist = disturb_rotz(sensors, m,ff,nb_CK);

        
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

        MagCorrected = MagCorrected';
        MagCorrected = MagCorrected(:); % Nb_mag*6  
        Localization_corrected = [Localization_corrected; MagCorrected'];
    end
end

% Plot finale
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

%% ERROR

[pos_err, ang_err] = Compute_95_percentile_nMMs(x00, Localization, numMag); % calculate the position and orientation error of the localization
[pos_err1, ang_err1] = Compute_95_percentile_nMMs(x00, Localization_dist, numMag); % calculate the position and orientation error of the localization - disturbances - NO correction
[pos_err2, ang_err2] = Compute_95_percentile_nMMs(x00, Localization_corrected, numMag); % calculate the position and orientation error of the localization - disturbances - correction
 
pos_err(1:numSteps:end,:) = [];
ang_err(1:numSteps:end,:) = [];

pos_err1(1:numSteps:end,:) = [];
ang_err1(1:numSteps:end,:) = [];

pos_err2(1:numSteps:end,:) = [];
ang_err2(1:numSteps:end,:) = [];

%position error
figure; set(gcf, 'Position' ,[10 10 600 600])
title('Position error (mm)')
subplot(3,1,1);
boxplot(pos_err,'PlotStyle','compact')
axis([0 numMag+1 0 max(max(pos_err))+0.1])
xlabel('No Disturbances')
set(gca,'FontSize',16,'XTick',[]);

subplot(3,1,2);
boxplot(pos_err1,'PlotStyle','compact')
axis([0 numMag+1 0 max(max(pos_err1))+0.1])
set(gca,'FontSize',16,'XTick',[]);
xlabel('Disturbances - No Correction')

subplot(3,1,3);
xlabel('Disturbances - With Correction')
boxplot(pos_err2,'PlotStyle','compact')
axis([0 numMag+1 0 max(max(pos_err2))+0.1])
xlabel('Disturbances - With correction')
set(gca,'FontSize',16,'XTick',[]);

%angular error
figure; set(gcf, 'Position' ,[10 10 600 600])
title('Orientation error (deg)')
subplot(3,1,1)
boxplot(ang_err,'PlotStyle','compact')
axis([0 numMag+1 0 max(max(ang_err))+0.1])
xlabel('No Disturbances')
set(gca,'FontSize',16,'XTick',[]);

subplot(3,1,2)
boxplot(pos_err1,'PlotStyle','compact')
axis([0 numMag+1 0 max(max(pos_err1))+0.1])
xlabel('NO CORRECTION - Orientation error')
set(gca,'FontSize',16,'XTick',[]);

subplot(3,1,3)
boxplot(ang_err2,'PlotStyle','compact')
axis([0 numMag+1 0 max(max(ang_err2))+0.1])
xlabel('WITH CORRECTION - Orientation error')
set(gca,'FontSize',16,'XTick',[]);

[displ] = Compute_Displacement(Localization, numMag); % displacement step by step

%%