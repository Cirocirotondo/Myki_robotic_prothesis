%% Function drawCylindricalMagnet
 % -----------------------------------------------------------------------
 % This function draws a cylindrical magnet of length/height: L and
 % diameter D. The drawn magnet is translated according to the first three
 % coordinates of magnetPose (cartesian coordinates) and oriented according
 % to the last three coordinates of magnetPose (magnetic moment vector).
 %
 % Inputs: 
 %       1) L : length/height of the magnet;                     [number]
 %       2) D : diameter of the magnet;                          [number]
 %       3) magnetPose : is a 1*6 (or 6*1) array containing the three
 %                       cartesian coordinates of the desired center of the 
 %                       magnet and the three coordinates of the moment
 %                       vector used to retrieve the orientation of the
 %                       magnet.                                 [6x1]
 %
 % Notes: orientation of the magnet is computed from the moment vector
 % through the Rodrigues' rotation formula.
 %
 % ---------------------------------------------------------------------
 % July 20th, 2019                               Author: Federico Masiero
 % ---------------------------------------------------------------------
 %
 %                                          Last check: October 6th, 2019
 
function [] = drawCylindricalMagnet(L,D,magnetPose)

% Cylinder dimensions
h  = L;     % height
ra = D/2;   % radius
syms t

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

[x,y,z] = cylinder([0,ra,ra,0],300);
z = z*h;
z([1,2],:) = 0;
z([3,4],:) = h;
z = z-h/2;

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
         -v(2)   v(1)    0   ];
    
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
  
%CC = mesh(x,y,z);
CC = surf(x,y,z);
set(CC,'facecolor',[0.25 0.25 0.25]);
%light               % create a light
%lighting gouraud    % preferred method for lighting curved surfaces
material dull

%% References
% Rodriguez's formula:
% from: https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d