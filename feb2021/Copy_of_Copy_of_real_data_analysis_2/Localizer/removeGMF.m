function [acq] = removeGMF(acq, remS)
%Subtracts the field from the remote sensors
  gmf = mean(acq(remS, :),1);
  acq = acq - (ones(32,1)*gmf);
%   acq(remS,:) = [];
end
