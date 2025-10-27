function[norms] = calculate_norm(x6, trajectories)
    [nMag,~] = size(x6);
    norms = zeros(1,nMag);
    
    for i = 1:nMag
        norms(i) = norm(x6(i,1:3) - trajectories(i,[1,3,5])) * 1000;
    end

end

