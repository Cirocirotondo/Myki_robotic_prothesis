function[xRotoTrasl] = rotoTrasla(x, rototranslation, boardsPoseMOKUP)
    xRotoTrasl = x;
    [num,~] = size(x);
    
    %rotazione
    for i = 1:num
        xRotoTrasl(i,:) = rotateY(rototranslation(5), xRotoTrasl(i,:), boardsPoseMOKUP);      
        xRotoTrasl(i,:) = rotateZ(rototranslation(6), xRotoTrasl(i,:), boardsPoseMOKUP);
        xRotoTrasl(i,:) = rotateX(rototranslation(4), xRotoTrasl(i,:), boardsPoseMOKUP);
    end
    
%     traslazione
    xRotoTrasl(:,1:3) = xRotoTrasl(:,1:3) + rototranslation(1:3);

end