function [] = DoScatterPlots(x0,y,SensorPositionMatrix,step,Nb_MM)

colors = [1 0 1; 0 1 1; 0 1 0];

figure; hold on
set(gcf, 'Position',[10 20 800 700])
scatter3(SensorPositionMatrix(1,:),SensorPositionMatrix(2,:),SensorPositionMatrix(3,:),'r')
r = 1;
for k = 1:step
    for h = 1:Nb_MM
        point = scatter3(y(k,(h-1)*6+1),y(k,(h-1)*6+2),y(k,(h-1)*6+3));
        point.MarkerFaceColor = colors(r,:);
        point.MarkerEdgeColor = 'k';
        r = r+1;
        if (r==4)
            r=1;
        end
        scatter3(x0(k,(h-1)*6+1),x0(k,(h-1)*6+2),x0(k,(h-1)*6+3),'b')
    end
end
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
legend('Sensors','Tracked Position', 'Real Position')
title('Results')
set(gca,'FontSize',18)
grid on

end