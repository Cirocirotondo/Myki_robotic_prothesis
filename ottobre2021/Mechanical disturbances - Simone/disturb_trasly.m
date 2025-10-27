function [sensors_rototrasl] = disturb_trasly(sensors,m,ff, nb_CK)
% Questa funzione applica il disturbo ai sensori, prima che questi
% effettuano la misura

% INPUT
% -> sensors: matrice contenente le posizioni dei sensori
% -> numMag: numero dei magneti
% -> nb_CK: numero di checkpoint in cui è diviso il movimento dei magneti
% -> m, ff: sono le due variabili dei due cicli for: mi permettono di
% capire a che punto ci troviamo della misurazione (li possiamo usare per
% ottenere una variabile tempo, crescente, che parte da 1 all'inizio della
% misurazione e termina con numMag*movMM)

% FUNZIONAMENTO:
% I disturbi avvengono lungo la direzione dell'osso (quello che 
% chiamiamo "asse y"), però i sensori e le traiettorio non sono orientate,
% su matlab, secondo il riferimento x y z. Quindi, ad ogni iterazione,
% ruotiamo i sensori in modo da allinearli con il riferimento x y z, poi
% applichiamo il disturbo, e infine li ri-ruotiamo nella posizione
% iniziale.

    xangle = -14;
    % yangle = 0; -> va già bene
    zangle = -20;

    % allineo i sensori ai riferimenti xyz
    sensors_rototrasl = rotx(xangle) * sensors;
    sensors_rototrasl = rotz(zangle) * sensors_rototrasl;
    
    % Traslazione lungo le y:
    if m == 1
        sensors_rototrasl(2,:) = sensors_rototrasl(2,:) + 0.005/nb_CK*ff; 
    elseif m == 2
        sensors_rototrasl(2,:) = sensors_rototrasl(2,:) + 0.005 - 0.005/nb_CK*ff; 
    elseif m == 3
        sensors_rototrasl (2,:) = sensors_rototrasl(2,:) - 0.005/nb_CK*ff;
    elseif m == 4
        sensors_rototrasl (2,:) = sensors_rototrasl(2,:) - 0.005 + 0.005/nb_CK*ff;
    end
    
    %riporto i sensori nella direzione iniziale
    sensors_rototrasl = rotz(-zangle) * sensors_rototrasl;
    sensors_rototrasl = rotx(-xangle) * sensors_rototrasl;

end
