clc
clear all %#ok<CLALL>
close all
%%

p1 = [1 0 0]';
p2 = [0 1 0]';
p3 = [0 0 1]';

a = 20;
b = -45;
c = -35;

Rx = [ 1      0        0;
       0   cosd(a) -sind(a);
       0   sind(a)  cosd(a)];
   
Ry = [ cosd(b)   0    sind(b);
          0      1      0;
      -sind(b)   0    cosd(b)];
   
Rz = [ cosd(c)  -sind(c)  0;
       sind(c)   cosd(c)  0;
         0         0      1];   
     
p1 = Rx*Ry*Rz*p1;
p2 = Rx*Ry*Rz*p2;
p3 = Rx*Ry*Rz*p3;
     
O = [0.2 0.2 -0.3];

p1 = [1 0 0];
p2 = [0 1 0];
p3 = [0 0 1];

% showFrame(O,p1,p2,p3,'Arrowheadlength',0.4,'Arrowheadwidth',0.2,'sphereradius',0.1)
% axis([-5 5 -5 5 -5 5])
% axis off
% hold on
drawVec(O,[1 0 0],'Arrowheadlength',0.2,'Arrowheadwidth',0.1)
hold on
drawVec(O,[0 1 0],'Arrowheadlength',0.2,'Arrowheadwidth',0.1)
hold on
drawVec(O,[0 0 1],'Arrowheadlength',0.2,'Arrowheadwidth',0.1)
axis([-2 2 -2 2 -2 2])