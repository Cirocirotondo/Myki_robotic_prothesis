function [M6, M5, B, N, name, ref6, ref5] = loadData(name, first_sample, n_samples)
%loadData carica i dati e li mette in una cella che li divide per magnete
%invece che per acquisizione

load(name)

[M6, ref6] = extract_localizations(localizations, first_sample, n_samples);
[B] = extract_field(acquisitions, first_sample, n_samples);
N = size(M6,2);
% M6 = sortMagnets(M6);
M6 = m2mm(M6);

[M5, ref5] = extract_localizations(localizations_5DoF, first_sample, n_samples);
% M5 = sortMagnets(M5);
M5 = m2mm(M5);

end
