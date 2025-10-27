function[x_fin] = rotateX(deg,x,boardsPoseMOKUP)
    %Questa funzione ruota il punto x intorno all'asse parallelo all'asse z e passante dal
    %punto x0.
    %Input: deg = gradi della rotazione voluta
    %       x = vettore 1x3 (coordinate del punto da ruotare)
    %       matrice boardsPoseMOKUP
    
    [~,dim] = size(x);
    x_fin = zeros(1,dim);
    
    x0 = [(boardsPoseMOKUP(3,1)+boardsPoseMOKUP(4,1))/2, 0, boardsPoseMOKUP(2,3)/2];

    
    x_trasl = x(1:3) - x0;
    x_trasl_rot = (rotx(deg)*x_trasl')';
    x_trasl_rot_ritrasl = x_trasl_rot + x0;

    x_fin(1:3) = x_trasl_rot_ritrasl;
    
    %bisogna fare ruotare anche i versori dei magneti.
    %poiché la funzione viene usata anche per la posizione dei sensori,
    %bisogna specificare che la rotazione dei versori va fatta sse x ha
    %6 colonne (ossia, se si tratta di un magnete)
    if dim == 6
        x_fin(4:6) = (rotx(deg)*x(4:6)')';
    end
    
end