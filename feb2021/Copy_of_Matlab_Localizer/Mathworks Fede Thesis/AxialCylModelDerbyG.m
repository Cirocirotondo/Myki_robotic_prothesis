function [Brho,Bz,values] = AxialCylModelDerbyG(D,L,M,MagPos,Point)

%% Building of the Reference System centered in the magnet centroid
 % vector from the center of the magnet to point of interest
 x   = Point - MagPos(1:3);   
 % z-component is the projection of x onto the z-axis
 z   = x'*MagPos(4:6);      %x(3)
 % radial component is the x-component if we consider only a plane
 rho = sqrt(norm(x)^2-z^2); %x(1)

%% Computation of auxiliary variables
mu0     = 4*pi*1e-7; % void permeability
B0      = mu0*M/pi;  % simple Constant
R       = D/2;       % magnet radius

zP      = z + L/2;                  zM     = z - L/2;
alphaP  = R/sqrt(zP^2+(rho+R)^2);   alphaM = R/sqrt(zM^2+(rho+R)^2);
betaP   = zP/sqrt(zP^2+(rho+R)^2);  betaM  = zM/sqrt(zM^2+(rho+R)^2);
kP      = sqrt((zP^2+(rho-R)^2)/(zP^2+(rho+R)^2));   
kM      = sqrt((zM^2+(rho-R)^2)/(zM^2+(rho+R)^2));
gamma   = (R-rho)/(R+rho);

values.rho    = rho;
values.gamma  = gamma;
values.alphaP = alphaP;
values.alphaM = alphaM;
values.betaP  = betaP;
values.betaM  = betaM;
values.zP     = zP;
values.zM     = zM;
values.R      = R;
values.B0     = B0;
values.kP     = kP;
values.kM     = kM;

%% Computation of the field coordinates

Brho = B0*(alphaP*GeneralizedEllipke(kP,1,1,-1,1e-9) - ...
                    alphaM*GeneralizedEllipke(kM,1,1,-1,1e-9));
               
Bz  = B0*R/(R+rho)*(betaP*GeneralizedEllipke(kP,gamma^2,1,gamma,1e-9) - ...
                    betaM*GeneralizedEllipke(kM,gamma^2,1,gamma,1e-9));