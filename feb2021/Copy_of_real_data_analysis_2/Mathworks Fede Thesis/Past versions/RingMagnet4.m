

rmin = 0.0007;
rmax = 0.002;
L    = 0.002;
colors = [1 0 0; 0 0 1];

magnetPose = [0 0.004 0 1/sqrt(2) 0 1/sqrt(2)];

[x, y, z] = cylinder([rmin,rmax,rmax,rmin],300);
z = z*L;
z([1,2],:) = 0;
z([3,4],:) = L;
z = z-L/2;

% Position where the magnet should be translated
xp = magnetPose(1);
yp = magnetPose(2);
zp = magnetPose(3);
% Magnet Orientation is given by its moment vector
mx = magnetPose(4);
my = magnetPose(5);
mz = magnetPose(6);

m  = [mx; my; mz];  % moment vector
e3 = [ 0;  0;  1];  % z-axis unit vector

xtemp = reshape(x,4*301,1);
ytemp = reshape(y,4*301,1);
ztemp = reshape(z,4*301,1);

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
    
    x = reshape(Points(:,1),4,301) + xp;
    y = reshape(Points(:,2),4,301) + yp;
    z = reshape(Points(:,3),4,301) + zp;
    
else
    x = x + xp;
    y = y + yp;
    z = z + zp;
end

CC1 = surf(x,y,z);
shading flat
if e3'*m == 1
    set(CC1,'facecolor',colors(2,:));
%     set(CC2,'facecolor',colors(1,:));
else            % flip the colors if the magnets is flipped
    set(CC1,'facecolor',colors(1,:));
%     set(CC2,'facecolor',colors(2,:));
end
light

axis([-0.01 0.01 -0.01 0.01 -0.01 0.01])