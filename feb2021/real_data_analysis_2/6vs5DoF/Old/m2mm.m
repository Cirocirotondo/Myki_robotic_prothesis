function [M] = m2mm(M)
%m2mm converte le posizioni da metri a millimetri

  N = size(M,2);
  for i = 1:N
    M{1,i}(:,1:3) = M{1,i}(:,1:3).*1000;
  end
end
