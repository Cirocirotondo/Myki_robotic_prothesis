clear all %#ok<CLALL>
close all
clc

t = linspace(0,2*pi);
L = 0.002;
rin = 0.0007;
rout = 0.002;
xin    = rin*cos(t);
xout   = rout*cos(t);
yin    = rin*sin(t);
yout   = rout*sin(t);
z1     = -L/2;
z2     = L/2;

%% Plot
% clf;
% hold on;
% bottom = patch(center(1)+[xout,xin], ...
%                center(2)+[yout,yin], ...
%                center(3) + z1*ones(1,2*length(xout)),'');
% top = patch(center(1)+[xout,xin], ...
%             center(2)+[yout,yin], ...
%             center(3) + z2*ones(1,2*length(xout)),'');
% [X,Y,Z] = cylinder(1,length(xin));
% outer = surf(rout*X+center(1), ...
%              rout*Y+center(2), ...
%              center(3) + Z*(z2-z1)+z1);
% inner = surf(rin*X+center(1), ...
%              rin*Y+center(2), ...
%              center(3) + Z*(z2-z1)+z1);

xp = magnetPose(1);
yp = magnetPose(2);
zp = magnetPose(3);
center = [xp, yp, zp];
% Magnet Orientation is given by its moment vector
mx = magnetPose(4);
my = magnetPose(5);
mz = magnetPose(6);

m  = [mx; my; mz];  % moment vector
e3 = [ 0;  0;  1];  % z-axis unit vector

x = [xin xout];
y = [yin yout];

xtemp = reshape(x,4*2*301,1);
ytemp = reshape(y,4*2*301,1);
ztemp = reshape(z,4*2*301,1);

Points = [xtemp ytemp ztemp];

if (abs(e3'*m) ~= 1)
    
    v = cross(e3,m);
    s = norm(v);      % sine of the angle
    c = e3'*m;        % cosine of the angle
    
    % skew symmetric tensor of v
    V = [  0    -v(3)   v(2) ; ...
        v(3)    0    -v(1) ; ...
        - v(2)   v(1)    0   ];
    
    % Rodrigues Formula to build the rotation
    % -> since this expression is not defined for |c| = 1, for these two
    %    cases we simply traslate the magnet (not distinguishable rotation)
    R = eye(3) + V + V*V*(1-c)/s^2;
    
    for u = 1:size(Points,1)
        temp        = R*(Points(u,:)');
        Points(u,:) = temp';
    end
    
    x = reshape(Points(:,1),4,301*2) + xp;
    y = reshape(Points(:,2),4,301*2) + yp;
    z = reshape(Points(:,3),4,301*2) + zp;
    
else
    x = x + xp;
    y = y + yp;
    z = z + zp;
end

hold on;
bottom = patch(center(1)+[xout,xin], ...
               center(2)+[yout,yin], ...
               center(3) + z1*ones(1,2*length(xout)),'');
top = patch(center(1)+[xout,xin], ...
            center(2)+[yout,yin], ...
            center(3) + z2*ones(1,2*length(xout)),'');
[X,Y,Z] = cylinder(1,length(xin));
outer = surf(rout*X+center(1), ...
             rout*Y+center(2), ...
             center(3) + Z*(z2-z1)+z1);
inner = surf(rin*X+center(1), ...
             rin*Y+center(2), ...
             center(3) + Z*(z2-z1)+z1);

set([bottom, top, outer, inner], ...
    'FaceColor', [0 1 0], ...
    'FaceAlpha', 0.99, ...
    'linestyle', 'none', ...
    'SpecularStrength', 0.7);
light('Position',[1 3 2]);
light('Position',[-3 -1 3]);
% light
% axis vis3d; 
axis([-0.02 0.02 -0.02 0.02 -0.02 0.02]); 
view(3);
