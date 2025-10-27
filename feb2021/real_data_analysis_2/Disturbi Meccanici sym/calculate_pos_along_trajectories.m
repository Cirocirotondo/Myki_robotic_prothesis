function[pos_along_trajectories] = calculate_pos_along_trajectories(x6,trajectories_detected)
    
    [nMag,~] = size(x6);
    pos_along_trajectories = zeros(1,nMag);
    
    for i = 1:nMag
        A = trajectories_detected(i,1:2:5);
        B = trajectories_detected(i,2:2:6);
        a = A - B;
        c = A - x6(i,:);
        d = norm(cross(a,c))/norm(a);       %distanza = area / base
        
        c = norm(c);
        l = sqrt(c*c - d*d);                 %teor. di Pitagora
        pos_along_trajectories(i) = l/norm(a);
        
        cos_alpha = (c*c+l*l-d*d)/(2*c*l);
        if cos_alpha < 0
            pos_along_trajectories(i)= - pos_along_trajectories(i);
        end
    end
end