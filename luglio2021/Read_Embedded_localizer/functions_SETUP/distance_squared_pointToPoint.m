function[cost] = distance_squared_pointToPoint(r0, X)
    cost = sum(sum( (X - r0).^2 ));  %somma dei quadrati delle distanze dei punti di X da r0
end