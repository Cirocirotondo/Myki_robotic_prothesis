function[V_finale] = trova_V(r0, X)
    %r0 è il punto fisso del fascio di rette
    %X è una matrice nPos*3 contenente le posizioni assunte da un magnete

    options = optimset('Algorithm','Levenberg-Marquardt','Display','off', 'UseParallel', false);
    fun = @(V) distance_squared(V, r0, X);
    V_finale = lsqnonlin(fun,[0.2 0.2 0],[],[],options);
    
    V_finale = V_finale/norm(V_finale);     %utilizzo un vettore unitario
    
    %ho spostato il plot nel main
%     plot3(X(:,1)*1000, X(:,2)*1000, X(:,3)*1000,'o')      
%     plot3(r0(1)*1000,r0(2)*1000,r0(3)*1000, '+')
%     plot3([r0(1)-V_finale(1) r0(1) r0(1)+V_finale(1)]*1000, [r0(2)-V_finale(2) r0(2) r0(2)+V_finale(2)]*1000, [r0(3)-V_finale(3) r0(3) r0(3)+V_finale(3)]*1000)
%     axis equal
    
end