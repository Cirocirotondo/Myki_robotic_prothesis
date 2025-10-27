%% Rough force calculations at the level of the forearm

clc
clear all %#ok<*CLALL>
close all
%% 

addpath("X Positions T1-T2-T3");
load("mag_11_t1.mat");

pose(:,1)  = Loc_11_mag_t1{1,1}(1,:)';
pose(:,2)  = Loc_11_mag_t1{2,1}(1,:)';
pose(:,3)  = Loc_11_mag_t1{3,1}(1,:)';
pose(:,4)  = Loc_11_mag_t1{4,1}(1,:)';
pose(:,5)  = Loc_11_mag_t1{5,1}(1,:)';
pose(:,6)  = Loc_11_mag_t1{6,1}(1,:)';
pose(:,7)  = Loc_11_mag_t1{7,1}(1,:)';
pose(:,8)  = Loc_11_mag_t1{8,1}(1,:)';
pose(:,9)  = Loc_11_mag_t1{9,1}(1,:)';
pose(:,10) = Loc_11_mag_t1{10,1}(1,:)';
pose(:,11) = Loc_11_mag_t1{11,1}(1,:)';

figure
for u = 1:11
    drawCylindricalMagnet(0.001,0.002,pose(:,u))
    hold on
    drawnow;
end
hold off
axis equal

