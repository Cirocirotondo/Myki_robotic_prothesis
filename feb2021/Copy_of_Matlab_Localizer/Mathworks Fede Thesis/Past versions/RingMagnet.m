clear all %#ok<CLALL>
close all
clc

t = linspace(0,2*pi);
L = 0.002;
rin = 0.0008;
rout = 0.002;
center = [0, 0];
xin    = rin*cos(t);
xout   = rout*cos(t);
yin    = rin*sin(t);
yout   = rout*sin(t);
z1     = -L/2;
z2     = L/2;

%% Plot
% clf;
hold on;
bottom = patch(center(1)+[xout,xin], ...
               center(2)+[yout,yin], ...
               z1*ones(1,2*length(xout)),'');
top = patch(center(1)+[xout,xin], ...
            center(2)+[yout,yin], ...
            z2*ones(1,2*length(xout)),'');
[X,Y,Z] = cylinder(1,length(xin));
outer = surf(rout*X+center(1), ...
             rout*Y+center(2), ...
             Z*(z2-z1)+z1);
inner = surf(rin*X+center(1), ...
             rin*Y+center(2), ...
             Z*(z2-z1)+z1);

set([bottom, top, outer, inner], ...
    'FaceColor', [0 1 0], ...
    'FaceAlpha', 0.99, ...
    'linestyle', 'none', ...
    'SpecularStrength', 0.7);
light('Position',[1 3 2]);
light('Position',[-3 -1 3]);
% light
% axis vis3d; 
axis([-0.01 0.01 -0.01 0.01 -0.01 0.01]); 
view(3);
