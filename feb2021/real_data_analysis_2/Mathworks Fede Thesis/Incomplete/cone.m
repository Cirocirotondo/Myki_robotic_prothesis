h = 0.2; % height of the cone
w = 1/(2*h);
r = -linspace(0,h); 
th = linspace(0,2*pi);
[R,T] = meshgrid(r,th);
Xc = R.*cos(T)./3; % ./3 is for width scaling
Yc = R.*sin(T)./3;
Zc = R + h/2;

surf(Xc,Yc,Zc)