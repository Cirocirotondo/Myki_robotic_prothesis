close all
clear
clc

%load('C:\Users\Sergio\OneDrive - University of Pisa\All_Results_Quarantena\Disturbi_Meccanici\3MMs_0mov_2acq_1706\3MMs_0move_2acq_1706')
load('3MMs_0mov_2acq_1706.txt')
clear ans h k dx dy user
% interval 250-750

%% Results

[R, D] = Reduction(y(2,:), SensorPositionMatrix, numMag);

DoScatterPlots(Mag_Position,y(1:50,:),SensorPositionMatrix, MagField, 3)

figure; set(gcf, 'Position', [10 10 1200 800]) 
for k = 1:numMag
    subplot(numMag,1,k)
    hold on
    plot(estim(:,k),'Color',[0 0.447 0.741])
%     plot(real(:,k).*12.35,'Color',[0.85 0.325 0.098])
    hold off
end

% %% For frequency analysis
% 
% % Servo
% 
% M1 = real;
% 
% n = size(M1,1);
% fs = 1/0.05; % 20 Hz is the sampling frequency
% 
% f = (0:n-1)*(fs/n);
% fshift = (-n/2:n/2-1)*(fs/n);
% figure;
% for h = 1:size(M1,2)
%     subplot(size(M1,2),1,h)
%     stem(fshift, abs(fftshift(fft(M1(:,h)))));
% end
% 
% % Displacement
% 
% M2 = estim;
% 
% figure;
% for h = 1:size(M2,2)
%     subplot(size(M2,2),1,h)
%     stem(fshift, abs(fftshift(fft(M2(:,h)))));
% end

%% REMOVE REFERENCE MAGNET

ref = 2;

[rem, axang, rem_rot] = Adjust_with_ref(y, ref);

for k = 2:size(y,1)
    for h = 1:numMag
%         if h ~= ref
            a = [y(k,(h-1)*6+1)-rem((k-1),1) y(k,(h-1)*6+2)-rem((k-1),2) y(k,(h-1)*6+3)-rem((k-1),3)];
            b = [y(k,(h-1)*6+4)-rem_rot((k-1),1) y(k,(h-1)*6+5)-rem_rot((k-1),2) y(k,(h-1)*6+6)-rem_rot((k-1),3)]
%             a = a*rotm{k-1}
            y(k,(h-1)*6+1) = a(1);
            y(k,(h-1)*6+2) = a(2);
            y(k,(h-1)*6+3) = a(3);
            y(k,(h-1)*6+4) = b(1);
            y(k,(h-1)*6+5) = b(2);
            y(k,(h-1)*6+6) = b(3);
    end    
end

[estim, real, estim_rot, real_rot] = Compute_Displacement(servo, y, numMag);


figure; set(gcf, 'Position', [10 10 1200 800]) 
for k = 1:numMag
    subplot(numMag,1,k)
    hold on
    plot(estim(:,k),'Color',[0 0.447 0.741])
%     plot(real(:,k).*12.35,'Color',[0.85 0.325 0.098])
%     legend('estimated','servo','Location','northwest','FontSize',16)
    hold off
end

figure; set(gcf, 'Position', [10 10 1200 800]) 
for k = 1:numMag
    subplot(numMag,1,k)
    hold on
    plot(estim_rot(:,k),'Color',[0 0.447 0.741])
    plot(real_rot(:,k),'Color',[0.85 0.325 0.098])
%     legend('estimated','servo','Location','northwest','FontSize',16)
    hold off
end





%%

