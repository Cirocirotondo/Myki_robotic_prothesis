function correctMagPos(k)

    global rototranslation
    global MagCorrected
    global MagLoc_dist
    
    MagCorrected{k} = rotoTrasla(MagLoc_dist{k}, rototranslation{k});

end