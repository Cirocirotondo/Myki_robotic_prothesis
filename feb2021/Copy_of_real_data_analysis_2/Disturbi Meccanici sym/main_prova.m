%main di prova, usato per lanciare le varie funzioni da controllare

load workspace_prova
variables_DMsym

x0 = [(boardsPoseMOKUP(3,1)+boardsPoseMOKUP(4,1))/2, 0, boardsPoseMOKUP(2,3)/2]
uy = [0,1,0];
deg = 90;
% M=AxelRot(deg,uy,x0);
point = [x0(1) 0 0 1 0 0]

%point_rotated = rotateY(deg,point,boardsPoseMOKUP)
%point_rotated = rotateZ(deg,point,boardsPoseMOKUP);
% point_rotated = rotateX(deg,point,boardsPoseMOKUP);

point_rotated = rotoTrasla(point, [0 0 0 0 90 0] ,boardsPoseMOKUP)





% k = 35;
% x6{k}
% figure(6)
% clf
% hold  on
%     title("Iterazione n." + k + " di " + nPos);
%     plot_mags(x6{k}, 6, 'c', 'c', 'c');   % dove vengono visti i magneti dal sistema
%     plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
%     
%     %SC: stampa traiettorie
%     plot3(trajectories_detected(1, 1:2)*1000, trajectories_detected(1,3:4)*1000, trajectories_detected(1, 5:6)*1000, "LineWidth", 3)
%     plot3(trajectories_detected(2, 1:2)*1000, trajectories_detected(2,3:4)*1000, trajectories_detected(2, 5:6)*1000, "LineWidth", 3)
%     plot3(trajectories_detected(3, 1:2)*1000, trajectories_detected(3,3:4)*1000, trajectories_detected(3, 5:6)*1000, "LineWidth", 3)
%     %plot3(trajectories_detected(4, 1:2)*1000, trajectories_detected(4,3:4)*1000, trajectories_detected(4, 5:6)*1000, "LineWidth", 3)
%  
%     plot_multiple_boards(sPos, B{k}','k');
% 
%     axis equal
%     if blocco_vista
%       axis(bounds*1000)
%     end
%     hold off
%     
% errore_rilevazione(x6{278}, x6{279},boardsPoseMOKUP, SPOST_MAX)
    
% figure(7)
% plot3(trasl_tot_sensori, ang_tot_sensori, costo,'o', 'LineStyle', 'none');
% xlabel('traslazione totale sensori')
% ylabel('somma angoli di rotazione dei sensori')
% zlabel('errore della misura')
% labels = string(1:nPos);
% text(trasl_tot_sensori, ang_tot_sensori, costo, labels, 'FontSize',8 )

