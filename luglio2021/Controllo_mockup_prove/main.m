clear all
close all
clc
addpath("../Controllo_mockup");


ports = serialportlist
servo_port = serialport('COM8', 9600);

nMag = 4;
mot_num = [1,2,4,5,7];    % corrispondenti al muscolo [11,6,14,12,4]
muscles_num = [ 5, 6, 10, 12,14];
mot_num2 = [ 2,4,5,6,7];
mot_num3 = [0,5,6,7];


%% setup
disp("press a key to bring the magnet to the starting position")
pause()
%tutti i motori in posizione di start
for i = 1:length(mot_num3)
        moveServo(mot_num3(i), 0, servo_port);
end
disp("Motori in posizione 0")
disp("press a key to start") 
pause()

%3...2...1..start
tic
while toc < 2.7
    for i = 1:length(mot_num3)
        moveServo(mot_num3(i), 1/2.7*toc, servo_port);
    end
end

%% movimento lineare

while(1)
    for p = 0:0.005:1
        for i = 1:nMag
            moveServo(mot_num3(i), p, servo_port);
        end
        pause(0.005)
    end
    for p = 1:-0.005:0
        for i = 1:nMag
            moveServo(mot_num3(i), p, servo_port);
        end
        pause(0.005)
    end
end

%% movimento random
%  while(1)
%     pos_rnd = rand(1,nMag);
%     for i = 1:nMag
%         moveServo(mot_num3(i), pos_rnd(i), servo_port);
%     end
%     disp(pos_rnd)
%     pause(1)
%    
% end
%%

% i = 0;
%  while(1)
%     moveServo(i, 0, servo_port);
%     disp('0')
%     pause(1)
%     
%     moveServo(i, 1, servo_port);
%     disp('1')
%     pause(1)
%    
%   end
% 
% 
% %% SETUP: i motori vengono mandati ai 2 finecorsa
% 
% for m = 1:nMag          % tutti i motori a inizio corsa
%     moveServo(mot_num(m), 0, servo_port);
% end
% pause(10)
% 
%     for i = 0:0.01:1        % tempo totale per andare da un capo all'altro: 2 secondi
%     for m = 1:nMag
%         moveServo(mot_num(m), i, servo_port);
%         pause(0.02)
%     end
% end
% 
% 
%  m = 0;
% 
% while(1)
%     moveServo(m, 0, servo_port);
%     pause(2)
%     moveServo(m, 1, servo_port);
%     pause(2)
% end

% mot_num = [0 1 2 3 4];
% while(1)
%   for m = 1:5
%     moveServo(mot_num(m), 0, servo_port);
%     pause(2)
%     moveServo(mot_num(m), 1, servo_port);
%     pause(2)
%   end
% 
% end




% if move_motors
%   servo_port = serialport('COM8', 9600);
%   for m = 1:5
%     moveServo(mot_num(m), 0, servo_port);
%   end
% end