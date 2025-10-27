function [M, ref] = extract_localizations(cells, first_sample, n_samples)
%extract_localizations estrae i dati dalle celle e li ritorna in N (ossia
%il numero dei magneti) matrici.

  N = size(cells{1,2},1);
  n_cells = size(cells,2);
  DoFs = size(cells{2},2);

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



  for i = 1:N
    M{i} = zeros(n_samples, DoFs);
  end

  ref = cells{1,first_sample};
  for t = 1:n_samples
    tempMat = cells{1,first_sample+t-1};
    for i = 1:N
      M{i}(t,1:DoFs) = tempMat(i,:);
    end
  end


end
