function[V_finale] = trova_V(r0, X)
    %r0 è il punto fisso del fascio di rette
    %X è una matrice nPos*3 contenente le posizioni assunte da un magnete

    options = optimset('Algorithm','Levenberg-Marquardt','Display','off', 'UseParallel', false);
    fun = @(V) distance_squared(V, r0, X);
    V_finale = lsqnonlin(fun,[0.2 0.2 0],[],[],options);
    
    V_finale = V_finale/norm(V_finale);     %utilizzo un vettore unitario
    
end