clear
close all
clc
load Workspace/SimoneWorkspace % load magnets initial position, trajectories, and sensor matrix
addpath('Dependencies');
addpath('stlTools');

% x00 = position and orientation of a11 magnets (Nb_MM, on the columns), along 121 steps (on the raws)
% xrr, TrajMag_fit = used for plot only, you don't need them
% Matrix_of_sensors = coordinates of 480 sensors, there is a conversions in the code because they are in inches
% mag_mom = magnetic moment of the magnets
% DD = diameter of the magnets
% LL = height of the magnets
% fi_marta = muscles to plot, taken from the cad (shoulder_arm_skin_POLLICI_stl.stl), used only for plot
% NB_MM = Number of Magnets

%% Random Gaussian Noise

rng(2) % seed for generating the same random numbers everytime I launch the code
mu                  =       0.000;
sigma               =       0.004;
Noise = randn(size(x00,1)*size(Matrix_of_sensors,2),3) * sigma + mu;
% figure; histogram(Noise(:,1),250) % this is the noise to be added to the simulated field

%% PLOT THE SETUP %%

figure; hold on  
for i = length(TrajMag_fit)
    for mm = 1:Nb_MM
        plot3(TrajMag_fit{i}{mm}(:,1),TrajMag_fit{i}{mm}(:,2),TrajMag_fit{i}{mm}(:,3),'LineWidth',2)
    end
end
 plot_cylinders(xrr,1);
 scatter3(Matrix_of_sensors(1,:),Matrix_of_sensors(2,:),...
    Matrix_of_sensors(3,:),'o','MarkerFaceColor',[0 0.447 0.741],'MarkerEdgeColor',[0 0 0],...
       'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.3)  
% plot_muscles(fi_marta)
hold off
axis equal
set(gca,'XTick',[],'YTick',[],'XColor','none','YColor','none')
set(gcf,'Position',[50 50 800 600]) 
title('Setup', 'FontSize',18)

clear i m
%% Add Random_Tilting, i.e. random rotations of the magnets along the trajectory

[read_to_save,x00] = Add_RandomRot(TrajMag_fit, Matrix_of_sensors, M, DD, LL);
read_noise = read_to_save + Noise;

%% Localize the Magnets along the Trajectories, step by step
% Trajectories are 121 steps long, because we have:
%   - 11 magnets
%   - 11 step-points for each magnet trajectory
%   - magnets are moved one per time, while the others stay in their initial position

Loc = zeros(size(x00,1),6*Nb_MM); % vairable that will host the localizations
mat = Matrix_of_sensors.*0.0254;  % conversione pollici-metri

%% Localize
Nb_s = size(Matrix_of_sensors,2);
for s = 1:size(x00,1)
    disp(s);
    
    Read = read_noise((s-1)*Nb_s+1:s*Nb_s,:);
    if s == 1
        x = x00(s,:);
        x = reshape(x,6,Nb_MM);
        x = x';
        x(:,1:3) = x(:,1:3) + ((1-0.5).*rand(Nb_MM,3) + 0.0)*1e-2; % err tra 5 mm e 1 cm
    else
        x = Loc(s-1,:);
        x = reshape(x,6,Nb_MM);
        x = x';        
    end
    tic
    Loc_temp = localize_magnets_sym(x, Read, Nb_MM, mag_mom, mat', 0);
    time = toc;
    LLoc = Loc_temp';
    LLoc = LLoc(:);
    Loc(s,:) = LLoc;
      
end

clear s
%% ScatterPlot (very very very slow if you plot all checkpoints)
init = 10;
fin = 82; % you can change init and fin to plot different instants of the results
DoScatterPlots(x00(init:fin,:),Loc(init:fin,:),mat,(fin-init),Nb_MM) % plot results of the localization (only position, not orientation)
 


