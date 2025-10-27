function [B] = extract_field(cells, first_sample, n_samples)
%extract_field estrae i dati dalle celle e li ritorna in N (ossia
%il numero dei sensori) matrici.

  N = size(cells{1},1);
  n_cells = size(cells,2);

  if nargin < 2
    first_sample = 2;
  end
  if first_sample == 1
    first_sample = 2;
  end
  if nargin < 3
    n_samples = n_cells-first_sample-1;
  end

  if first_sample > n_cells || (n_samples+first_sample-1) > n_cells
    error('----------Interval to be returned is out of bounds')
    return
  end

  for i = 1:N-2
    B{i} = zeros(n_samples, 3);
  end

  for t = 1:n_samples
    tempMat = cells{1,first_sample+t-1};
    for i = 1:7
      B{i}(t,1:3) = tempMat(i,:);
    end
    for i = 9:31
      B{i-1}(t,1:3) = tempMat(i,:);
    end
  end

end
