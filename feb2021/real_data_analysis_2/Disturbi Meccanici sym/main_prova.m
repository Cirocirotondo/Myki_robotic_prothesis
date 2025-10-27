%main di prova, usato per lanciare le varie funzioni da controllare

load workspace_prova
variables_DMsym
% traiettorie = [1 3 1 1 0 0; 
%                1 1 1 3 0 0];
 posizioni = [0 1 0 0 1 0; 
              1 0 0 1 0 0];
trovate = [0 1.5 0 0.5 0.866025 0
           1   0 0 1 0 0];
posizioni1 = [0,0.0475306392639435,0.0300000000000000,0.337711254942706,0.564607724006057,0.753106384435641];
trovate1 = [6.61351900399267e-05,0.0475258432631278,0.0300694808013042,0.358450277054382,0.588091008396867,0.733442988559669];


rototranslation = [0 0 0 30 90 0];
prova = (roty(90)*(rotx(30) * [0 1 0]'))'   
posizioni_rototraslate = rotoTrasla(posizioni, rototranslation)

%cost_function(rototranslation, posizioni, traiettorie, 2, 1)

%rototranslation_found = find_rototranslation(posizioni, traiettorie, 2, 1)


[pos_err, ang_err] = calcola_errore( posizioni1, trovate1 , 1)




k = 35;
x6{k}
figure(6)
clf
hold  on
    title("Iterazione n." + k + " di " + nPos);
    plot_mags(x6{k}, 6, 'c', 'c', 'c');   % dove vengono visti i magneti dal sistema
    plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
    
    %SC: stampa traiettorie
    plot3(trajectories_detected(1, 1:2)*1000, trajectories_detected(1,3:4)*1000, trajectories_detected(1, 5:6)*1000, "LineWidth", 3)
    plot3(trajectories_detected(2, 1:2)*1000, trajectories_detected(2,3:4)*1000, trajectories_detected(2, 5:6)*1000, "LineWidth", 3)
    plot3(trajectories_detected(3, 1:2)*1000, trajectories_detected(3,3:4)*1000, trajectories_detected(3, 5:6)*1000, "LineWidth", 3)
    %plot3(trajectories_detected(4, 1:2)*1000, trajectories_detected(4,3:4)*1000, trajectories_detected(4, 5:6)*1000, "LineWidth", 3)
 
    plot_multiple_boards(sPos, B{k}','k');

    axis equal
    if blocco_vista
      axis(bounds*1000)
    end
    hold off
    
errore_rilevazione(x6{278}, x6{279},boardsPoseMOKUP, SPOST_MAX)
    
% figure(7)
% plot3(trasl_tot_sensori, ang_tot_sensori, costo,'o', 'LineStyle', 'none');
% xlabel('traslazione totale sensori')
% ylabel('somma angoli di rotazione dei sensori')
% zlabel('errore della misura')
% labels = string(1:nPos);
% text(trasl_tot_sensori, ang_tot_sensori, costo, labels, 'FontSize',8 )

