%% Cylinder magnetic field visualization
 % This script is a DEMO for the visualization of the magnetic flux density
 %  field lines of an axially magnetized cylinder.

clc
clear all %#ok<CLALL>
close all
%%

MagPos = [0 0 0 0 0 1];

M = 1.2706/(4*pi*1e-7);              % Magnetization   [A/m]    
L = 0.002;
D = 0.004;

spaceRegion = -0.4:0.001:0.4;
x = spaceRegion; z = x;
Npoints = length(x);
k = 1;

[xx, zz] = meshgrid(x);

xp = reshape(xx',length(x)*length(x),1);
zp = reshape(zz',length(x)*length(x),1);
Points = [xp zeros(length(x)*length(x),1) zp]';

Bfield = ParallelBfield(D,L,M,MagPos',Points);

Brho   = reshape(Bfield(1,:),length(x),length(x))';
Baxial = reshape(Bfield(3,:),length(x),length(x))';

Bfield2 = ParallelDipole(MagPos',1,M*D^2/4*L,Points');

Brho2   = reshape(Bfield2(:,1),length(x),length(x))';
Baxial2 = reshape(Bfield2(:,3),length(x),length(x))';

B     = sqrt(Brho.^2+Baxial.^2);

%% Contour lines (logscale)

figure
imagesc(log10(abs(Brho-Brho2)*1e4))
colormap(jet)
caxis([-11 4])

figure
imagesc(log10(abs(Baxial-Baxial2)*1e4))
colormap(jet)
caxis([-11 4])

%%

step = 25;
figure(3) 
contourf(xx,zz,log10(B),1000,'EdgeColor','none')
colormap(jet)
colorbar
hold on 
h = streamline(xx,zz,Brho,Baxial,...
    xx(1:step:end,1:step:end),zz(1:step:end,1:step:end));
rectangle('Position',[0-D/2,0-L/2,D,L/2],'FaceColor',[0 0 1])
rectangle('Position',[0-D/2,0,D,L/2],'FaceColor',[1 0 0])
set(h,'Color','red');
title('\textbf{Cylindrical Magnet Model Field Lines}','interpreter','latex',...
    'fontsize',14)
xlabel('x [m]','interpreter','latex')
ylabel('z [m]','interpreter','latex')

N = length(x)-1;

dBaxialdz = Baxial(2:N+1,:)-Baxial(1:N,:);
dBaxial   = Baxial(:,2:N+1)-Baxial(:,1:N);

dBrho   = Baxial(2:N+1,:)-Baxial(1:N,:);
dBrhodx = Brho(:,2:N+1)-Brho(:,1:N);

dBaxial2 = Baxial2(:,2:N+1)-Baxial2(:,1:N);
dBrho2   = Brho2(2:N+1,:)-Brho2(1:N,:);

figure
subplot(211)
imagesc(log10(abs(dBaxial)))
subplot(212)
imagesc(log10(abs(dBrhodx))')
colormap(jet)
caxis([-11 4])

figure
subplot(211)
imagesc(log10(abs(dBaxialdz)))
subplot(212)
imagesc(log10(abs(dBrho)))
colormap(jet)
caxis([-11 4])

figure
subplot(211)
imagesc(log10(abs(dBaxial2(1:N,:))))
subplot(212)
imagesc(log10(abs(dBrho2(:,1:N))))

figure
imagesc(log10(abs(Brho./Baxial)))
colorbar