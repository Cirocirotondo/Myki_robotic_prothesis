function [trajectories_reordered] = reorder_trajectories(X,sys)

    trajectories_reordered = zeros(size(sys.trajectories));

    for k = 1:sys.nMag
       temp = find_nearest_trajectory(k,X,sys);
       trajectories_reordered(k,:) = sys.trajectories(temp,:);
    end
end