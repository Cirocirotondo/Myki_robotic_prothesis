function[x_fin] = rotateY(deg,x,x0)
    %Questa funzione ruota il punto x intorno all'asse parallelo all'asse y e passante dal
    %punto x0.
    
% INPUT
%   deg = gradi della rotazione voluta
%   x = vettore 1x3 o 1x6 (coordinate del punto da ruotare 
%       -> 1x3 nel caso della rotazione dei sensori
%       -> 1x6 nel caso della rotazione dei magneti
%   x0 = punto intorno a cui viene compiuta la rotazione
    
    
    [~,dim] = size(x);
    x_fin = zeros(1,dim);
    
    
    x_trasl = x(1:3) - x0;
    x_trasl_rot = (roty(deg)*x_trasl')';
    x_trasl_rot_ritrasl = x_trasl_rot + x0;

    x_fin(1:3) = x_trasl_rot_ritrasl;

    %bisogna fare ruotare anche i versori dei magneti.
    %poiché la funzione viene usata anche per la posizione dei sensori,
    %bisogna specificare che la rotazione dei versori va fatta sse x ha
    %6 colonne (ossia, se si tratta di un magnete)
    if dim == 6
        x_fin(4:6) = (roty(deg)*x(4:6)')';
    end
    
end