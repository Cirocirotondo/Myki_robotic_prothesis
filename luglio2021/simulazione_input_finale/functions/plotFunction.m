function plotFunction(k)

    global nPos
    global nMag
    global MagPos
    global MagLoc
    global MagLoc_dist
    global MagCorrected
    global trajectories
    global Matrix_of_sensors
    global Matrix_of_sensors_dist
    global B
    global B_dist
    
    figure(2)
    clf
    hold on
    
    title("Iterazione n." + k + " di " + nPos);
    
    % traiettorie
    for j = 1:nMag
        plot3(trajectories(j, 1:2), trajectories(j,3:4), trajectories(j, 5:6), "LineWidth", 3)
    end
%% no disturbances
    % magneti(real) -> VERDI
    plot_mags(MagPos{k}, 6, 'g', 'g', 'g');      % original
    % magneti(rilevati) -> GIALLI
    plot_mags(MagLoc{k}, 6, 'y', 'y', 'y');
    % sensori
    scatter3(Matrix_of_sensors(1,:),Matrix_of_sensors(2,:), Matrix_of_sensors(3,:),'o','MarkerFaceColor',[0 0.447 0.741],'MarkerEdgeColor',[0 0 0], 'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.3)  
    % campo magnetico sui sensori
    quiver3(Matrix_of_sensors(1,:), Matrix_of_sensors(2,:), Matrix_of_sensors(3,:), B{k}(:,1)', B{k}(:,2)', B{k}(:,3)','k');  
%     plot_multiple_boards(Matrix_of_sensors,B{k},'k') 

%% with disturbances
    % magneti localizzati dal sistema disturbato -> CIANO(azzurro)
    plot_mags(MagLoc_dist{k}, 6, 'c', 'c', 'c');  
    % magneti nella posizione corretta -> MAGENTA(rosa)
    plot_mags(MagCorrected{k}, 6, 'm','m','m');
    % sensori spostati
    scatter3(Matrix_of_sensors_dist{k}(1,:),Matrix_of_sensors_dist{k}(2,:), Matrix_of_sensors_dist{k}(3,:),'.g');
    % campo magnetico sui sensori
    quiver3(Matrix_of_sensors_dist{k}(1,:), Matrix_of_sensors_dist{k}(2,:), Matrix_of_sensors_dist{k}(3,:), B_dist{k}(:,1)', B_dist{k}(:,2)', B_dist{k}(:,3)','g');  

    view(50,20)
    axis equal
    hold off

end