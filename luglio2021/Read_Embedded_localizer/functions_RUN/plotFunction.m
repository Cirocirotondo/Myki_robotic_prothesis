function plotFunction(sys)
    
    figure(1)
    clf
    hold on
    
    
    % traiettorie
    for j = 1:sys.nMag
        plot3(sys.trajectories(j, 1:2), sys.trajectories(j,3:4), sys.trajectories(j, 5:6), "LineWidth", 3)
    end

    % sensori
    % scatter3(Matrix_of_sensors(1,:),Matrix_of_sensors(2,:), Matrix_of_sensors(3,:),'o','MarkerFaceColor',[0 0.447 0.741],'MarkerEdgeColor',[0 0 0], 'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.3)

    % magneti localizzati dalla board -> CIANO(azzurro)
    plot_mags(sys.X, 6, 'c', 'c', 'c');  
    % magneti dopo la correzione -> MAGENTA(rosa)
    plot_mags(sys.XCorrected, 6, 'm','m','m');
    
    
    view(50,20)
    axis equal
    hold off

end