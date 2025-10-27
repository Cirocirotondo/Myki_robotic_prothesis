function[costo] = distance_squared(V, r0, X)
[num_points,~] = size(X); 
costo = 0;
for i = 1:num_points
    A = r0;
    B = r0 + V;
    a = A - B;
    b = B - X(i, 1:3);
    d = norm(cross(a,b))/norm(a);       %distanza = area / base
    costo = costo + d*d;                %costo = somma dei quadrati delle distanze
end

end