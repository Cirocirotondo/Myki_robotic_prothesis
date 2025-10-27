function generateField(k)
    global MagPos
    global nMag
    global Matrix_of_sensors
    global B
    global DD
    global LL
    global M
    
    B{k} = (GenerateReadings(MagPos{k},Matrix_of_sensors',...
        ones(nMag,1).*M, DD, LL))*10000;  % nSens*3 % multiplication "*10000" is for converting from tesla to gauss % multiplication "*0.0254" is for converting inches to meters
    
end
