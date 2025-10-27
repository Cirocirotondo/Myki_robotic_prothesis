function B_model = MagDipole(MagnetPose,Mag,Vol,Point)

mu  = 4*pi*1e-7;          % vacuum permeability  [H/m]

x     = MagnetPose(1:3);  % j-th magnet position [mm]
m     = MagnetPose(4:6);  % j-th magnet moment   [adim]

% distance vector, from j-th magnet to the i-th sensor
pvec  = Point - x;               %[mm]
p     = norm(pvec);
pv    = pvec/p;

B_model = ((mu*Mag*Vol)/(4*pi*p^3))*(3*(pv*m')*pv - m);
