clc
clear all %#ok<CLALL>
close all

%%

MagPos = [0  0.01 0.015 0 0 -1;
          0 -0.01 0.015 0 0 -1;
          0  0.03 0.015 0 0 -1]';      
      
MM = size(MagPos,2); 
D = 0.004*ones(MM,1);
L = 0.002*ones(MM,1);
M = 1.2706/(4*pi*1e-7)*ones(MM,1);

[SensorPosMatrix,WorkspaceDim] = buildWorkspace([8 16],0.009,0);
Brho = zeros(1,size(SensorPosMatrix,1)*MM);
Bz   = Brho; Bx = Brho; By = Brho;
index = 1;

% tic
% for pp = 1:MM
%     for i = 1:size(SensorPosMatrix,1)
%         Point = SensorPosMatrix(i,:);
%         [Brho(index),Bz(index)] = AxialCylModelDerby(D(pp),L(pp),M(pp),MagPos(:,pp),Point');
%         index = index+1;
%     end
% end
% toc

figure
scatter3(SensorPosMatrix(:,1),SensorPosMatrix(:,2),SensorPosMatrix(:,3))
% quiver3(SensorPosMatrix(:,1),SensorPosMatrix(:,2),SensorPosMatrix(:,3),...
%         readings(:,1),readings(:,2),readings(:,3))
for i = 1:MM
    hold on
    drawCylindricalMagnet(L(i),D(i),MagPos(:,i),'texture','axial')
    hold on
    drawVec(MagPos(1:3,i),MagPos(4:6,i)*0.005)
end
hold off
axis([-68 68 -68 68 -68 68]/1000)
setAxes3DPanAndZoomStyle(zoom(gca),gca,'camera')

Points = SensorPosMatrix';

Ns = size(Points,2);

% Points = repmat(Points,1,MM);
% MagPos = reshape(reshape(repmat(MagPos',1,Ns)',1,Ns*MM*6)',6,Ns*MM);

% tic
% Points = repmat(Points,1,MM);
% MagPos = reshape(reshape(repmat(MagPos',1,Ns)',1,Ns*MM*6)',6,Ns*MM);
% 
% [BrhoP,BzP] = ParallelDerby(D(1),L(1),M(1),MagPos,Points,Ns,MM);
% toc

% [Brho' BrhoP']*1e4
% 
% [Bz' BzP']*1e4

%%

index = 1;

tic
for pp = 1:MM
    for i = 1:size(SensorPosMatrix,1)
        Point = SensorPosMatrix(i,:);
        [Bx(index), By(index), Bz(index)] = WrapCylBfield3(D(pp),...
                                                           L(pp),...
                                                           M(pp),...
                                                           MagPos(:,pp),...
                                                           Point');
%         [Brho(index),Bz(index)] = AxialCylModelDerby(D(pp),L(pp),M(pp),MagPos(:,pp),Point');
        index = index+1;
    end
end
toc

tic
BP = ParallelBfield(D(1),L(1),M(1),MagPos,Points);
toc

M = reshape(BP,3,Ns,MM);
Bfinale = sum(M,3);

%%

clc
close all
clear all

MagPos = [0  0.01 0.015 0 0 -1;
          0 -0.01 0.015 0 0 -1;
          0  0.03 0.015 0 0 -1]';      
      
MM = size(MagPos,2); 
D = 0.004*ones(MM,1);
L = 0.002*ones(MM,1);
M = 1.2706/(4*pi*1e-7)*ones(MM,1);

[SensorPosMatrix,WorkspaceDim] = buildWorkspace([8 16],0.009,0);

tic
Readings = GenerateReadings(MagPos',SensorPosMatrix,...
                                      M,D,L);
toc

tic
Readings2 = ParallelGenerateReadings(D(1),L(1),M(1),MagPos,SensorPosMatrix');
toc