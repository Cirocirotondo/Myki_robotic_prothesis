clear all
close all
clc

% addpath ..
% variables_5DoF

first_sample = 500;
n_samples = 1000;

%% prelevo i nomi dei files
dato = getFilesNames();

%% carico segnale pulito per riferimenti
[M6, M5, B, N, name, ref6, ref5] = loadData(dato{end}, first_sample, n_samples);


[errorsp6, ep{1}, Sp{1}] = errorMeasP(M6,ref6*1000);
[errorsp5, ep{2}, Sp{2}] = errorMeasP(M5,ref5*1000);

% MyBar(ep, 'labels', 'magnet', 'e_p (mm)')
MyBar(Sp, 'labels', '', 'S_p (mm)')
