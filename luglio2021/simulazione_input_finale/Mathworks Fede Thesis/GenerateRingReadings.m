function Readings = GenerateRingReadings(MagnetPoses,SensorPositionMatrix,...
                                      M,Rin,Rout,L)

Nsens    = size(SensorPositionMatrix,1); 
MM       = size(MagnetPoses,1);
Readings = zeros(Nsens,3);

for u = 1:MM
    for i = 1:Nsens
        Point = SensorPositionMatrix(i,:)';
        [Bx, By, Bz] = WrapRingBfield3(Rin(u),Rout(u),L(u),M(u),MagnetPoses(u,:)',Point);
        Readings(i,:) = Readings(i,:) + [Bx By Bz];
    end
end