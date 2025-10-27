clc
clear all %#ok<CLALL>
close all

MagPos = [0 0 0 0 0 1];

M = 1.2706/(4*pi*1e-7);              % Magnetization   [A/m]    
L = 0.006;
D = 0.012;

spaceRegion = 0:0.0001:0.1;
x = spaceRegion; z = x;
Npoints = length(x);
k = 1;

Brho = zeros(Npoints,Npoints); Baxial = Brho; B = Brho;
xx = zeros(Npoints,Npoints);
zz = zeros(Npoints,Npoints);
DBrho   = zz;
DBtheta = zz;
DBz     = zz;

for i = 1:Npoints
    for j = 1:Npoints
        
        Point = [x(j) 0 z(i)];
        xx(i,j) = x(j);
        zz(i,j) = z(i);
        
        [Bx, By, Bz] = WrapCylBfield3(D,L,M,MagPos',Point');
        
        [dBrho, dBtheta, dBz] = gradTensor(D,L,M,Point');
        DBrho(i,j)   = dBrho;
        DBtheta(i,j) = dBtheta;
        DBz(i,j)     = dBz;
        
        Brho(i,j)   = Bx;
        Baxial(i,j) = Bz;
        B(i,j)      = sqrt(Bx^2+Bz^2);
        
    end
end