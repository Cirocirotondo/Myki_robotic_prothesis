%% CYBERGLOVE CALIBRATION - Algorithm (version 2)
%% Calibration data acquisitions
clear all 
clc 

Cyber1=Cyberglove('COM4');
StartAcquisition(Cyber1);
T=5;
pause(T);
StopAcquisition(Cyber1);

% Saving data
GlovePos = [];
fid = fopen('pos.csv');
tline = fgetl(fid);

%check tline
while ischar(tline)
   row= str2num(tline);
   disp(row);
   GlovePos = [GlovePos; row];
   tline = fgetl(fid);
end
fclose(fid);
answer00 = questdlg('Hand condition: ', ...
          'Hand condition', ...
          'Open','Close','Open');
        switch answer00
            case 'Open'
                save('C:\Users\Handlab3\OneDrive - Politecnico di Torino\TESI MAGISTRALE\Data&Code\CG_Calibration\Algorithm version 2\Data\S08\open.mat','GlovePos')
            case 'Close'
                save('C:\Users\Handlab3\OneDrive - Politecnico di Torino\TESI MAGISTRALE\Data&Code\CG_Calibration\Algorithm version 2\Data\S08\close.mat','GlovePos')
        end
delete(Cyber1);

%% Saving calibration data
clear all 
close all 
clc
load('C:\Users\Handlab3\OneDrive - Politecnico di Torino\TESI MAGISTRALE\Data&Code\CG_Calibration\Algorithm version 2\Data\S08\open.mat')
open = GlovePos(:,1:15);
load('C:\Users\Handlab3\OneDrive - Politecnico di Torino\TESI MAGISTRALE\Data&Code\CG_Calibration\Algorithm version 2\Data\S08\close.mat')
close = GlovePos(:,1:15); 

open_mean = mean(open); 
close_mean = mean(close);  

save('C:\Users\Handlab3\OneDrive - Politecnico di Torino\TESI MAGISTRALE\Data&Code\CG_Calibration\Algorithm version 2\Data\S08\calibration.mat','close_mean');
csvwrite('C:\Users\Handlab3\OneDrive - Politecnico di Torino\TESI MAGISTRALE\Data&Code\CG_Calibration\Algorithm version 2\Data\S08\calibration.csv',close_mean); 
writematrix(close_mean, 'D:\calibration.txt');
calibration = close_mean; 
dist = pdist2(close_mean, open_mean, 'euclidean');
threshold = 0.5*dist;
% threshold2 = 0.4*dist; 
disp(threshold);
% disp(threshold2);

%% Test
Cyber1=Cyberglove('COM4');
ans = 0;
StartAcquisition(Cyber1);

y1 = [dist dist];
y2 = [0 0];
y3 = [threshold threshold];

figure()
tic
i=1;
while ans == 0
    fid = fopen('pos.csv');
    array = str2num(fgetl(fid));
    disp(array);
    fclose(fid);
    dist_live(i) = pdist2(calibration, array(1:15), 'euclidean');
    i=i+1;
    elapsedTime = toc;
    x = [1 2000];
    line(x,y1,'linewidth', 1.5, 'color','k'),hold on, line(x,y2,'linewidth', 1.5,'color', 'k'), hold on, 
    line(x,y3, 'linewidth',1.5,'color','r'), hold on
    plot(dist_live,'color','b')
    title('TEST')
    drawnow limitrate
    hold on
    if i == 2000; 
        ans=2; 
    end 
end
hold off
StopAcquisition(Cyber1);
delete(Cyber1);
