function [dBrho, dBtheta, dBz] = gradTensor(D,L,M,Point)

MagPos = [0 0 0 0 0 1];

[Brho, ~, values] = AxialCylModelDerbyG(D,L,M,MagPos',Point);

rho    = values.rho;
gamma  = values.gamma;
alphaP = values.alphaP;
alphaM = values.alphaM;
betaP  = values.betaP;
betaM  = values.betaM;
zP     = values.zP;
zM     = values.zM;
R      = values.R;
B0     = values.B0;
kP     = values.kP;
kM     = values.kM;
kPp    = sqrt(1-kP^2);
kMp    = sqrt(1-kM^2);


dBrho   = B0*( -alphaP^3*(rho+R)/R*GeneralizedEllipke(kP,1,1,-1,1e-9) + ...
               alphaP*1/kPp*GeneralizedEllipke(kP,1,(1+kPp^2)/(1-kPp^2),2,1e-9)*(1/sqrt(rho*R)*alphaP-2*alphaP*(rho+R)*sqrt(rho)/R^(5/2)) - ...
               +alphaM^3*(rho+R)/R*GeneralizedEllipke(kM,1,1,-1,1e-9) - ...
               alphaM*1/kMp*GeneralizedEllipke(kM,1,(1+kMp^2)/(1-kMp^2),2,1e-9)*(1/sqrt(rho*R)*alphaM-2*alphaM*(rho+R)*sqrt(rho)/R^(5/2)));

dBtheta = Brho/rho;

dBz     = B0/2*( betaP*(1+betaP^2)/zP*GeneralizedEllipke(kP,gamma^2,1,gamma,1e-9) + ...
                 betaP*kPp/(kPp^2-gamma^2)*(GeneralizedEllipke(kP,1,(kPp^2-gamma^2+gamma)/(1-kPp^2),gamma,1e-9)-gamma*GeneralizedEllipke(kP,1-gamma^2,1,1,1e-9))*betaP^3*4*sqrt(R*rho)/zP^2 - ...
                 betaM*(1+betaM^2)/zM*GeneralizedEllipke(kM,gamma^2,1,gamma,1e-9) - ...
                 betaM*kMp/(kMp^2-gamma^2)*(GeneralizedEllipke(kM,1,(kMp^2-gamma^2+gamma)/(1-kMp^2),gamma,1e-9)-gamma*GeneralizedEllipke(kM,1-gamma^2,1,1,1e-9))*betaM^3*4*sqrt(R*rho)/zM^2 );

