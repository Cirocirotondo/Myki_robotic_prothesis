function[check] = everyoneInTrajectory (X,sys)
% Questa funzione controlla che tutti i magneti dell'array X siano all'interno della
% propria traiettoria

    
    distances = calculate_distances(X, sys);

    check = 1;
    for i = 1:sys.nMag
        if distances(i) > sys.errMax
            check = 0;
        end
    end
end