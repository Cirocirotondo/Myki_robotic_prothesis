function [sPos_finale, rototraslazione] = randomly_move_sensors(sPos,rototraslazione_precedente)

%Parte 0: pura traslazione lungo le x
    %sPos è una matrice 128*3
%     sPos(:,1) = sPos(:,1) + 0.005;  %il blocco viene traslato di x
%     traslazione = 0.005;


% %Parte 1: pura traslazione di un vettore [x y z]. i moduli di questi
% %spostamenti hanno modulo minore di 0.010
%     traslazione = rand(1,3)*0.02 - 0.01;
%     sPos = sPos + traslazione;

    
%Parte 2: le traslazioni sono tra loro sequenziali: ogni traslazione è uno
%scostamento dalla posizione precedente. Stessa cosa per le rotazioni.

    rototraslazione = rototraslazione_precedente;
    dt = rand(1,3)*0.02 - 0.01;     % c'è un dt per ogni direzione. Il modulo dello spostamento, per ogni direzione, è minore di 1 cm
    for i = 1:2:3   %il massimo scostamento per le direzioni x e z è pari a 1.5 cm
        if rototraslazione_precedente(i) + dt(i) <= 0.015 && rototraslazione_precedente(i) + dt(i) >= -0.015        
             rototraslazione(i) = rototraslazione_precedente(i) + dt(i);
        end
    end
    if rototraslazione_precedente(2) + dt(2) <= 0.02 && rototraslazione_precedente(2) + dt(2) >= -0.02         %il massimo scostamento nella direzione y è pari a 2 cm
             rototraslazione(2) = rototraslazione_precedente(2) + dt(2);
    end
    
% 
% % ROTAZIONE
% 
% %     rototraslazione(4) = 10;        % per ora: rotazione di 10° lungo l'asse x
% 
%     % sPos = 128x3. Per ruotare un vettore bisogna moltiplicare la matrice
%     % rotazione per un vettore 3x1 (o matrice 3xN). Allora uso la trasposta
%     % di sPos, e poi ri-traspongo il tutto.
%     
% %     rototraslazione(4:6) = rand(1,3)*20 - 10;        %la rotazione nelle tre direzioni ha modulo massimo di 10°   
% %     sPos_finale = (rotz(rototraslazione_precedente(6)) * (roty(rototraslazione_precedente(5)) * (rotx(rototraslazione_precedente(4)) * sPos')))';     
% 
%     dr = rand(1,3)*2 - 1;   %c'è una dr per ogni direzione. Il modulo della rotazione, per ogni asse, è minore di 1°
%     for i = 1:3
%         if rototraslazione_precedente(3+i) + dr(i) <= 10 && rototraslazione_precedente(3+i) + dr(i) >= -10      %la rotazione nelle tre direzioni ha modulo massimo di 10°   
%             rototraslazione(3+i) = rototraslazione_precedente(3+i) + dr(i);
%         end
%     end
%     
%     sPos_finale = rotoTrasla(sPos, rototraslazione);


    rototraslazione(4:6) = [3 0 0];
    sPos_finale = (rotz(rototraslazione_precedente(6)) * (roty(rototraslazione_precedente(5)) * (rotx(rototraslazione_precedente(4)) * sPos')))';     
    


end