function localize_dist(k)

    global nMag
    global Matrix_of_sensors
    global trajectories
    global MagLoc_dist
    global B_dist
    global m
    

   if k > 1
       MagLoc_dist{k} = localize_magnets(MagLoc_dist{k-1}, B_dist{k}, nMag, m, Matrix_of_sensors');
   else
       %come posizione iniziale dei magneti considero la posizione centrale
       %delle traiettorie
       magStartPos = zeros(nMag,6);
       for i = 1:nMag
           magStartPos(i,1) = mean(trajectories(i,1:2));
           magStartPos(i,2) = mean(trajectories(i,3:4));
           magStartPos(i,3) = mean(trajectories(i,5:6));
           magStartPos(i,4:6) = [0 1 0];
       end
       
       MagLoc_dist{1} = localize_magnets(magStartPos,B_dist{1}, nMag, m, Matrix_of_sensors');
   end

end