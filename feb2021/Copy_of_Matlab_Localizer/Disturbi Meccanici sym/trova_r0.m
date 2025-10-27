function[r_finale] = trova_r0(X)

    %r0 è il punto avente la minima somma dei quadrati delle distanze da tutti i
    %punti
    
    options = optimset('Algorithm','Levenberg-Marquardt','Display','off', 'UseParallel', false,'TolFun', 1e-08, 'TolX', 1e-08);
    fun = @(r0) distance_squared_pointToPoint(r0, X);
    r_finale = lsqnonlin(fun, X(1,:) ,[],[],options);    %come condizione iniziale, diamo il primo punto della matrice X
end