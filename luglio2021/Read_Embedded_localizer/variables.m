%% VARIABLES

enablePlot_in_run = 0;  %plot man mano che acquisisce i dati (ATTENTO! RALLENTA TUTTO!)

%% sys (system) è una struct contenente tutte le variabili più utilizzate.
sys.nMag = 4;
sys.errMax = 0.0015;
sys.X = [];
sys.XCorrected = [];
% sys.prev_X = [];
sys.trajectories = [];
sys.rotTransl = zeros(1,6);
sys.prev_rotTransl = zeros(1,6);

% sys.x0 = calcola_x0(sensor_position)
sys.x0 = [0 0 0];