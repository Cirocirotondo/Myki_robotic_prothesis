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




k = 18;
X{k}
figure(6)
hold  on
    title("Iterazione n." + k + " di " + nPos);
    plot_mags(X{k}, 6, 'r', 'g', 'y');      % original
    plot_mags(x6Riord{k}, 6, 'k', 'r', 'b');      % 6 DoF
    plot_mags(x6Mod{k}, 6, 'c', 'c', 'c');   % dove vengono visti i magneti dal sistema traslato
    plot_mags(x6Corrected{k}, 6, 'm', 'm', 'm')    % posizione dei magneti dopo aver corretto l'errore dovuto alla rototraslazione dei sensori
    
    %SC: stampa traiettorie
    plot3(trajectories(1, 1:2)*1000, trajectories(1,3:4)*1000, trajectories(1, 5:6)*1000, "LineWidth", 3)
    plot3(trajectories(2, 1:2)*1000, trajectories(2,3:4)*1000, trajectories(2, 5:6)*1000, "LineWidth", 3)
    plot3(trajectories(3, 1:2)*1000, trajectories(3,3:4)*1000, trajectories(3, 5:6)*1000, "LineWidth", 3)
    plot3(trajectories(4, 1:2)*1000, trajectories(4,3:4)*1000, trajectories(4, 5:6)*1000, "LineWidth", 3)
 
    plot_multiple_boards(sPosMod{k}, B1{k}', 'g') %stampa sensori rototraslati
    plot_multiple_boards(sPos, B{k}','k');

    axis equal
    if blocco_vista
      axis(bounds*1000)
    end
    hold off
    
    
figure(7)
plot3(trasl_tot_sensori, ang_tot_sensori, costo,'o', 'LineStyle', 'none');
xlabel('traslazione totale sensori')
ylabel('somma angoli di rotazione dei sensori')
zlabel('errore della misura')
labels = string(1:nPos);
text(trasl_tot_sensori, ang_tot_sensori, costo, labels, 'FontSize',8 )

