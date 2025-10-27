function updateVar(k)
% Nel caso in cui non venga chiamato l'algoritmo di correzione dei disturbi
% meccanici, alcune variabili rimarrebbero con valori nulli

    global MagCorrected
    global MagLoc_dist
    global rototranslation
    
    MagCorrected{k} = MagLoc_dist{k};
    rototranslation{k} = zeros(1,6);

end