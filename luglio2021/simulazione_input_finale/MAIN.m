%LUGLIO 2021, VERSIONE AGGLOMERATA

% Simulazione dei dati (input simulati, non da mockup)
% Simulazione dei dati online (non batch) -> tutti i dati vengono tenuti
% salvati per il plot finale


clc
close all
clear all

addpath('functions')
addpath('Mathworks Fede Thesis')
variables
global MagLoc_dist



if enablePlotSetup == 1
   plotSetup;
end

for k = 1:nPos
    
%% Magnets trajectories generation
    moveMagnet(k);
    
%% Add disturbances
    moveSensors(k);
    
%% Field generation
    generateField(k);
% disturbed system
    generateField_dist(k);
    

%% Localize
    localize(k);
% MagLoc_dist: magnets localized by the disturbed system
    localize_dist(k);

%% If needed, remove disturbances
    check = everyoneInTrajectory(MagLoc_dist{k})
     if check == 0
         findRototranslation(k, MagLoc_dist{k});
         correctMagPos(k);
     else
         updateVar(k);
     end
     
%% Elimina errori evidentemente errati
% Serve davvero?

%% If enabled, display current result
    if enablePlotCurrent
        plotFunction(k)
        pause(0.5)
    end
    
    
end
