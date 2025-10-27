function plotSetup()

    global Matrix_of_sensors;
    global trajectories;

    figure; hold on
    
    scatter3(Matrix_of_sensors(1,:),Matrix_of_sensors(2,:),...
    Matrix_of_sensors(3,:),'o','MarkerFaceColor',[0 0.447 0.741],'MarkerEdgeColor',[0 0 0],...
       'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.3)  

   for i = 1:size(trajectories,1)
        plot3(trajectories(i,1:2),trajectories(i,3:4),trajectories(i,5:6),'LineWidth',2)
   end
   
   view(50,20)
   axis equal; hold off
end