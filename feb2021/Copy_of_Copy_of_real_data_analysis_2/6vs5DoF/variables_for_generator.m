nMag = 2;
nPos = 20; % number of times th emagnets have to be moved
dist = 1/1000;  % how far the magnets have to be moved
alpha = 0.9;    % [between 0 and 1] determines how straight magnets randomly moves
noise_sd = 4/1000;  % sensors noise standard deviation
min_dist = 5/1000;  % minimum distance between magnets
nBoards = 4;
plotta_grafici_3D = true;   % plots 3D graphs showing localizations in space
grafici_sovrapposti = false;  % overimpose the two localizations
blocco_vista = true;   % limits visualized area to boundaries
plot_computation_times = true; % produces a graph showing compared computation times between 5 and 6 DoFs systems
plot_errors = true; % produces graphs showing compared pose errors between 5 and 6 DoFs systems
plot_fails = true;  % produces graphs showing the number of localization fails between 5 and 6 DoFs systems
max_acceptable_dist = 1/1000; % maximum distance to ground thruth to consider a localization correct
max_acceptable_ang = 8; % maximum angle to ground thruth to consider a localization correct
sort_axis = 2;  % axis on which execute sorting


% boardsPosePLAIN= [        0,      0,      0,    0,    0,    0;
%                        44.5,      0,    1.5,    0,    0,    0;
%                      44.5*2,      0,      0,    0,    0,    0;
%                      44.5*3,      0,    1.5,    0,    0,    0;
%                      44.5*4,      0,      0,    0,    0,    0];
%
% boardsPoseTOWER= [      0,      0,       0,    0,    0,    0;
%                         0,      0,    11.5,    0,    0,    0;
%                         0,      0,  11.5*2,    0,    0,    0;
%                         0,      0,  11.5*3,    0,    0,    0;
%                         0,      0,  11.5*4,    0,    0,    0];
%
% boardsPoseCROSS= [          0,         0,          0,    0,    0,    0;
%                         -44.5,         0,       2.57,    0,    0,    90;
%                         -44.5,     -44.5,     2.57*2,    0,    0,    180;
%                             0,     -44.5,     2.57*3,    0,    0,    270];

boardsPoseMOKUP= [     38.6,      0,   92.4,    0,  180,    0;
                          0,      0,      0,    0,    0,    0;
                      -32.1,      0,   71.4,    0,  270,    0;
                       69.3,      0,   30.8,    0,   90,    0];

boardsPose = boardsPoseMOKUP;
boardsPose(:,1:3) = boardsPose(:,1:3)/1000;

sPos_wrtBoard = [ 5.5,    4,    0;  ...    % 1
                  5.5,    13,   0;  ...
                  5.5,    22,   0;  ...
                  5.5,    31,   0;  ...
                  5.5,    40,   0;  ...
                  5.5,    49,   0;  ...
                  5.5,    58,   0;  ...    %7
                  5.5,    67,   0;  ...    %8
                  % 11.4,    115.9,    0;  ...    %8far
                  14.5,   4,    0;  ...    %9
                  14.5,   13,   0;  ...
                  14.5,   22,   0;  ...
                  14.5,   31,   0;  ...
                  14.5,   40,   0;  ...
                  14.5,   49,   0;  ...
                  14.5,   58,   0;  ...
                  14.5,   67,   0;  ...    %16
                  23.5,   4,    0;  ...    %17
                  23.5,   13,   0;  ...
                  23.5,   22,   0;  ...
                  23.5,   31,   0;  ...
                  23.5,   40,   0;  ...
                  23.5,   49,   0;  ...
                  23.5,   58,   0;  ...
                  23.5,   67,   0;  ...    %24
                  32.5,   4,    0;  ...    %25
                  32.5,   13,   0;  ...
                  32.5,   22,   0;  ...
                  32.5,   31,   0;  ...
                  32.5,   40,   0;  ...
                  32.5,   49,   0;  ...
                  32.5,   58,   0;  ...    %31
                  32.5,   67,   0 ]/1000; %32
                  % 27.2,    115.9,    0]/1000; % 32far


sPos = positionateSensors(sPos_wrtBoard, boardsPose, nBoards);

x = rand_x0_3D(nMag,sPos,0.02);
% x = [       20,      0,      35,      0,  -1000,      0;
%             20,      2,      65,      0,      0,  -1000;
%              0,      4,      50,      0,  +1000,      0;
%             40,      6,      50,  +1000,      0,      0;
%           % 20,      8,      50,      0,      0,  +1000;
%             20,   0+20,      35,      0,      0,  -1000;
%             20,   2+20,      65,      0,  -1000,      0;
%              0,   4+20,      50,  +1000,      0,      0;
%             40,   6+20,      50,      0,      0,  -1000;
%           % 20,   8+30,      50,      0,  +1000,      0;
%             20,   0+40,      35,  +1000,      0,      0;
%             20,   2+40,      65,      0,      0,  -1000;
%              0,   4+40,      50,      0,  +1000,      0;
%             40,   6+40,      50,      0,      0,  -1000]/1000;
%           % 20,   8+60,      50,      0,  -1000,      0]/1000;


mrg = 0.05; % [m] bound margin
bounds = [min(sPos(:,1))-mrg, max(sPos(:,1))+mrg, min(sPos(:,2))-mrg, max(sPos(:,2))+mrg, min(sPos(:,3))-mrg, max(sPos(:,3))+mrg];

clear boardsPosePLAIN boardsPoseTOWER boardsPoseCROSS boardsPoseMOKUP sPos_wrtBoard
