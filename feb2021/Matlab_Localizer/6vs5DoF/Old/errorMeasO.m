function [errors, eo, So] = errorMeasO(M,ref)
%PositionBias calcola il bias rispetto ad una posizione di riferimento

N = size(M,2);
  for i = 1:N
    for j = 1:size(M{1,1},1)
      errors(i,j) = vectAngle_3Ddeg(M{1,i}(j, 4:6),ref(i,4:6));
    end
  end
  eo = mean(errors');
  So = std(errors');
end
