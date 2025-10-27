function moveSensors(k)
    global Matrix_of_sensors_dist
    global Matrix_of_sensors
    global nPos
    
    % Movimento consequenziale
    
    spostMax = [0.01; 0.01; 0.01];   %spostamento massimo

    t = (k-1)/nPos;
    Matrix_of_sensors_dist{k} = Matrix_of_sensors + spostMax*t;

end