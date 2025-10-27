% DICHIARAZIONE / INIZIALIZZAZIONE DI TUTTE LE VARIABILI UTILI




global nPos; nPos = 10;
global nMag; nMag = 11;
global errMax; errMax = 0.001;


%% Sensor positions

global Matrix_of_sensors; load ('starting_Marta/Workspace/SimoneWorkspace','Matrix_of_sensors')
Matrix_of_sensors = Matrix_of_sensors*0.0254;   %Consversione pollici-metri

% Matrix_of_sensors_dist : posizione dei sensori a seguito del disturbo
global Matrix_of_sensors_dist; Matrix_of_sensors_dist = cell(nPos,1);



%% x0 = punto di rotazione
%   localizzato presso il fulcro di rotazione protesi-braccio. Per questo:
%   x,z ~ media delle componenti x e z dei sensori
%   y ~ estremità della protesi ~ max(componenti y dei sensori)
global x0; x0 = zeros(1,3);
x0(1) = mean(Matrix_of_sensors(:,1));
x0(2) = max(Matrix_of_sensors(:,2));
x0(3) = mean(Matrix_of_sensors(:,3));


%% Magnets Positions
% celle con una matrice per ogni "istante temporale" nPos -> ogni matrice
% contiene una riga per ogni magnete e, per ogni magnete, [x,y,z,rx,ry,rz]

%MagPos: posizione reale
global MagPos; MagPos = cell(nPos,1);
for i = 1:nPos
    MagPos{i} = zeros(nMag, 6);
end

%MagLoc: localised positions
global MagLoc; MagLoc = cell(nPos,1);
for i = 1:nPos
    MagPos{i} = zeros(nMag, 6);
end

%MagLoc_dist: localised position when the system receives mechanical disturbances
global MagLoc_dist; MagLoc_dist = cell(nPos,1);
for i = 1:nPos
    MagPos{i} = zeros(nMag, 6);
end

%MagCorrected: corrected magnet position, obtained with the optimization algorithm
global MagCorrected; MagCorrected = cell(nPos,1);
for i = 1:nPos
    MagCorrected{i} = zeros(nMag, 6);
end

%B: magnet field
global B; B = cell(nPos,1);

%B_dist: magnetic field revealed when victim of mechanical disturbances
global B_dist; B_dist = cell(nPos,1);

% Rototranslation
global rototranslation; rototranslation = cell(nPos,1);
for i = 1:nPos
    rototranslation{i} = zeros(1,6);
end

%% Enable plots

enablePlotSetup = 1;
enablePlotCurrent = 1;


%% Magnets parameters
global DD; load('starting_Marta/Workspace/SimoneWorkspace','DD');   % Diameter of the magnets (vector)
global LL; load('starting_Marta/Workspace/SimoneWorkspace','LL');  % Length of the magnets (vector)
global M; load('starting_Marta/Workspace/SimoneWorkspace','M');     % Magnetization of the magnets (scalar)
global m; m = M*((DD(1)/2)^2*pi*LL(1));     %NOTA: considero tutti i magneti uguali, e considero quindi solo DD(1),LL(1)

%% Magnets trajectories
% "trajectories" = matrice nella forma: "[xi, yi, zi, xf, yf, zf]", da mettere nella forma "[xi, xf, yi, yf, zi, zf]", con una riga per ogni magnete
global trajectories 

trajectories_temp = [[10.2735573584774, 43.3566574758324, 1.76183360527188], [10.0988113864134,43.5566113978991,1.82875520899814];
                [9.32750893970686,42.5925965867644,-0.377254341092012], [9.06843085843511,42.8468952624033,-0.336393051385770];
                [11.2151317135085,43.3908622722126,0.395808132449483], [11.2760799508457,43.6096416403250,0.467143372414066];
                [10.2108077021876,40.8338483447033,1.26418705416978], [10.0364620980444,41.1882921541323,1.32897576143696];
                [11.5585526766258,42.1306606420998,0.616835182239454], [11.6292180290565,42.4252864015598,0.709220546883509];
                [9.02864908441902,41.6236947481038,0.854377636048454], [8.96138800407966,41.8587123516162,1.10181572446636];
                [11.0128945001253,43.1952354386141,1.54389999164625], [10.6895921081728,43.4803365364488,1.59643591531984];
                [10.9499113951121,42.2043471072247,1.31421983543626], [10.8054205494580,42.5260547027533,1.59407306930905];
                [11.3950935752542,41.3224382287552,0.999170859694644], [11.2612745647402,41.6193578915352,1.30936006009495];
                [10.3792058611298,44.0515068240669,1.60081628760796], [10.3379530036212,44.2569414356521,1.59983810625329];
                [9.54211733637152,40.8700258364480,-0.0284196571899784], [9.25683647567058,41.1638731064250,0.0196521692029670]] * 0.0254;
        
trajectories = trajectories_temp;
trajectories(:,2) = trajectories_temp(:,4);
trajectories(:,3) = trajectories_temp(:,2);
trajectories(:,4) = trajectories_temp(:,5);
trajectories(:,5) = trajectories_temp(:,3);

clear trajectories_temp



%% Random Gaussian Noise

rng(2) % seed for generating the same random numbers everytime I launch the code
mu                  =       0.000;
sigma               =       0.004;

