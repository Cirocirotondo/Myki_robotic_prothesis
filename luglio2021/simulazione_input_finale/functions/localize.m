function localize(k)

    global nMag
    global Matrix_of_sensors
    global trajectories
%     global MagPos
    global MagLoc
    global B
    global m
    

   if k > 1
       MagLoc{k} = localize_magnets(MagLoc{k-1}, B{k}, nMag, m, Matrix_of_sensors');
   else
       magStartPos = zeros(nMag,6);
       for i = 1:nMag
           magStartPos(i,1) = mean(trajectories(i,1:2));
           magStartPos(i,2) = mean(trajectories(i,3:4));
           magStartPos(i,3) = mean(trajectories(i,5:6));
           magStartPos(i,4:6) = [0 1 0];
       end
       
       MagLoc{1} = localize_magnets(magStartPos,B{1}, nMag, m, Matrix_of_sensors');
   end

end