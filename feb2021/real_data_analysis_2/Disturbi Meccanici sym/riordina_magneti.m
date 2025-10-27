function[x6Riordinati] = riordina_magneti(x6,trajectories)
% Questa funzione riordina i magneti nella matrice.
% Infatti la funzione "localize magnets" ottiene la posizione degli nMag magneti, ma tali
% magneti non sono sempre nell'ordine corretto (ossia: il magnete che si
% trova sulla prima traiettoria non sempre si trova nella prima riga, il
% magnete che si trova sulla seconda traiettoria non sempre si trova sulla
% seconda riga, etc.) Questa cosa non ci piace perché manda all'aria gli
% algoritmi di minimizzazione per ottenere lo spostamento dei sensori. Per
% questo è necessario riordinare i magneti.

    x6Riordinati = zeros(size(x6));
    [nMag,~] = size(x6);
    for i = 1: nMag
        %creo la matrice "x-iesimo" di dimensioni nMag*6, contenente le posizioni dell'i-esimo
        %magnete, clonate in tutte le nMag righe (questa operazione è
        %unicamente funzionale al calcolo delle distanze con l'utilizzo
        %della già esistente funzione "calculate distances"
        x_iesimo = zeros(nMag,6);
        for j = 1:nMag
            x_iesimo(j,:) = x6(i,:);
        end
        distanze_dalle_traiettorie = calculate_distances(x_iesimo, trajectories, nMag);     %vettore contenente le distanze che l'i-esimo magnete ha dalle varie traiettorie
        [~, min_index] = min(distanze_dalle_traiettorie);
        x6Riordinati(min_index,:) = x6(i, :);               % si ottiene la posizione dell'i-esimo magnete guardando la minima distanza dalle varie traiettorie.
    end
    
    %controllo operazione riuscita
    successfull_operation = 1;
    for i = 1:nMag
        if x6Riordinati(i, :) == zeros(1,6)
            successfull_operation = 0;
        end
    end
    if successfull_operation == 0
        x6Riordinati = x6;
    end

end